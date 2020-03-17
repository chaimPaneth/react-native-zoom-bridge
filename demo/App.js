/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */

import React, { Component } from 'react';
import { Platform, StyleSheet, Text, View, Button } from 'react-native';

import ZoomUs from 'react-native-zoom-bridge';

const zoomUserType = 1; // 2 - pro user
const config = {
  zoom: {
    appKey: '', // TODO: appKey
    appSecret: '', // TODO appSecret
    domain: 'zoom.us',
  },
};

type Props = {};
export default class App extends Component<Props> {
  zakTokenRaw = ''; // TODO: meeting zak
  meetingNo = ''; // TODO: meeting number

  async componentDidMount() {
    try {
      const initializeResult = await ZoomUs.initialize(
        config.zoom.appKey,
        config.zoom.appSecret,
        config.zoom.domain,
      );
      console.warn({ initializeResult });
    } catch (e) {
      console.warn({ e });
    }
  }

  async start() {
    const zakToken = decodeURIComponent(this.zakTokenRaw);
    const displayName = 'Test mentor';

    // TODO recieve user's details from zoom API? WOUT: webinar user is different
    const userId = 'null'; // NOTE: no need for userId when using zakToken
    const userType = zoomUserType;
    const zoomToken = 'null'; // NOTE: no need for userId when using zakToken

    const zoomAccessToken = zakToken;

    try {
      const startMeetingResult = await ZoomUs.startMeeting(
        displayName,
        this.meetingNo,
        userId,
        userType,
        zoomAccessToken,
        zoomToken,
      );
      console.warn({ startMeetingResult });
    } catch (e) {
      console.warn({ e });
    }
  }

  async join() {
    const displayName = 'Test student';

    try {
      const joinMeetingResult = await ZoomUs.joinMeeting(
        displayName,
        this.meetingNo,
      );
      console.warn({ joinMeetingResult });
    } catch (e) {
      console.warn({ e });
    }
  }

  render() {
    return (
      <View style={styles.container}>
        <Button onPress={() => this.start()} title="Start example meeting" />
        <Text>-------</Text>
        <Button onPress={() => this.join()} title="Join example meeting" />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
});
