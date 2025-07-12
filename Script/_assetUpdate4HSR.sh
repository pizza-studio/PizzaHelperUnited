#!/bin/zsh

swift ./Script/HSR_RawAssetsPuller.swift
# bash ./Script/convertAssetsToHEIC.sh // Disable HEIC for smaller app package, since Xcode will auto-convert HEIC to TIFF.
swift ./Script/HSR_ImageAssetRegenerator.swift
