
# react-native-zoom-bridge

This is a minimum bridge of https://github.com/zoom/zoom-sdk-android and https://github.com/zoom/zoom-sdk-ios

Tested on XCode 9.4.1 and node 10.14.1.

Pull requests are welcome.

## Getting started

`$ npm install react-native-zoom-bridge`

## Important

### iOS
Go to zoom.us and download the [SDK for iOS](https://marketplace.zoom.us/docs/sdk/native-sdks/android/getting-started/install-sdk#1-download-the-zoom-sdk)

#### Note

There is two SDK's provided by zoom, 1 for development and one for production, check out this https://marketplace.zoom.us/docs/sdk/native-sdks/iOS/getting-started/integration#5-deployment and make sure you have the correct SDK for your build. You can download the development sdk from here https://github.com/zoom/zoom-sdk-ios/releases/download/v4.6.15084.0206/ios-mobilertc-all-4.6.15084.0206-n.zip on the latest releases page https://github.com/zoom/zoom-sdk-ios/releases. Check out the description on Zoom's github page https://github.com/zoom/zoom-sdk-ios.

### Android
Go to zoom.us and download the [arr files for android](https://marketplace.zoom.us/docs/sdk/native-sdks/android/getting-started/install-sdk#1-download-the-zoom-sdk) and take out the arr files from `/mobilertc-android-studio/mobilertc` && `/mobilertc-android-studio/commonlib`

Place them in their platform respective locations, (Create the `libs` folder).

iOS: `node_modules/react-native-zoom-bridge/ios/libs`

Android: `node_modules/react-native-zoom-bridge/android/libs`

For `iOS` when building for development make sure to put in the development sdk otherwise you will get a build error see number [8.](#8) below

### Mostly automatic installation

On react-native versions 60+ for *ios* just `cd ios/` and `pod install`

for lower react-native versions run `$ react-native link react-native-zoom-bridge`

#### Extra steps for Android

Since Zoom SDK `*.aar` libraries are not globally distributed
it is also required to manually go to your project's `android/build.gradle` and under `allprojects.repositories` add the following:
```gradle
allprojects {
    repositories {
        flatDir {
            dirs "$rootDir/../node_modules/react-native-zoom-bridge/android/libs"
        }
        ...
    }
    ...
}
```

If you have problem with multiDex go to your project's `android/app/build.gradle` and under `android.defaultSettings` add the following:
```gradle
android {
    defaultConfig {
        multiDexEnabled true
        ...
    }
    ...
}
```

Note: In `android/app/build.gradle` I tried to set up `compile project(':react-native-zoom-bridge')` with `transitive=false`
and it compiled well, but the app then crashes after running with initialize/meeting listener.
So the above solution seems to be the best for now.

#### Extra steps for iOS

1. In XCode, in your main project go to `General` tab, expand `Linked Frameworks and Libraries` and add the following libraries:
* `libsqlite3.tbd`
* `libc++.tbd`
* `libz.1.2.5.tbd`
* `CoreBluetooth`
* `VideoToolbox`
* `ReplayKit`

2. In XCode, in your main project go to `General` tab, expand `Linked Frameworks and Libraries` and add `MobileRTC.framework`:
* choose `Add other...`
* navigate to `../node_modules/react-native-zoom-bridge/ios/libs`
* choose `MobileRTC.framework`

3. In XCode, in your main project go to `General` tab, expand `Embedded Binaries` and add `MobileRTC.framework` from the list - should be at `Frameworks`.

4. In XCode, in your main project go to `Build Phases` tab, expand `Copy Bundle Resources` and add `MobileRTCResources.bundle`:
* choose `Add other...`
* navigate to `../node_modules/react-native-zoom-bridge/ios/libs`
* choose `MobileRTCResources.bundle`
* choose `Create folder references` and uncheck `Copy files if needed`
Note: if you do not have `Copy Bundle Resources` you can add it by clicking on top-left `+` sign

5. In XCode, in your main project go to `Build Settings` tab:
* search for `Framework Search Paths` and add `$(SRCROOT)/../node_modules/react-native-zoom-bridge/ios/libs` with `non-recursive`

6. In XCode, in your main project go to `Build Settings` tab:
* search for `Enable Bitcode` and make sure it is set to `NO`

7. In XCode, in your main project go to `Info` tab and add the following keys with appropriate description:
* `NSCameraUsageDescription`
* `NSMicrophoneUsageDescription`
* `NSPhotoLibraryUsageDescription`
* `NSBluetoothPeripheralUsageDescription`

8. Because this package includes Zoom SDK that works for both simulator and real device, when releasing to app store you may encounter problem with unsupported architecure. Please follow this answer to add script in `Build Phases` that filters out unsupported architectures: https://stackoverflow.com/questions/30547283/submit-to-app-store-issues-unsupported-architecture-x86. You may want to modify the script to be more specific, i.e. replace `'*.framework'` with `'MobileRTC.framework'`.
  
## Important

9. You might have to fix the imports of the headers in the SDK e.g. from `<MobileRCT/MobileRCT.h>` to `<MobileRCT.h>` from `<MobileRCT/MobileRCTConstants.h>` to `<MobileRCTConstants.h>`, if you get `'MobileRCT/MobileRCTConstants.h' not found` error then you have to rename the headers as follows throughout the whole SDK.

### Manual installation

#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-zoom-bridge` and add `RNZoomUs.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNZoomUs.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<
5. Follow [Mostly automatic installation-> Extra steps for iOS](#extra-steps-for-ios)

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.appgolaz.reactnative.RNZoomUsPackage;` to the imports at the top of the file
  - Add `new RNZoomUsPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-zoom-bridge'
  	project(':react-native-zoom-bridge').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-zoom-bridge/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-zoom-bridge')
  	```
4. Follow [Mostly automatic installation-> Extra steps for Android](#extra-steps-for-android)


## Usage
```javascript
import ZoomUs from 'react-native-zoom-bridge';

await ZoomUs.initialize(
  config.zoom.appKey,
  config.zoom.appSecret,
  config.zoom.domain
);

// Start Meeting
await ZoomUs.startMeeting(
  displayName,
  meetingNo,
  userId, // can be 'null'?
  userType, // for pro user use 2
  zoomAccessToken, // zak token
  zoomToken // can be 'null'?

  // NOTE: userId, userType, zoomToken should be taken from user hosting this meeting (not sure why it is required)
  // But it works with putting only zoomAccessToken
);

// OR Join Meeting
await ZoomUs.joinMeeting(
  displayName,
  meetingNo
);
```

## Example
Go inside `demo` folder and run:
```bash
yarn & yarn start
```
