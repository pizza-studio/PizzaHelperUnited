#!/bin/zsh

swift ./Script/HSR_RawAssetsPuller.swift
bash ./Script/convertAssetsToHEIC.sh
swift ./Script/ImageAssetRegenerator.swift
