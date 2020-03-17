require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "RNZoomUs"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  RNZoomUs
                   DESC
  s.homepage     = "https://zoom.us/"
  s.license      = "MIT"
  s.author       = package["author"]
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/chaimPaneth/react-native-zoom-bridge.git", :tag => "master" }
  
  s.source_files = "ios/**/*.{h,m}"
  s.requires_arc = true

  s.dependency "React"
end
