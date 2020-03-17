const path = require('path');

module.exports = {
  dependency: {
    platforms: {
      ios: { podspecPath: path.join(__dirname, "RNZoomUs.podspec") },
      android: {
        packageImportPath: "import com.appgolaz.reactnative.RNZoomUsPackage;",
        packageInstance: "new RNZoomUsPackage()"
      }
    }
  }
};
