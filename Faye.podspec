Pod::Spec.new do |s|
  s.name = "Faye"
  s.version = "0.1.0"
  s.summary = "Faye Swift Client for GetStream"
  s.homepage = "https://github.com/GetStream/stream-swift"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "Alexey Bukhtin" => "alexey@getstream.io" }
  s.social_media_url   = ""
  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source = { :git => "https://github.com/GetStream/stream-swift.git", :tag => s.version.to_s }
  s.source_files = "Faye/"
  s.dependency "Starscream"
end
