#
# Be sure to run `pod lib lint StreamApiCore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'StreamApiCore'
  s.version          = '0.1.0'
  s.summary          = 'A short description of StreamApiCore.'

  s.description      = <<-DESC
API Client for Stream (getstream.io)
                       DESC
  s.swift_version    = '4.0'
  s.homepage         = 'https://github.com/GetStream/stream-swift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tommaso Barbugli' => 'tommaso@getstream.io' }
  s.source           = { :git => 'https://github.com/GetStream/stream-swift.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tbarbugli'

  s.ios.deployment_target = '9.3'

  s.source_files = 'StreamApiCore/Classes/**/*'
  
  # s.resource_bundles = {
  #   'StreamApiCore' => ['StreamApiCore/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'

  s.dependency 'JWTDecode', '~> 2.1'
  s.dependency 'Alamofire', '~> 4.7'
end
