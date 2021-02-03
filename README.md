# AEPUserProfile

<!--
on [![Cocoapods](https://img.shields.io/cocoapods/v/AEPCore.svg?color=orange&label=AEPCore&logo=apple&logoColor=white)](https://cocoapods.org/pods/AEPUserprofile)
-->
[![SPM](https://img.shields.io/badge/SPM-Supported-orange.svg?logo=apple&logoColor=white)](https://swift.org/package-manager/)
[![Actions Status](https://github.com/adobe/aepsdk-userprofile-ios/workflows/build/badge.svg)](https://github.com/adobe/aepsdk-userprofile-ios/actions)
[![Code Coverage](https://img.shields.io/codecov/c/github/adobe/aepsdk-userprofile-ios/dev.svg?logo=codecov)](https://codecov.io/gh/adobe/aepsdk-userprofile-ios/branch/dev)

## BETA ACKNOWLEDGEMENT

AEPUserProfile is currently in Beta. Use of this code is by invitation only and not otherwise supported by Adobe. Please contact your Adobe Customer Success Manager to learn more.

By using the Beta, you hereby acknowledge that the Beta is provided "as is" without warranty of any kind. Adobe shall have no obligation to maintain, correct, update, change, modify or otherwise support the Beta. You are advised to use caution and not to rely in any way on the correct functioning or performance of such Beta and/or accompanying materials.

## About this project

The Adobe Experience Platform UserProfile Mobile Extension is an extension for the [Adobe Experience Platform SDK](https://github.com/Adobe-Marketing-Cloud/acp-sdks).

To learn more about this extension, read [Adobe Experience Platform Edge Mobile Extension](https://aep-sdks.gitbook.io/docs/using-mobile-extensions/profile).

## Requirements
- Xcode 11.x
- Swift 5.x

## Installation

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

```ruby
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'AEPUserProfile', :git => 'git@github.com:adobe/aepsdk-userprofile-ios.git', :branch => 'main'
    pod 'AEPCore', :git => 'git@github.com:adobe/aepsdk-core-ios.git', :branch => 'main'
    pod 'AEPServices', :git => 'git@github.com:adobe/aepsdk-core-ios.git', :branch => 'main'
    pod 'AEPRulesEngine', :git => 'git@github.com:adobe/aepsdk-rulesengine-ios.git', :branch => 'main'
end
```

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

To add the AEPUserProfile Package to your application, from the Xcode menu select:

`File > Swift Packages > Add Package Dependency...`

Enter the URL for the AEPUserProfile package repository: `https://github.com/adobe/aepsdk-userprofile-ios.git`.

When prompted, make sure you change the branch to `main`. 

Alternatively, if your project has a `Package.swift` file, you can add AEPUserProfile directly to your dependencies:

```
dependencies: [
    .package(url: "https://github.com/adobe/aepsdk-userprofile-ios.git", .branch("main")),
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
