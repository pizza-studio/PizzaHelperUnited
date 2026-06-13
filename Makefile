SHELL := /bin/sh
.PHONY: clean gitclean format lint archive

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

gitclean:
	git clean -ffdx

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

# Interactive archive target
archive:
	@echo "========================================"; \
	echo "  請選擇要封存的目標 App："; \
	echo "========================================"; \
	echo "  1) The Latte Helper  (Latte)"; \
	echo "  2) The Pizza Helper  (Pizza)"; \
	echo "  3) United Pizza Engine (Engine)"; \
	echo "========================================"; \
	printf "請輸入數字 (1/2/3): "; \
	read app_choice; \
	case "$$app_choice" in \
		1|Latte|latte) APP=Latte ;; \
		2|Pizza|pizza) APP=Pizza ;; \
		3|Engine|engine) APP=Engine ;; \
		*) echo "❌ 無效的選擇：$$app_choice"; exit 1 ;; \
	esac; \
	echo ""; \
	echo "========================================"; \
	echo "  請選擇目標平台："; \
	echo "========================================"; \
	echo "  1) iOS"; \
	echo "  2) macOS"; \
	echo "========================================"; \
	printf "請輸入數字 (1/2): "; \
	read os_choice; \
	case "$$os_choice" in \
		1|iOS|ios) OS=iOS ;; \
		2|macOS|macos) OS=macOS ;; \
		*) echo "❌ 無效的選擇：$$os_choice"; exit 1 ;; \
	esac; \
	echo ""; \
	echo "→ 即將執行：make archive$$APP-$$OS"; \
	echo ""; \
	$(MAKE) "archive$$APP-$$OS"

# Archive (App Store version - The Pizza Helper)
archivePizza: archivePizza-iOS archivePizza-macOS

archivePizza-iOS:
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

archivePizza-macOS:
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