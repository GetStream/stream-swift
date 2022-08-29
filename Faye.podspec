Pod::Spec.new do |s|
  s.name = "Faye"
  s.version = "2.2.5"
  s.summary = "Faye Swift Client for GetStream"
  s.homepage = "https://github.com/GetStream/stream-swift"
  s.license = { :type => "BSD-3", :file => "LICENSE" }
  s.author = { "GetStream" => "support@getstream.io" }
  s.swift_version = "5.0"
  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "3.0"
  s.tvos.deployment_target = "9.0"
  s.source = { :git => "https://github.com/GetStream/stream-swift.git", :tag => s.version.to_s }
  s.source_files = "Faye/*"
  s.framework = "Foundation"
  s.dependency "Starscream", "~> 4.0"
end
