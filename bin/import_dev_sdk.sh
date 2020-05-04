#!/bin/sh

rm -f -r ./node_modules/react-native-zoom-bridge/ios/libs && \
mkdir -p ./node_modules/react-native-zoom-bridge/ios/libs && \
cd ./node_modules/react-native-zoom-bridge/ios/libs && \
curl -L https://github.com/zoom/zoom-sdk-ios/releases/download/v4.6.15084.0206/ios-mobilertc-all-4.6.15084.0206-n.zip > file.zip && \
unzip file.zip && \
cd lib && \
mv * ../ && \
cd ../ && \
rm file.zip && \
rm -r lib && \
rm -r MobileRTCSample