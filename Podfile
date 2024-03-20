# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

# Comment the next line if you don't want to use dynamic frameworks
use_frameworks!

workspace 'AEPUserProfile'
project 'AEPUserProfile.xcodeproj'

pod 'SwiftLint', '0.52.0'

target 'AEPUserProfile' do
  pod 'AEPCore'
  pod 'AEPServices'
  pod 'AEPRulesEngine'
end

target 'AEPUserProfileTests' do
  pod 'AEPCore'
  pod 'AEPServices'
  pod 'AEPRulesEngine'
  pod 'AEPTestUtils', :git => 'https://github.com/adobe/aepsdk-testutils-ios.git', :tag => '5.0.0'
end

target 'AEPUserProfileE2ETests' do
  pod 'AEPCore'
  pod 'AEPServices'
  pod 'AEPRulesEngine'
  pod 'AEPTestUtils', :git => 'https://github.com/adobe/aepsdk-testutils-ios.git', :tag => '5.0.0'
end
