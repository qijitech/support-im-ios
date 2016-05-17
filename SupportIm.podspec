#
# Be sure to run `pod lib lint SupportIm.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SupportIm"
  s.version          = "0.1.0"
  s.summary          = "A short description of SupportIm."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = "https://github.com/<GITHUB_USERNAME>/SupportIm"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "杨玉刚" => "smartydroid@gmail.com" }
  s.source           = { :git => "https://github.com/qijitech/support-im-ios.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'SupportIm/Classes/**/*'
  s.resource_bundles = {
    'SupportIm' => ['$(SRCROOT)/SupportIm/Assets/*']
  }

  s.public_header_files = 'SupportIm/Classes/**/*.h'
  s.frameworks = 'UIKit', 'MapKit', 'MobileCoreServices', 'SystemConfiguration', 'CoreGraphics', 'AVFoundation', 'AudioToolbox'

#  s.vendored_frameworks = 'AMap2DMap/Frameworks/MAMapKit.framework', 'Pods/AMapSearch/Frameworks/AMapSearchKit.framework'

#  s.libraries = 'libz.tbd'

#  s.vendored_frameworks = 'AVOSCloud', 'AVOSCloudIM', 'AVOSCloudCrashReporting'

#  s.vendored_frameworks = 'SupportIm/Classes/MAMap/MAMapKit.framework', 'SupportIm/Classes/MAMap/AMapSearchKit.framework'

#  s.dependency 'AVOSCloud'
#  s.dependency 'AVOSCloudIM'
#  s.dependency 'AVOSCloudCrashReporting'

  s.dependency 'AVOSCloudDynamic'
  s.dependency 'AVOSCloudIMDynamic'
  s.dependency 'AVOSCloudCrashReportingDynamic'

  s.dependency 'DateTools'
  s.dependency 'Masonry'
  s.dependency 'FMDB'
  s.dependency 'SDWebImage'
  s.dependency 'MaterialControls'
  s.dependency 'MBProgressHUD'

#  s.dependency 'AMapSearch'
#  s.dependency 'AMap2DMap'

end
