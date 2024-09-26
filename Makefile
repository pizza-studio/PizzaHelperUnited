SHELL := /bin/sh
.PHONY: format lint

format:
	@swiftformat --swiftversion 6.0 ./

lint:
	@git ls-files --exclude-standard | grep -E '\.swift$$' | \
	grep -Ev '(^Build/|^Packages/Build/)' | \
	swiftlint --fix --autocorrect --config .swiftlint.yml
