#
#  Be sure to run `pod spec lint Consentmanager.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#
Pod::Spec.new do |spec|

  spec.name         = "consentmanager"
  spec.version      = "1.2.4"
  spec.summary      = "Provides functionality to inform the user about data protection and collect consent from the user."

  spec.description  = <<-DESC
        The ConsentManager SDK for iOS apps implements and provides functionality to inform the user about data protection and ask and collect consent from the user.
        It enables app-developers to easily integrate the ConsentManager service into their app.
                         DESC

  spec.homepage     = "https://www.consentmanager.net/"

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "Skander Ben Abdelmalak" => "s.benabdelmalak@dotben.de" }
  
  spec.platform     = :ios, "11.0"
  
  spec.source       = { :git => "https://Bitbucket.org/consentmanager/ios-consentmanager.git", :tag => "#{spec.version}" }
  spec.source_files  = "consentmanager/**/*.{h,m}"
  spec.exclude_files = "Classes/Exclude", "consentmanager/*.plist"

end