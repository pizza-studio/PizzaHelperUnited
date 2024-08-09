#!/bin/zsh

swift ./Script/GI_RawAssetsPuller.swift
bash ./Script/convertAssetsToHEIC.sh
swift ./Script/GI_ImageAssetRegenerator.swift
