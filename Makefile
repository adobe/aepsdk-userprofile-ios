export EXTENSION_NAME = AEPUserProfile
PROJECT_NAME = $(EXTENSION_NAME)

lint-autocorrect:
	swiftlint autocorrect

lint:
	swiftlint lint

check-format:
	swiftformat --lint AEPUserProfile/Sources
	
format:
	swiftformat .

generate-lcov:
	xcrun llvm-cov export -format="lcov" .build/debug/AEPRulesEnginePackageTests.xctest/Contents/MacOS/AEPRulesEnginePackageTests -instr-profile .build/debug/codecov/default.profdata > info.lcov

pod-install:
	(pod install --repo-update)

pod-repo-update:
	(pod repo update)

pod-update: pod-repo-update
	(pod update)

clean:
	(rm -rf build)

test:
	@echo "######################################################################"
	@echo "### Testing iOS"
	@echo "######################################################################"
	xcodebuild test -workspace $(PROJECT_NAME).xcworkspace -scheme $(PROJECT_NAME)Tests -destination 'platform=iOS Simulator,name=iPhone 11 Pro' -derivedDataPath build/out -enableCodeCoverage YES