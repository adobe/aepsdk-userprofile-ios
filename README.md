# AEPUserProfile

[![Cocoapods](https://img.shields.io/github/v/release/adobe/aepsdk-userprofile-ios?label=Cocoapods&logo=apple&logoColor=white&color=orange&sort=semver)](https://cocoapods.org/pods/AEPUserProfile)
[![SPM](https://img.shields.io/github/v/release/adobe/aepsdk-userprofile-ios?label=SPM&logo=apple&logoColor=white&color=orange&sort=semver)](https://github.com/adobe/aepsdk-userprofile-ios/releases)
[![Build](https://github.com/adobe/aepsdk-userprofile-ios/actions/workflows/build.yml/badge.svg)](https://github.com/adobe/aepsdk-userprofile-ios/actions/workflows/build.yml)
[![Code Coverage](https://img.shields.io/codecov/c/github/adobe/aepsdk-userprofile-ios/main.svg?label=Coverage&logo=codecov)](https://codecov.io/gh/adobe/aepsdk-userprofile-ios/branch/main)

## About this project

The Adobe Experience Platform UserProfile Mobile Extension is an extension for the [Adobe Experience Platform SDK](https://github.com/Adobe-Marketing-Cloud/acp-sdks).

To learn more about this extension, read [Adobe Experience Platform Profile Mobile Extension](https://aep-sdks.gitbook.io/docs/v/AEP-Edge-Docs/).

## Requirements
- Xcode 14.1 (or newer)
- Swift 5.1 (or newer)

## Installation

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

```ruby
# Podfile

use_frameworks!

# for app development, include all the following pods
target 'YOUR_TARGET_NAME' do
    pod 'AEPCore'
    pod 'AEPUserProfile'
end

# for extension development, include AEPCore and its dependencies
target 'YOUR_TARGET_NAME' do
    pod 'AEPCore'
    pod 'AEPUserProfile'
end
```

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

To add the AEPUserProfile Package to your application, from the Xcode menu select:

`File > Swift Packages > Add Package Dependency...`

Enter the URL for the AEPUserProfile package repository: `https://github.com/adobe/aepsdk-userprofile-ios.git`.

When prompted, input a specific version or a range of versions for Version rule. 

Alternatively, if your project has a `Package.swift` file, you can add AEPUserProfile directly to your dependencies:

```
dependencies: [
    .package(url: "https://github.com/adobe/aepsdk-userprofile-ios.git", .upToNextMajor(from: "4.0.0")),
],
targets: [
    .target(name: "YourTarget",
            dependencies: ["AEPUserProfile"],
	    path: "your/path")
]
```

### Binaries

To generate an `AEPUserProfile.xcframework`, run the following command:

```
make archive
```

## Development

The first time you clone or download the project, you should run the following from the root directory to setup the environment:

~~~
make pod-install
~~~

Subsequently, you can make sure your environment is updated by running the following:

~~~
make pod-update
~~~

#### Open the Xcode workspace
Open the workspace in Xcode by running the following command from the root directory of the repository:

~~~
make open
~~~

#### Command line integration

You can run all the test suites from command line:

~~~
make test
~~~

## Contributing

Contributions are welcomed! Read the [Contributing Guide](./.github/CONTRIBUTING.md) for more information.

## Licensing

This project is licensed under the Apache V2 License. See [LICENSE](LICENSE) for more information.
