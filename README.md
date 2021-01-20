
# react-native-zoom-bridge

<img width="200" alt="sample" src="images/Sample.png">

React-native bridge for ZoomUs video conference calls [android](https://github.com/zoom/zoom-sdk-android) & [iOS](https://github.com/zoom/zoom-sdk-ios) SDK's (as of Jul 14, 2020 version 4.6.21666.0428)

## Getting started

`$ npm install react-native-zoom-bridge --save`

## Quick installation guide
<details><summary>Shortcut</summary>
Run

`npm i --save react-native-zoom-bridge` 

For iOS:
1. Import the SDK:
   
      *Development environment*

      `chmod +x ./node_modules/react-native-zoom-bridge/bin/import_dev_sdk.sh`

      `./node_modules/react-native-zoom-bridge/bin/import_dev_sdk.sh`

      *Production environment*

      `chmod +x ./node_modules/react-native-zoom-bridge/bin/import_prod_sdk.sh`

      `./node_modules/react-native-zoom-bridge/bin/import_prod_sdk.sh`
2. `cd ios`
3. `pod install`

Follow [Extra steps for iOS](#extra-steps-for-ios)

For Android:

`chmod +x ./node_modules/react-native-zoom-bridge/bin/import_aars.sh`

`./node_modules/react-native-zoom-bridge/bin/import_aars.sh`

Follow [Extra steps for Android](#extra-steps-for-android)

For a more detailed guide read on.
</details>

## Pre-requisites

### iOS

<details><summary>Import iOS Development SDK</summary>

run in project root

`$ chmod +x ./node_modules/react-native-zoom-bridge/bin/import_dev_sdk.sh`

`$ ./node_modules/react-native-zoom-bridge/bin/import_dev_sdk.sh`

or download the development SDK manually from [here](https://github.com/zoom/zoom-sdk-ios/releases/download/v4.6.15084.0206/ios-mobilertc-all-4.6.15084.0206-n.zip) or from the latest releases page https://github.com/zoom/zoom-sdk-ios/releases and place all contents of *lib* folder in `node_modules/react-native-zoom-bridge/ios/libs`

**When downloading the SDK manually you will have to rename the header imports in the whole SDK removing the leading `MobileRTC/` from the header imports. see [Incorrect header imports](#incorrect-header-imports)**
</details>

<details><summary>Import iOS Production SDK</summary>

run in project root

`$ chmod +x ./node_modules/react-native-zoom-bridge/bin/import_prod_sdk.sh`

`$ ./node_modules/react-native-zoom-bridge/bin/import_prod_sdk.sh`

or download the production SDK manually from [here](https://marketplace.zoom.us/docs/sdk/native-sdks/iOS/getting-started/install-sdk#install-the-zoom-sdk) or from the latest releases page https://github.com/zoom/zoom-sdk-ios/releases and place all contents of *lib* folder in `node_modules/react-native-zoom-bridge/ios/libs`

**When downloading the SDK manually you will have to rename the header imports in the whole SDK removing the leading `MobileRTC/` from the header imports. see [Incorrect header imports](#incorrect-header-imports)**
</details>

## Important Note
##### SDK-type

<details><summary>Production vs Development SDK's</summary>
There is two SDK's provided by zoom for iOS, development & production sdk's - **you will get a build fail if you run production sdk on a simulator and a compilation error when archiving the app for release if using the development sdk!**

Check out this https://marketplace.zoom.us/docs/sdk/native-sdks/iOS/getting-started/integration#5-deployment and make sure you have the correct SDK for your build. 

You can download the development sdk from here https://github.com/zoom/zoom-sdk-ios/releases/download/v4.6.15084.0206/ios-mobilertc-all-4.6.15084.0206-n.zip on the latest releases page https://github.com/zoom/zoom-sdk-ios/releases. 

Check out the description on Zoom's github page https://github.com/zoom/zoom-sdk-ios.

The issue when releasing to app store with unsupported architecture is because the development SDK works for both simulator and real device. You can work around this issue by following this answer to add script in `Build Phases` that filters out unsupported architectures: https://stackoverflow.com/questions/30547283/submit-to-app-store-issues-unsupported-architecture-x86. You may want to modify the script to be more specific, i.e. replace `'*.framework'` with `'MobileRTC.framework'`
</details>

**When downloading the SDK manually you will have to rename the header imports in the whole SDK removing the leading `MobileRTC/` from the header imports. see [Incorrect header imports](#incorrect-header-imports)**

### Android

<details><summary>Import Android aar's</summary>

run in project root

`$ chmod +x ./node_modules/react-native-zoom-bridge/bin/import_aars.sh`

`$ ./node_modules/react-native-zoom-bridge/bin/import_aars.sh`

or download the aar's manually from [here](https://marketplace.zoom.us/docs/sdk/native-sdks/android/getting-started/install-sdk#1-download-the-zoom-sdk) and take out the aar files from `/mobilertc-android-studio/mobilertc` && `/mobilertc-android-studio/commonlib` and place both (commonlib.aar && mobilertc.aar) in `node_modules/react-native-zoom-bridge/ios/libs`
</details>

## Once you have your SDK and aar's imported

Make sure they appear in their platform respective locations as follows:

iOS: `node_modules/react-native-zoom-bridge/ios/libs`

Android: `node_modules/react-native-zoom-bridge/android/libs`

you can continue to linking.

### Mostly automatic linking

On react-native versions 60+ for **ios** just `cd ios/` and `pod install` - make sure you already have the right SDK in the `libs` folder before running `pod install`

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

In order to use the latest SDK from zoom.us currently v4.6.21666.0429 you will have to set your api level to 29 and use build tools 29+ and min sdk to 21.

So make sure your settings are as follows:

```
ext {
  buildToolsVersion = "29.0.3"
  minSdkVersion = 21
  compileSdkVersion = 29
  targetSdkVersion = 29
}
```

and that you have build tools 29 installed.

#### Extra steps for iOS

1. In XCode, in your main project go to `Build Settings` tab:
* search for `Enable Bitcode` and make sure it is set to `NO`

2. In XCode, in your main project go to `Info` tab and in the following keys enter the appropriate description:
* `NSCameraUsageDescription`
* `NSMicrophoneUsageDescription`
* `NSPhotoLibraryUsageDescription`
* `NSBluetoothPeripheralUsageDescription`
* `NSBluetoothAlwaysUsageDescription`
  
## Important

#### Incorrect header imports

If you get **`'MobileRTCConstants.h' not found`** error or **`Duplicate interface definition for class 'MobileRTCSDKInitContext'`** etc, then you have to rename the headers as follows throughout the whole SDK.
Change the imports of the headers in the SDK e.g. from `<MobileRTC/MobileRTC.h>` to `<MobileRTC.h>` from `<MobileRTC/MobileRTCConstants.h>` to `<MobileRTCConstants.h>` and so on, basically you need to remove the leading `MobileRTC/` throughout the project.

You can make use of the find and replace function in XCode, find "`MobileRTC/`" and replace with nothing "" and recompile.

You should only have to do this if you manually download the SDK otherwise the import script in this library should do that for you.

### Manual installation

#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-zoom-bridge` and add `RNZoomBridge.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNZoomBridge.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<
5. In XCode, in your main project go to `General` tab, expand `Linked Frameworks and Libraries` and add the following libraries:
   * `libsqlite3.tbd`
   * `libc++.tbd`
   * `libz.1.2.5.tbd`
   * `CoreBluetooth`
   * `VideoToolbox`
   * `ReplayKit`
6. In XCode, in your main project go to `General` tab, expand `Linked Frameworks and Libraries` and add `MobileRTC.framework`:
   * choose `Add other...`
   * navigate to `../node_modules/react-native-zoom-bridge/ios/libs`
   * choose `MobileRTC.framework`
7. In XCode, in your main project go to `General` tab, expand `Embedded Binaries` and add `MobileRTC.framework` from the list - should be at `Frameworks`.
8. In XCode, in your main project go to `Build Phases` tab, expand `Copy Bundle Resources` and add `MobileRTCResources.bundle`:
   * choose `Add other...`
   * navigate to `../node_modules/react-native-zoom-bridge/ios/libs`
   * choose `MobileRTCResources.bundle`
   * choose `Create folder references` and uncheck `Copy files if needed`
Note: if you do not have `Copy Bundle Resources` you can add it by clicking on top-left `+` sign
9. In XCode, in your main project go to `Build Settings` tab:
   * search for `Framework Search Paths` and add `$(SRCROOT)/../node_modules/react-native-zoom-bridge/ios/libs` with `non-recursive`
10. Follow [Extra steps for iOS](#extra-steps-for-ios)

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.appgolaz.reactnative.RNZoomBridgePackage;` to the imports at the top of the file
  - Add `new RNZoomBridgePackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-zoom-bridge'
  	project(':react-native-zoom-bridge').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-zoom-bridge/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      implementation project(':react-native-zoom-bridge')
  	```
4. Follow [Extra steps for Android](#extra-steps-for-android)

## Usage

```javascript
import ZoomBridge from 'react-native-zoom-bridge';

await ZoomBridge.initialize(
  config.zoom.appKey,
  config.zoom.appSecret,
  config.zoom.domain
);

// Start Meeting
await ZoomBridge.startMeeting(
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
await ZoomBridge.joinMeeting(
  displayName,
  meetingNo
);

// OR Join Meeting with password
await ZoomBridge.joinMeetingWithPassword(
  displayName,
  meetingNo,
  'Enter password here'
);
```

#### [CHANGELOG](https://github.com/chaimPaneth/react-native-zoom-bridge/releases)

#### Important before archiving a build for the App Store

See issue https://github.com/chaimPaneth/react-native-zoom-bridge/issues/24.

As of now this library isn't using MobileRTCScreenShare.framework and we need to delete this after downloading the sdk's otherwise you will get an error as below:

```[Transporter Error Output]: ERROR ITMS-90635: "Invalid Mach-O Format. The Mach-O in bundle "appname.app/Frameworks/MobileRTCScreenShare.framework" isn’t consistent with the Mach-O in the main bundle. The main bundle Mach-O contains arm64(machine code), while the nested bundle Mach-O contains armv7(machine code) and arm64(machine code). Verify that all of the targets for a platform have a consistent value for the ENABLE_BITCODE build setting."

[Transporter Error Output]: ERROR ITMS-90171: "Invalid Bundle Structure - The binary file 'appname.app/Frameworks/MobileRTCScreenShare.framework/MobileRTCScreenShare' is not permitted. Your app can’t contain standalone executables or libraries, other than a valid CFBundleExecutable of supported bundles. Refer to the Bundle Programming Guide at https://developer.apple.com/go/?id=bundle-structure for information on the iOS app bundle structure."

[Transporter Error Output]: ERROR ITMS-90362: "Invalid Info.plist value. The value for the key 'MinimumOSVersion' in bundle appname.app/Frameworks/MobileRTCScreenShare.framework is invalid. The minimum value is 8.0"

[Transporter Error Output]: ERROR ITMS-90124: "The binary is invalid. The executable 'appname.app/Frameworks/MobileRTCScreenShare.framework/MobileRTCScreenShare' has type 'OBJECT' that is not valid. Only 'EXECUTE' is permitted."

[Transporter Error Output]: ERROR ITMS-90125: "The binary is invalid. The encryption info in the LC_ENCRYPTION_INFO load command is either missing or invalid, or the binary is already encrypted. This binary does not seem to have been built with Apple's linker."

[Transporter Error Output]: ERROR ITMS-90210: "Missing load commands. The executable at 'appname.app/Frameworks/MobileRTCScreenShare.framework' does not have the necessary load commands. Try rebuilding the app with the latest Xcode version. If you are using third party development tools, contact the provider."
```

After running the production SDK import script go to `node_modules/react-native-zoom-bridge/ios/libs` and delete `MobileRTCScreenShare.framework` then run `pod install` and only then prepare your archive for the App Store.
