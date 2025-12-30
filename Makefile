SHELL := /bin/sh
.PHONY: clean format lint

# 定义日期和时间变量
DATE_DIR := $(shell date +%Y-%m-%d)
DATE_FILE := $(shell date +%Y-%-m-%-d)
TIME_FILE := $(shell date +%H.%M)
ARCHIVE_DIR := $(HOME)/Library/Developer/Xcode/Archives/$(DATE_DIR)
ARCHIVE_NAME := ThePizzaHelper-$(DATE_FILE)-$(TIME_FILE).xcarchive
ARCHIVE_PATH := $(ARCHIVE_DIR)/$(ARCHIVE_NAME)

clean:
	@echo "Cleaning build artifacts for ThePizzaHelper..."
	@xcodebuild clean -project UnitedPizzaHelper.xcodeproj -scheme ThePizzaHelper -configuration Release
	@echo "Cleaning build artifacts for UnitedPizzaHelperEngine..."
	@xcodebuild clean -project UnitedPizzaHelper.xcodeproj -scheme UnitedPizzaHelperEngine -configuration Release
	@echo "Clean completed."

format:
	@swiftformat --swiftversion 6.0 ./

lint:
	@echo "Running SwiftLint on tracked Swift files..."
	@files="$$(git ls-files -- '*.swift' ':!Build/**' ':!Packages/Build/**' ':!Packages/**/.build/')"; \
	if [ -z "$$files" ]; then \
		echo "No Swift files tracked by git."; \
	else \
		printf '%s\n' "$$files" | tr '\n' '\0' | \
		xargs -0 swiftlint lint --fix --autocorrect --config .swiftlint.yml --; \
	fi

# Archive (App Store version - The Pizza Helper)
archive: archive-iOS archive-macOS

archive-iOS:
	@ARCHIVE_NAME=ThePizzaHelper-iOS-$(DATE_FILE)-$(TIME_FILE).xcarchive; \
	ARCHIVE_PATH=$(ARCHIVE_DIR)/$$ARCHIVE_NAME; \
	echo "Creating directory: $(ARCHIVE_DIR)"; \
	mkdir -p "$(ARCHIVE_DIR)"; \
	echo "Archiving to: $$ARCHIVE_PATH"; \
	xcodebuild archive \
		-project UnitedPizzaHelper.xcodeproj \
		-scheme ThePizzaHelper \
		-configuration Release \
		-destination "generic/platform=iOS" \
		-archivePath "$$ARCHIVE_PATH" \
		-allowProvisioningUpdates

archive-macOS:
	@ARCHIVE_NAME=ThePizzaHelper-macOS-$(DATE_FILE)-$(TIME_FILE).xcarchive; \
	ARCHIVE_PATH=$(ARCHIVE_DIR)/$$ARCHIVE_NAME; \
	echo "Creating directory: $(ARCHIVE_DIR)"; \
	mkdir -p "$(ARCHIVE_DIR)"; \
	echo "Archiving to: $$ARCHIVE_PATH"; \
	xcodebuild archive \
		-project UnitedPizzaHelper.xcodeproj \
		-scheme ThePizzaHelper \
		-configuration Release \
		-destination "generic/platform=macOS,variant=Mac Catalyst" \
		-archivePath "$$ARCHIVE_PATH" \
		-allowProvisioningUpdates

# Archive (United Pizza Engine)
archiveEngine: archiveEngine-iOS archiveEngine-macOS

archiveEngine-iOS:
	@ARCHIVE_NAME=UnitedPizzaEngine-iOS-$(DATE_FILE)-$(TIME_FILE).xcarchive; \
	ARCHIVE_PATH=$(ARCHIVE_DIR)/$$ARCHIVE_NAME; \
	echo "Creating directory: $(ARCHIVE_DIR)"; \
	mkdir -p "$(ARCHIVE_DIR)"; \
	echo "Archiving to: $$ARCHIVE_PATH"; \
	xcodebuild archive \
		-project UnitedPizzaHelper.xcodeproj \
		-scheme UnitedPizzaHelperEngine \
		-configuration Release \
		-destination "generic/platform=iOS" \
		-archivePath "$$ARCHIVE_PATH" \
		-allowProvisioningUpdates

archiveEngine-macOS:
	@ARCHIVE_NAME=UnitedPizzaEngine-macOS-$(DATE_FILE)-$(TIME_FILE).xcarchive; \
	ARCHIVE_PATH=$(ARCHIVE_DIR)/$$ARCHIVE_NAME; \
	echo "Creating directory: $(ARCHIVE_DIR)"; \
	mkdir -p "$(ARCHIVE_DIR)"; \
	echo "Archiving to: $$ARCHIVE_PATH"; \
	xcodebuild archive \
		-project UnitedPizzaHelper.xcodeproj \
		-scheme UnitedPizzaHelperEngine \
		-configuration Release \
		-destination "generic/platform=macOS,variant=Mac Catalyst" \
		-archivePath "$$ARCHIVE_PATH" \
		-allowProvisioningUpdates

# Archive (App Store version - The Latte Helper)
archiveLatte: archiveLatte-iOS archiveLatte-macOS

archiveLatte-iOS:
	@ARCHIVE_NAME=TheLatteHelper-iOS-$(DATE_FILE)-$(TIME_FILE).xcarchive; \
	ARCHIVE_PATH=$(ARCHIVE_DIR)/$$ARCHIVE_NAME; \
	echo "Creating directory: $(ARCHIVE_DIR)"; \
	mkdir -p "$(ARCHIVE_DIR)"; \
	echo "Archiving to: $$ARCHIVE_PATH"; \
	xcodebuild archive \
		-project UnitedPizzaHelper.xcodeproj \
		-scheme TheLatteHelper \
		-configuration Release \
		-destination "generic/platform=iOS" \
		-archivePath "$$ARCHIVE_PATH" \
		-allowProvisioningUpdates

archiveLatte-macOS:
	@ARCHIVE_NAME=TheLatteHelper-macOS-$(DATE_FILE)-$(TIME_FILE).xcarchive; \
	ARCHIVE_PATH=$(ARCHIVE_DIR)/$$ARCHIVE_NAME; \
	echo "Creating directory: $(ARCHIVE_DIR)"; \
	mkdir -p "$(ARCHIVE_DIR)"; \
	echo "Archiving to: $$ARCHIVE_PATH"; \
	xcodebuild archive \
		-project UnitedPizzaHelper.xcodeproj \
		-scheme TheLatteHelper \
		-configuration Release \
		-destination "generic/platform=macOS,variant=Mac Catalyst" \
		-archivePath "$$ARCHIVE_PATH" \
		-allowProvisioningUpdates