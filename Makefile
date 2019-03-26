.PHONY: all build test tag release clean clean-release clean-build

all: build

build:
	xcodebuild clean build \
		-scheme Pine \
		-workspace ./Pine.xcworkspace

test:
	xcodebuild \
		-scheme Pine \
		-configuration Debug test \
		-workspace ./Pine.xcworkspace

tag:
ifdef PINE_VERSION
	/usr/libexec/Plistbuddy -c "Set CFBundleShortVersionString $(PINE_VERSION)" ./Pine/Info.plist
else
	@echo 'PINE_VERSION is not set'
endif

release:
	xcodebuild archive \
		-scheme Pine \
		-workspace ./Pine.xcworkspace \
		-archivePath Release/App.xcarchive

	open Release/App.xcarchive/Products/Applications

clean: clean-release clean-build

clean-release:
	rm -r ./Release

clean-build:
	rm -r ./build
