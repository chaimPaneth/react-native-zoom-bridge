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
sed -i.bak 's/\#import <MobileRTC\//\#import </g' ./MobileRTC.framework/Headers/MobileRTC.h
sed -i.bak 's/\#import <MobileRTC\//\#import </g' ./MobileRTC.framework/Headers/MobileRTCMeetingService+AppShare.h
sed -i.bak 's/\#import <MobileRTC\//\#import </g' ./MobileRTC.framework/Headers/MobileRTCMeetingService+Audio.h
sed -i.bak 's/\#import <MobileRTC\//\#import </g' ./MobileRTC.framework/Headers/MobileRTCMeetingService+Chat.h
sed -i.bak 's/\#import <MobileRTC\//\#import </g' ./MobileRTC.framework/Headers/MobileRTCMeetingService+Customize.h
sed -i.bak 's/\#import <MobileRTC\//\#import </g' ./MobileRTC.framework/Headers/MobileRTCMeetingService+inMeeting.h
sed -i.bak 's/\#import <MobileRTC\//\#import </g' ./MobileRTC.framework/Headers/MobileRTCMeetingService+User.h
sed -i.bak 's/\#import <MobileRTC\//\#import </g' ./MobileRTC.framework/Headers/MobileRTCMeetingService+Video.h
sed -i.bak 's/\#import <MobileRTC\//\#import </g' ./MobileRTC.framework/Headers/MobileRTCMeetingService+VirtualBackground.h
sed -i.bak 's/\#import <MobileRTC\//\#import </g' ./MobileRTC.framework/Headers/MobileRTCMeetingService+Webinar.h
sed -i.bak 's/\#import <MobileRTC\//\#import </g' ./MobileRTC.framework/Headers/MobileRTCMeetingService+BO.h