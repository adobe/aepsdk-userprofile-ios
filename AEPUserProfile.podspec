Pod::Spec.new do |s|
  s.name             = "AEPUserProfile"
  s.version          = "3.0.1"
  s.summary          = "Experience Platform UserProfile extension for Adobe Experience Platform Mobile SDK. Written and maintained by Adobe."
  s.description      = <<-DESC
                        The Experience Platform UserProfile extension provides APIs that allow use of the custom client-side User Profile in the Adobe Experience Platform SDK.
                        DESC
  s.homepage         = "https://github.com/adobe/aepsdk-userprofile-ios"
  s.license          = 'Apache V2'
  s.author           = "Adobe Experience Platform SDK Team"
  s.source           = { :git => "https://github.com/adobe/aepsdk-userprofile-ios", :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.swift_version    = '5.1'
  s.pod_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }
  s.dependency 'AEPCore'
  s.source_files          = 'AEPUserProfile/Sources/**/*.swift'

end
