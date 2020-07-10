#!/bin/sh

rm -f -r ./node_modules/react-native-zoom-bridge/android/libs && \
mkdir -p ./node_modules/react-native-zoom-bridge/android/libs && \
cd ./node_modules/react-native-zoom-bridge/android/libs && \
curl -L https://github.com/zoom/zoom-sdk-android/archive/v4.6.21666.0429.zip > file.zip && \
unzip file.zip && \
cd zoom-sdk-android-4.6.21666.0429/mobilertc-android-studio/commonlib && \
mv commonlib.aar ../../../ && \
cd ../mobilertc && \
mv mobilertc.aar ../../../ && \
cd ../../../ && \
rm file.zip && \
rm -r zoom-sdk-android-4.6.21666.0429
