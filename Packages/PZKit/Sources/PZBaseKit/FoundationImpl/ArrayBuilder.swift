// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@resultBuilder
public enum ArrayBuilder<Element> {
    public static func buildEither(first elements: [Element]) -> [Element] {
        elements
    }

    public static func buildEither(second elements: [Element]) -> [Element] {
        elements
    }

    public static func buildOptional(_ elements: [Element]?) -> [Element] {
        elements ?? []
    }

    public static func buildExpression(_ expression: Element) -> [Element] {
        [expression]
    }

    public static func buildExpression(_: ()) -> [Element] {
        []
    }

    public static func buildBlock(_ elements: [Element]...) -> [Element] {
        elements.flatMap { $0 }
    }

    public static func buildArray(_ elements: [[Element]]) -> [Element] {
        Array(elements.joined())
    }
}
