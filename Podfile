source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'
inhibit_all_warnings!
use_frameworks!

link_with 'ESRestKitConfig'

pod 'RestKit', '~> 0.25.0'

target :test, :exclusive => true do
  link_with 'ESRestKitConfigTests'
  pod 'OCMock'
end
