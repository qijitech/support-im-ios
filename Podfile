#source 'https://github.com/smartydroid/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'
#use_frameworks!

inhibit_all_warnings!

workspace ‘SupportIm’

target 'Examples' do
  pod "SupportIm", :path => "."
#  pod 'StarterKit', :git => 'https://github.com/qijitech/ios-starter-kit.git', :branch => 'master'

end

xcodeproj 'Examples/Examples.xcodeproj'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ARCHS'] = 'armv7 armv7s arm64'
            config.build_settings['VALID_ARCHS'] = 'armv6 armv7 armv7s arm64'
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
        end
    end
end