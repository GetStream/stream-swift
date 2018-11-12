Pod::Spec.new do |s|
  s.name = "GetStream"
  s.version = "0.1"
  s.summary = "Swift Client - Build Activity Feeds & Streams with GetStream.io https://getstream.io"
  s.homepage = "https://github.com/GetStream/stream-swift"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "Alexey Bukhtin" => "alexey@getstream.io" }
  s.social_media_url   = ""
  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source = { :git => "https://github.com/GetStream/stream-swift.git", :tag => s.version.to_s }
  s.default_subspec = "Core"
  
  s.subspec "Core" do |ss|
    ss.source_files = "Sources/Core/**/*"
    ss.framework = "Foundation"
    ss.dependency "Moya", "~> 11.0"
    ss.dependency "Require"
    ss.dependency "Result", "~> 3.0"
  end
  
  s.subspec "Token" do |ss|
    ss.source_files = "Sources/Token/"
    ss.dependency "GetStream/Core"
    ss.dependency "SwiftyJWT"
  end
end
