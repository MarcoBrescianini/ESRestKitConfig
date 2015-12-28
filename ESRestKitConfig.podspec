Pod::Spec.new do |s|
  s.name             = "ESRestKitConfig"
  s.version          = "1.3"
  s.summary          = "RestKit plist configuration helpers"
  s.homepage         = "https://github.com/MarcoBrescianini/ESRestKitConfig"
  s.license          = 'MIT'
  s.author           = { "Marco Brescianini" => "m.brescianini85@gmail.com" }
  s.source           = { :git => "https://github.com/MarcoBrescianini/ESRestKitConfig.git", :tag => s.version }

  s.platform     = :ios, '8.0'
  s.ios.deployment_target = "8.0"
  s.requires_arc = true
  s.module_name = 'ESRestKitConfig'

  s.source_files = 'ESRestKitConfig/*.{h,m}'
  s.dependency 'RestKit'

  s.frameworks = 'SystemConfiguration', 'MobileCoreServices'
end
