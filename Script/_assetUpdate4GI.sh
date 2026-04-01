#!/bin/zsh

swift ./Script/GI_RawAssetsPuller.swift
# bash ./Script/convertAssetsToHEIC.sh // Disable HEIC for smaller app package, since Xcode will auto-convert HEIC to TIFF.
swift ./Script/GI_ImageAssetRegenerator.swift
