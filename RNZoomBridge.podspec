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
    'NSCameraUsageDescription' => 'For people to see you during meetings, we need access to your camera.',
    'NSMicrophoneUsageDescription' => 'For people to hear you during meetings, we need access to your microphone.',
    'NSPhotoLibraryUsageDescription' => 'For people to share, we need access to your photos',
    'NSBluetoothPeripheralUsageDescription' => 'We will use your Bluetooth to access your Bluetooth headphones.'
  }
end
