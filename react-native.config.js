const path = require('path');

module.exports = {
  dependency: {
    platforms: {
      ios: { podspecPath: path.join(__dirname, "RNZoomBridge.podspec") },
      android: {
        packageImportPath: "import com.appgoalz.reactnative.RNZoomBridgePackage;",
        packageInstance: "new RNZoomBridgePackage()"
      }
    }
  }
};
