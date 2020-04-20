require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "RNZoomBridge"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  RNZoomBridge
                   DESC
  s.homepage     = "https://zoom.us/"
  s.license      = "MIT"
  s.author       = package["author"]
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/chaimPaneth/react-native-zoom-bridge.git", :tag => "master" }
  s.source_files = "ios/**/*.{h,m}"
  s.requires_arc = true
  s.dependency "React"
  s.libraries = "sqlite3", "z.1.2.5", "c++"
  s.frameworks = 'VideoToolbox', "ReplayKit", "CoreBluetooth"
  s.vendored_frameworks = "ios/libs/MobileRTC.framework", "ios/libs/MobileRTCScreenShare.framework"
  s.resources = "ios/libs/MobileRTC.framework", "ios/libs/MobileRTCScreenShare.framework", "ios/libs/MobileRTCResources.bundle"
  s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"$(SRCROOT)/../node_modules/react-native-zoom-bridge/ios/libs"' }
  s.info_plist = {
    'NSCameraUsageDescription' => 'We need access to your camera so other meeting attendies can see you.',
    'NSMicrophoneUsageDescription' => 'We need access to your microphone so other meeting attendies can hear you.',
    'NSPhotoLibraryUsageDescription' => 'We need access to your photo library so you can share photos with other meeting attendies.',
    'NSBluetoothPeripheralUsageDescription' => 'We need access to your bluetooth so you can participate meetings with your bluetooth device.'
  }
end
