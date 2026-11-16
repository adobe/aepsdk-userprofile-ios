#!/bin/bash

set -e # Any subsequent(*) commands which fail will cause the shell script to exit immediately

PROJECT_NAME=Swift6Consumer

# Clean up.
rm -rf $PROJECT_NAME

mkdir -p $PROJECT_NAME/Sources/$PROJECT_NAME && cd $PROJECT_NAME

# Create the Package.swift. Tools version 6.0 is required for swiftLanguageMode, and only the consumer target uses Swift 6.
echo "// swift-tools-version:6.0
import PackageDescription
let package = Package(
    name: \"$PROJECT_NAME\",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: \"$PROJECT_NAME\", targets: [\"$PROJECT_NAME\"])
    ],
    dependencies: [
        .package(name: \"AEPUserProfile\", path: \"../\")
    ],
    targets: [
        .target(
            name: \"$PROJECT_NAME\",
            dependencies: [
                .product(name: \"AEPUserProfile\", package: \"AEPUserProfile\")
            ],
            swiftSettings: [.swiftLanguageMode(.v6)]
        )
    ]
)
" >Package.swift

# A main actor consumer calls the public completion API with plain closures, covering the success and error paths.
echo "import AEPCore
import AEPUserProfile

@MainActor
final class Swift6Consumer {
    var lastValue: String?
    var lastError: AEPError = .none

    func exercise() {
        UserProfile.updateUserAttributes(attributeDict: [\"key\": \"value\"])
        UserProfile.getUserAttributes(attributeNames: [\"key\"]) { attributes, error in
            let value = attributes?[\"key\"] as? String
            Task { @MainActor in
                self.lastValue = value
                self.lastError = error
            }
        }
        UserProfile.getUserAttributes(attributeNames: []) { _, error in
            Task { @MainActor in self.lastError = error }
        }
        UserProfile.removeUserAttributes(attributeNames: [\"key\"])
    }
}
" >Sources/$PROJECT_NAME/$PROJECT_NAME.swift

swift package resolve

echo '############# Build Swift 6 consumer for generic iOS device ###############'
xcodebuild build -scheme $PROJECT_NAME -destination 'generic/platform=iOS'

echo '############# Build Swift 6 consumer for generic iOS Simulator ###############'
xcodebuild build -scheme $PROJECT_NAME -destination 'generic/platform=iOS Simulator'

# Clean up.
cd ../
rm -rf $PROJECT_NAME
