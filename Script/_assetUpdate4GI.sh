#!/bin/zsh

swift ./Script/GI_RawAssetsPuller.swift
# bash ./Script/convertAssetsToHEIC.sh // Disable HEIC for smaller app package, since Xcode will auto-convert HEIC to TIFF.
swift ./Script/GI_ImageAssetRegenerator.swift

# 显式清理，确保不被沙箱限制
rm -rf ./Assets/AssetTemp 2>/dev/null || true
