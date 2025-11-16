#!/usr/bin/env python3
"""Utility to strip only the problematic template scaffolding from symbol SVGs.

watchOS 26 tightened its SVG parser for complications/widgets. Our assets
need the Guides + Symbols groups and any class-based styling intact, but the
"Notes" implementation instructions, generator comments, and metadata can go.
This script removes only the known offenders and leaves the rest of the SVG
byte order untouched so multi-weight symbols continue to import cleanly.
"""

from __future__ import annotations

import argparse
import sys
from io import StringIO
import re
from pathlib import Path
from typing import Iterable, Tuple
import xml.etree.ElementTree as ET
from xml.etree.ElementTree import Comment

ET.register_namespace("", "http://www.w3.org/2000/svg")

XMLNS_DECL_RE = re.compile(r"\s+xmlns(?::(?P<prefix>[\w.-]+))?=\"(?P<uri>[^\"]+)\"")

REMOVE_IDS = {"Notes", "template-version", "descriptive-name"}
KEEP_ROOT_IDS = {"Symbols", "Guides"}
DROP_TAGS = {"metadata"}


def local_tag(elem: ET.Element) -> str:
    tag = elem.tag
    if tag.startswith("{"):
        return tag.split("}", 1)[1]
    return tag


def remove_comments(elem: ET.Element) -> bool:
    changed = False
    for child in list(elem):
        if child.tag is Comment:
            elem.remove(child)
            changed = True
            continue
        changed |= remove_comments(child)
    return changed


def prune_children(elem: ET.Element, svg_root: ET.Element) -> bool:
    changed = False
    for child in list(elem):
        tag = local_tag(child)
        child_id = child.attrib.get("id")

        if child_id in REMOVE_IDS:
            elem.remove(child)
            changed = True
            continue

        if tag in DROP_TAGS:
            elem.remove(child)
            changed = True
            continue

        if elem is svg_root:
            if child_id in KEEP_ROOT_IDS or child_id is None:
                changed |= prune_children(child, svg_root)
            else:
                elem.remove(child)
                changed = True
            continue

        changed |= prune_children(child, svg_root)
    return changed


def extract_prolog_and_namespaces(text: str) -> Tuple[str, dict[str, str]]:
    svg_idx = text.find("<svg")
    if svg_idx == -1:
        return "", {}

    prolog = text[:svg_idx]
    tag_close = text.find(">", svg_idx)
    if tag_close == -1:
        return prolog, {}

    start_tag = text[svg_idx : tag_close + 1]
    namespaces: dict[str, str] = {}
    for match in XMLNS_DECL_RE.finditer(start_tag):
        prefix = match.group("prefix") or ""
        namespaces[prefix] = match.group("uri")

    return prolog, namespaces


def reassemble_xml(prolog: str, tree: ET.ElementTree) -> str:
    prolog_value = prolog if prolog else "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    buffer = StringIO()
    tree.write(buffer, encoding="unicode", xml_declaration=False)
    body = buffer.getvalue()
    combined = f"{prolog_value}{body}"
    if not combined.endswith("\n"):
        combined += "\n"
    return combined


def ensure_namespace_decls(svg_text: str, namespaces: dict[str, str]) -> str:
    if not namespaces:
        return svg_text

    start_idx = svg_text.find("<svg")
    if start_idx == -1:
        return svg_text

    end_idx = svg_text.find(">", start_idx)
    if end_idx == -1:
        return svg_text

    start_tag = svg_text[start_idx : end_idx + 1]
    missing = []
    for prefix, uri in namespaces.items():
        decl = f' xmlns:{prefix}="{uri}"' if prefix else f' xmlns="{uri}"'
        if decl not in start_tag:
            missing.append(decl)

    if not missing:
        return svg_text

    new_tag = f"{start_tag[:-1]}{''.join(missing)}>"
    return f"{svg_text[:start_idx]}{new_tag}{svg_text[end_idx + 1:]}"


def clean_svg(path: Path, dry_run: bool = False) -> Tuple[bool, str]:
    original_text: str | None = None
    try:
        original_text = path.read_text(encoding="utf-8")
    except OSError:
        original_text = None
    try:
        tree = ET.parse(path)
    except ET.ParseError as exc:
        return False, f"{path}: parse error: {exc}"

    root = tree.getroot()
    changed = False

    if original_text:
        prolog, namespaces = extract_prolog_and_namespaces(original_text)
    else:
        prolog, namespaces = "", {}

    changed |= remove_comments(root)

    # Strip template layers and <style>/<metadata> tags.
    changed |= prune_children(root, root)

    # Drop stray attributes that only matter for the template preview.
    xml_space_keys = ["xml:space", "{http://www.w3.org/XML/1998/namespace}space"]
    for attr in xml_space_keys:
        if attr in root.attrib:
            root.attrib.pop(attr)
            changed = True

    if not changed:
        return True, "unchanged"

    if dry_run:
        return True, "would update"

    ET.indent(tree, space="  ")  # Python 3.9+

    new_text = reassemble_xml(prolog, tree)
    new_text = ensure_namespace_decls(new_text, namespaces)
    path.write_text(new_text, encoding="utf-8")
    return True, "updated"


def iter_svg_files(root: Path) -> Iterable[Path]:
    for svg in root.rglob("*.svg"):
        yield svg


def parse_args(argv: Iterable[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Clean SF Symbol template cruft from SVG assets.")
    parser.add_argument(
        "root",
        nargs="?",
        default=Path("Packages/PZWidgetsKit/Sources/PZWidgetsKit/Resources/Assets.xcassets/Icons4EmbeddedWidgets"),
        type=Path,
        help="Directory containing .svg files (defaults to Icons4EmbeddedWidgets).",
    )
    parser.add_argument("--dry-run", action="store_true", help="Scan without writing changes.")
    return parser.parse_args(list(argv))


def main(argv: Iterable[str]) -> int:
    args = parse_args(argv)
    root = args.root.resolve()
    if not root.exists():
        print(f"error: {root} does not exist", file=sys.stderr)
        return 1

    status_rows = []
    for svg_path in sorted(iter_svg_files(root)):
        ok, status = clean_svg(svg_path, args.dry_run)
        if not ok:
            print(status, file=sys.stderr)
            return 1
        status_rows.append((svg_path, status))

    for path, status in status_rows:
        rel = path.relative_to(Path.cwd()) if path.is_relative_to(Path.cwd()) else path
        print(f"{rel}: {status}")

    if not status_rows:
        print("warning: no SVG files found")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
