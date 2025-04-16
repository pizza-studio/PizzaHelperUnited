SHELL := /bin/sh
.PHONY: format lint

# 定义日期和时间变量
DATE_DIR := $(shell date +%Y-%m-%d)
DATE_FILE := $(shell date +%Y-%-m-%-d)
TIME_FILE := $(shell date +%H.%M)
ARCHIVE_DIR := $(HOME)/Library/Developer/Xcode/Archives/$(DATE_DIR)
ARCHIVE_NAME := ThePizzaHelper-$(DATE_FILE)-$(TIME_FILE).xcarchive
ARCHIVE_PATH := $(ARCHIVE_DIR)/$(ARCHIVE_NAME)

format:
	@swiftformat --swiftversion 6.0 ./

lint:
	@git ls-files --exclude-standard | grep -E '\.swift$$' | \
	grep -Ev '(^Build/|^Packages/Build/)' | \
	swiftlint --fix --autocorrect --config .swiftlint.yml

# Archive (App Store version)

archive: archive-iOS archive-macOS

archive-iOS:
	@echo "Creating directory: $(ARCHIVE_DIR)"
	@mkdir -p "$(ARCHIVE_DIR)"
	@echo "Archiving to: $(ARCHIVE_PATH)"
	xcodebuild archive \
	-project UnitedPizzaHelper.xcodeproj \
	-scheme ThePizzaHelper \
	-configuration Release \
	-destination "generic/platform=iOS" \
	-archivePath "$(ARCHIVE_PATH)" \
	-allowProvisioningUpdates

archive-macOS:
	@echo "Creating directory: $(ARCHIVE_DIR)"
	@mkdir -p "$(ARCHIVE_DIR)"
	@echo "Archiving to: $(ARCHIVE_PATH)"
	xcodebuild archive \
	-project UnitedPizzaHelper.xcodeproj \
	-scheme ThePizzaHelper \
	-configuration Release \
	-destination "generic/platform=macOS,variant=Mac Catalyst" \
	-archivePath "$(ARCHIVE_PATH)" \
	-allowProvisioningUpdates

# Archive (United Pizza Engine)

archiveEngine: archiveEngine-iOS archiveEngine-macOS

archiveEngine-iOS:
	@echo "Creating directory: $(ARCHIVE_DIR)"
	@mkdir -p "$(ARCHIVE_DIR)"
	@echo "Archiving to: $(ARCHIVE_PATH)"
	xcodebuild archive \
	-project UnitedPizzaHelper.xcodeproj \
	-scheme UnitedPizzaHelperEngine \
	-configuration Release \
	-destination "generic/platform=iOS" \
	-archivePath "$(ARCHIVE_PATH)" \
	-allowProvisioningUpdates

archiveEngine-macOS:
	@echo "Creating directory: $(ARCHIVE_DIR)"
	@mkdir -p "$(ARCHIVE_DIR)"
	@echo "Archiving to: $(ARCHIVE_PATH)"
	xcodebuild archive \
	-project UnitedPizzaHelper.xcodeproj \
	-scheme UnitedPizzaHelperEngine \
	-configuration Release \
	-destination "generic/platform=macOS,variant=Mac Catalyst" \
	-archivePath "$(ARCHIVE_PATH)" \
	-allowProvisioningUpdates
