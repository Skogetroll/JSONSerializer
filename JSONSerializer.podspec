Pod::Spec.new do |s|

  s.name         = "JSONSerializer"
  s.version      = "1.0.0"
  s.summary      = "Serializes objects to JSON"

  s.homepage     = "https://github.com/Skogetroll/JSONSerializer"

  s.license      = "MIT"

  s.author             = { "Mikhail Stepkin" => "skogetroll@gmail.com" }

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.6"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/Skogetroll/JSONSerializer.git", :tag => "#{s.version}" }

  s.source_files  = "Sources", "Sources/**/*.{h,m,swift}"

  s.requires_arc = true

  s.dependency "JSONKit", "~> 3.0"

end
