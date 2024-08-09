#!/bin/zsh

swift ./Script/HSR_RawAssetsPuller.swift
bash ./Script/convertAssetsToHEIC.sh
swift ./Script/HSR_ImageAssetRegenerator.swift
