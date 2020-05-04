#!/bin/sh

rm -f -r ./node_modules/react-native-zoom-bridge/android/libs && \
mkdir -p ./node_modules/react-native-zoom-bridge/android/libs && \
cd ./node_modules/react-native-zoom-bridge/android/libs && \
curl -L https://github.com/zoom/zoom-sdk-android/archive/master.zip > file.zip && \
unzip file.zip && \
cd zoom-sdk-android-master/mobilertc-android-studio/commonlib && \
mv commonlib.aar ../../../ && \
cd ../mobilertc && \
mv mobilertc.aar ../../../ && \
cd ../../../ && \
rm file.zip && \
rm -r zoom-sdk-android-master
