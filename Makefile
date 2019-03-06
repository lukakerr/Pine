.PHONY: all build test release clean clean-release clean-build

all: build

build:
	xcodebuild clean build \
		-scheme Twig \
		-workspace ./Twig.xcworkspace

test:
	xcodebuild \
		-scheme Twig \
		-configuration Debug test \
		-workspace ./Twig.xcworkspace

release:
	xcodebuild archive \
		-scheme Twig \
		-workspace ./Twig.xcworkspace \
		-archivePath Release/App.xcarchive

	open Release/App.xcarchive/Products/Applications

clean: clean-release clean-build

clean-release:
	rm -r ./Release

clean-build:
	rm -r ./build
