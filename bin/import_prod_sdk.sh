#!/bin/sh

rm -f -r ./node_modules/react-native-zoom-bridge/ios/libs && \
mkdir -p ./node_modules/react-native-zoom-bridge/ios/libs && \
cd ./node_modules/react-native-zoom-bridge/ios/libs && \
curl -L https://github.com/zoom/zoom-sdk-ios/archive/v4.6.21666.0428.zip > file.zip && \
unzip file.zip && \
cd zoom-sdk-ios-4.6.21666.0428/lib && \
mv * ../../ && \
cd ../../ && \
rm file.zip && \
rm -r zoom-sdk-ios-4.6.21666.0428