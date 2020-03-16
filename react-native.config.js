const path = require('path');

module.exports = {
  dependency: {
    platforms: {
      ios: { podspecPath: path.join(__dirname, 'RNMobileRTC.podspec') },
      android: {
        packageImportPath: 'import com.appgoalz.RNMobileRTCPackage;',
        packageInstance: 'new RNMobileRTCPackage()',
      },
    },
  },
};
