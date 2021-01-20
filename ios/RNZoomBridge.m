
#import "RNZoomBridge.h"

@implementation RNZoomBridge
{
  BOOL isInitialized;
  RCTPromiseResolveBlock initializePromiseResolve;
  RCTPromiseRejectBlock initializePromiseReject;
  RCTPromiseResolveBlock meetingPromiseResolve;
  RCTPromiseRejectBlock meetingPromiseReject;
  RCTPromiseResolveBlock premeetingPromiseResolve;
  RCTPromiseRejectBlock premeetingPromiseReject;
}

- (instancetype)init {
  if (self = [super init]) {
    isInitialized = NO;
    initializePromiseResolve = nil;
    initializePromiseReject = nil;
    meetingPromiseResolve = nil;
    meetingPromiseReject = nil;
    premeetingPromiseResolve = nil;
    premeetingPromiseReject = nil;
  }
  return self;
}

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(
  initialize: (NSString *)appKey
  withAppSecret: (NSString *)appSecret
  withWebDomain: (NSString *)webDomain
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  if (isInitialized) {
    resolve(@"Already initialize Zoom SDK successfully.");
    return;
  }

  isInitialized = true;

  @try {
    initializePromiseResolve = resolve;
    initializePromiseReject = reject;

    [[MobileRTC sharedRTC] setMobileRTCDomain:webDomain];

    MobileRTCAuthService *authService = [[MobileRTC sharedRTC] getAuthService];
    if (authService)
    {
      authService.delegate = self;

      authService.clientKey = appKey;
      authService.clientSecret = appSecret;

      [authService sdkAuth];
    } else {
      NSLog(@"onZoomSDKInitializeResult, no authService");
    }
      
    MobileRTCPremeetingService *premeetingSevice = [[MobileRTC sharedRTC] getPreMeetingService];
    if (premeetingSevice)
    {
      premeetingSevice.delegate = self;
    } else {
      NSLog(@"onZoomSDKInitializeResult, no premeetingSevice");
    }
  } @catch (NSError *ex) {
      reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing initialize", ex);
  }
}

RCT_EXPORT_METHOD(
  startMeeting: (NSString *)displayName
  withMeetingNo: (NSString *)meetingNo
  withUserId: (NSString *)userId
  withUserType: (NSInteger)userType
  withZoomAccessToken: (NSString *)zoomAccessToken
  withZoomToken: (NSString *)zoomToken
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  @try {
    meetingPromiseResolve = resolve;
    meetingPromiseReject = reject;

    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (ms) {
      ms.delegate = self;

      MobileRTCMeetingStartParam4WithoutLoginUser * params = [[MobileRTCMeetingStartParam4WithoutLoginUser alloc]init];
      params.userName = displayName;
      params.meetingNumber = meetingNo;
      params.userID = userId;
      params.userType = (MobileRTCUserType)userType;
      params.zak = zoomAccessToken;
      params.userToken = zoomToken;

      MobileRTCMeetError startMeetingResult = [ms startMeetingWithStartParam:params];
      NSLog(@"startMeeting, startMeetingResult=%d", startMeetingResult);
    }
  } @catch (NSError *ex) {
      reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing startMeeting", ex);
  }
}

RCT_EXPORT_METHOD(
  joinMeeting: (NSString *)displayName
  withMeetingNo: (NSString *)meetingNo
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  @try {
    meetingPromiseResolve = resolve;
    meetingPromiseReject = reject;

    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (ms) {
      ms.delegate = self;

      NSDictionary *paramDict = @{
        kMeetingParam_Username: displayName,
        kMeetingParam_MeetingNumber: meetingNo
      };

      MobileRTCMeetError joinMeetingResult = [ms joinMeetingWithDictionary:paramDict];
      NSLog(@"joinMeeting, joinMeetingResult=%d", joinMeetingResult);
    }
  } @catch (NSError *ex) {
      reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing joinMeeting", ex);
  }
}

RCT_EXPORT_METHOD(
    joinMeetingWithPassword: (NSString *)displayName
    withMeetingNo: (NSString *)meetingNo
    withPassword: (NSString *)password
    withResolve: (RCTPromiseResolveBlock)resolve
    withReject: (RCTPromiseRejectBlock)reject
)
{
    @try {
      meetingPromiseResolve = resolve;
      meetingPromiseReject = reject;
    
      MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
      if (ms) {
        ms.delegate = self;
    
        NSDictionary *paramDict = @{
          kMeetingParam_Username: displayName,
          kMeetingParam_MeetingNumber: meetingNo,
          kMeetingParam_MeetingPassword: password
        };
        
        MobileRTCMeetError joinMeetingResult = [ms joinMeetingWithDictionary:paramDict];
        NSLog(@"joinMeeting, joinMeetingResult=%d", joinMeetingResult);
      }
    } @catch (NSError *ex) {
        reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing joinMeeting", ex);
    }
}

- (void)onMobileRTCAuthReturn:(MobileRTCAuthError)returnValue {
  NSLog(@"nZoomSDKInitializeResult, errorCode=%d", returnValue);
  if(returnValue != MobileRTCAuthError_Success) {
    initializePromiseReject(
      @"ERR_ZOOM_INITIALIZATION",
      [NSString stringWithFormat:@"Error: %d", returnValue],
      [NSError errorWithDomain:@"us.zoom.sdk" code:returnValue userInfo:nil]
    );
  } else {
    initializePromiseResolve(@"Initialize Zoom SDK successfully.");
  }
}

- (void)onMeetingReturn:(MobileRTCMeetError)errorCode internalError:(NSInteger)internalErrorCode {
  NSLog(@"onMeetingReturn, error=%d, internalErrorCode=%zd", errorCode, internalErrorCode);

  if (!meetingPromiseResolve) {
    return;
  }

  if (errorCode != MobileRTCMeetError_Success) {
    meetingPromiseReject(
      @"ERR_ZOOM_MEETING",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%zd", errorCode, internalErrorCode],
      [NSError errorWithDomain:@"us.zoom.sdk" code:errorCode userInfo:nil]
    );
  } else {
    meetingPromiseResolve(@"Connected to zoom meeting");
  }

  meetingPromiseResolve = nil;
  meetingPromiseReject = nil;
}

- (void)onMeetingStateChange:(MobileRTCMeetingState)state {
  NSLog(@"onMeetingStatusChanged, meetingState=%d", state);

  if (state == MobileRTCMeetingState_InMeeting || state == MobileRTCMeetingState_Idle) {
    if (!meetingPromiseResolve) {
      return;
    }

    meetingPromiseResolve(@"Connected to zoom meeting");

    meetingPromiseResolve = nil;
    meetingPromiseReject = nil;
  }
}

- (void)onMeetingError:(MobileRTCMeetError)errorCode message:(NSString *)message {
  NSLog(@"onMeetingError, errorCode=%d, message=%@", errorCode, message);

  if (!meetingPromiseResolve) {
    return;
  }

  meetingPromiseReject(
    @"ERR_ZOOM_MEETING",
    [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", errorCode, message],
    [NSError errorWithDomain:@"us.zoom.sdk" code:errorCode userInfo:nil]
  );

  meetingPromiseResolve = nil;
  meetingPromiseReject = nil;
}

#pragma mark - Settings API methods

// Auto connect

RCT_EXPORT_METHOD(
  isAutoConnected:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    BOOL isAutoConnected = [settings autoConnectInternetAudio];
    resolve([NSNumber numberWithBool:isAutoConnected]);
  }
}

RCT_EXPORT_METHOD(
  setAutoConnected: (BOOL*)autoConnect
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    [settings setAutoConnectInternetAudio:autoConnect];
    resolve(@"Successfully set auto connect");
  }
}

// Audio mute

RCT_EXPORT_METHOD(
  isAudioMuted:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    BOOL isAudioMuted = [settings muteAudioWhenJoinMeeting];
    resolve([NSNumber numberWithBool:isAudioMuted]);
  }
}

RCT_EXPORT_METHOD(
  setAudioMute: (BOOL*)audioMute
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    [settings setMuteAudioWhenJoinMeeting:audioMute];
    resolve(@"Successfully set audio mute");
  }
}

// Video mute

RCT_EXPORT_METHOD(
  isVideoMuted:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    BOOL isVideoMuted = [settings muteVideoWhenJoinMeeting];
    resolve([NSNumber numberWithBool:isVideoMuted]);
  }
}

RCT_EXPORT_METHOD(
  setVideoMute: (BOOL*)videoMute
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    [settings setMuteVideoWhenJoinMeeting:videoMute];
    resolve(@"Successfully set video mute");
  }
}

// Drive mode

RCT_EXPORT_METHOD(
  driveModeDisabled:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    BOOL disabled = [settings driveModeDisabled];
    resolve([NSNumber numberWithBool:disabled]);
  }
}

RCT_EXPORT_METHOD(
  disableDriveMode: (BOOL*)driveMode
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    [settings disableDriveMode:driveMode];
    resolve(@"Successfully set drive mode");
  }
}

// Call in

RCT_EXPORT_METHOD(
  disabledCallIn:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    BOOL disabledCallIn = [settings callInDisabled];
    resolve([NSNumber numberWithBool:disabledCallIn]);
  }
}

RCT_EXPORT_METHOD(
  disableCallIn: (BOOL*)disabled
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    [settings disableCallIn:disabled];
    resolve(@"Successfully set call in");
  }
}

// Call out

RCT_EXPORT_METHOD(
  disabledCallOut:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    BOOL disabledCallOut = [settings callOutDisabled];
    resolve([NSNumber numberWithBool:disabledCallOut]);
  }
}

RCT_EXPORT_METHOD(
  disableCallOut: (BOOL*)disabled
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    [settings disableCallOut:disabled];
    resolve(@"Successfully set call out");
  }
}

// Thumbnail in share

RCT_EXPORT_METHOD(
  thumbnailInShare:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    BOOL thumbnailInShare = [settings thumbnailInShare];
    resolve([NSNumber numberWithBool:thumbnailInShare]);
  }
}

RCT_EXPORT_METHOD(
  setThumbnailInShare: (BOOL*)hidden
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    [settings setThumbnailInShare:hidden];
    resolve(@"Successfully set thumbnail");
  }
}

// Custom meeting

RCT_EXPORT_METHOD(
  enableCustomMeeting:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    BOOL enableCustomMeeting = [settings enableCustomMeeting];
    resolve([NSNumber numberWithBool:enableCustomMeeting]);
  }
}

RCT_EXPORT_METHOD(
  setEnableCustomMeeting: (BOOL*)enable
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    [settings setEnableCustomMeeting:enable];
    resolve(@"Successfully set custom meeting");
  }
}

RCT_EXPORT_METHOD(
  setMeetingTitleHidden: (BOOL)hidden
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    settings.meetingTitleHidden = hidden;
    resolve(@"Successfully set meeting title hidden");
  }
}

RCT_EXPORT_METHOD(
  setMeetingPasswordHidden: (BOOL)hidden
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    settings.meetingPasswordHidden = hidden;
    resolve(@"Successfully set meeting password hidden");
  }
}

RCT_EXPORT_METHOD(
  setTopBarHidden: (BOOL)hidden
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    settings.topBarHidden = hidden;
    resolve(@"Successfully set top bar hidden");
  }
}

RCT_EXPORT_METHOD(
  setBottomBarHidden: (BOOL)hidden
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    settings.bottomBarHidden = hidden;
    resolve(@"Successfully set bottom bar hidden");
  }
}

// Show/Hide Leave Meeting Button

RCT_EXPORT_METHOD(
  setMeetingLeaveHidden: (BOOL)hidden
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    settings.meetingLeaveHidden = hidden;
    resolve(@"Successfully set meeting leave hidden");
  }
}

// Show/Hide Audio Button

RCT_EXPORT_METHOD(
  setMeetingAudioHidden: (BOOL)hidden
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    settings.meetingAudioHidden = hidden;
    resolve(@"Successfully set meeting audio hidden");
  }
}

// Show/Hide Video Button

RCT_EXPORT_METHOD(
  setMeetingVideoHidden: (BOOL)hidden
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    settings.meetingVideoHidden = hidden;
    resolve(@"Successfully set meeting video hidden");
  }
}

// Show/Hide Invite Button

RCT_EXPORT_METHOD(
  setMeetingInviteHidden: (BOOL)hidden
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    settings.meetingInviteHidden = hidden;
    resolve(@"Successfully set meeting invite hidden");
  }
}

// Show/Hide Participant Button

RCT_EXPORT_METHOD(
  setMeetingParticipantHidden: (BOOL)hidden
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    settings.meetingParticipantHidden = hidden;
    resolve(@"Successfully set meeting participant hidden");
  }
}

// Show/Hide Share Button

RCT_EXPORT_METHOD(
  setMeetingShareHidden: (BOOL)hidden
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    settings.meetingShareHidden = hidden;
    resolve(@"Successfully set meeting share hidden");
  }
}

// Show/Hide More Button

RCT_EXPORT_METHOD(
  setMeetingMoreHidden: (BOOL)hidden
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
  if (!settings) {
    reject(
      @"ERR_ZOOM_SETTINGS",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get settings."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    settings.meetingMoreHidden = hidden;
    resolve(@"Successfully set meeting more hidden");
  }
}

#pragma mark - Service API methods

// Meeting title

RCT_EXPORT_METHOD(
  customizeMeetingTitle: (NSString*)title
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    [service customizeMeetingTitle:title];
    resolve(@"Successfully set meeting title");
  }
}

// Meeting host

RCT_EXPORT_METHOD(
  isMeetingHost:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    BOOL isMeetingHost = [service isMeetingHost];
    resolve([NSNumber numberWithBool:isMeetingHost]);
  }
}

// My meeting audio

RCT_EXPORT_METHOD(
  connectMyAudio: (BOOL*)connect
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    [service connectMyAudio:connect];
    resolve(@"Successfully set connect audio");
  }
}

RCT_EXPORT_METHOD(
  switchMyAudioSource:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
      @try {
          [service switchMyAudioSource];
          resolve(@"Successfully switched audio");
      } @catch (NSError *ex) {
          reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing switchMyAudioSource", ex);
      }
  }
}

RCT_EXPORT_METHOD(
  isMyAudioMuted:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    BOOL isMyAudioMuted = [service isMyAudioMuted];
    resolve([NSNumber numberWithBool:isMyAudioMuted]);
  }
}

RCT_EXPORT_METHOD(
  muteMyAudio: (BOOL*)mute
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    if (!mute && ![service canUnmuteMyAudio]) {
      reject(
        @"ERR_ZOOM_SERVICE",
        [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot unmute your audio."],
        [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
      );
      return;
    }
    [service muteMyAudio:mute];
    resolve(@"Successfully set meeting audio");
  }
}

// My meeting video

RCT_EXPORT_METHOD(
  isSendingMyVideo:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    BOOL isSendingMyVideo = [service isSendingMyVideo];
    resolve([NSNumber numberWithBool:isSendingMyVideo]);
  }
}

RCT_EXPORT_METHOD(
  muteMyVideo: (BOOL*)mute
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    if (!mute && ![service canUnmuteMyVideo]) {
      reject(
        @"ERR_ZOOM_SERVICE",
        [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot unmute your video."],
        [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
      );
      return;
    }
    [service muteMyVideo:mute];
    resolve(@"Successfully set meeting video");
  }
}

// All users meeting audio

RCT_EXPORT_METHOD(
  muteAllUserAudio: (BOOL*)mute
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    [service muteAllUserAudio:mute];
    resolve(@"Successfully set meeting audio");
  }
}

// User meeting audio

RCT_EXPORT_METHOD(
  isUserAudioMuted: (NSUInteger*)userId
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    BOOL isUserAudioMuted = [service isUserAudioMuted:*userId];
    resolve([NSNumber numberWithBool:isUserAudioMuted]);
  }
}

RCT_EXPORT_METHOD(
  setUserAudioMuted: (NSUInteger*)muted
  forUser: (NSUInteger*)userId
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    [service muteUserAudio:muted withUID:*userId];
    resolve(@"Successfully set user meeting audio");
  }
}

// User meeting video

RCT_EXPORT_METHOD(
  switchMyCamera:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
      @try {
          [service switchMyCamera];
          resolve(@"Successfully switched camera");
      } @catch (NSError *ex) {
          reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing switchMyAudioSource", ex);
      }
  }
}

RCT_EXPORT_METHOD(
  isUserVideoSending: (NSUInteger*)userId
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    BOOL isUserVideoSending = [service isUserVideoSending:*userId];
    resolve([NSNumber numberWithBool:isUserVideoSending]);
  }
}

RCT_EXPORT_METHOD(
  setUserVideoMuted: (NSUInteger*)muted
  forUser: (NSUInteger*)userId
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    if (muted) {
      [service stopUserVideo:*userId];
    } else {
      [service askUserStartVideo:*userId];
    }
    resolve(@"Successfully set user meeting video");
  }
}

RCT_EXPORT_METHOD(
  pinVideo: (BOOL*)pin
  forUser: (NSUInteger*)userId
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    [service pinVideo:pin withUser:*userId];
    resolve(@"Successfully set pin video");
  }
}

// CRM

RCT_EXPORT_METHOD(
  isCMREnabled:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    BOOL isCMREnabled = [service isCMREnabled];
    resolve([NSNumber numberWithBool:isCMREnabled]);
  }
}

RCT_EXPORT_METHOD(
  isCMRInProgress:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    BOOL isCMRInProgress = [service isCMRInProgress];
    resolve([NSNumber numberWithBool:isCMRInProgress]);
  }
}

RCT_EXPORT_METHOD(
  isCMRPaused:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    BOOL isCMRPaused = [service isCMRPaused];
    resolve([NSNumber numberWithBool:isCMRPaused]);
  }
}

RCT_EXPORT_METHOD(
  turnOnCMR: (BOOL*)on
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    [service turnOnCMR:on];
    resolve(@"Successfully set CMR");
  }
}

// My user Info

RCT_EXPORT_METHOD(
  getMyUserInfo:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    MobileRTCMeetingUserInfo *myself = [service userInfoByID:[service myselfUserID]];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
  
    NSNumber *userID = [NSNumber numberWithInteger:[myself userID]];
    [dict setObject:userID forKey:@"userID"];
    [dict setObject:[myself userName] forKey:@"userName"];
  
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error: &error];
      
    resolve(@{@"userInfo": [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]});
  }
}

// All users Info

RCT_EXPORT_METHOD(
  getInMeetingUserList:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    NSArray *users = [service getInMeetingUserList];
    NSMutableArray *usersInfo = [[NSMutableArray alloc] init];
      
    for (id user in users) {
      MobileRTCMeetingUserInfo *item = [service userInfoByID:[user integerValue]];
      NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
  
      NSNumber *userID = [NSNumber numberWithInteger:[item userID]];
      [dict setObject:userID forKey:@"userID"];
      [dict setObject:[item userName] forKey:@"userName"];
  
      [usersInfo addObject:item];
    }
      
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:usersInfo options:NSJSONWritingPrettyPrinted error: &error];
    
    resolve(@{@"usersInfo": [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]});
  }
}

// Leave meeting

RCT_EXPORT_METHOD(
  leaveMeeting:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    [service leaveMeetingWithCmd:LeaveMeetingCmd_Leave];
    resolve(@"Successfully left meeting");
  }
}

// End meeting

RCT_EXPORT_METHOD(
  endMeeting:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
      @try {
          [service leaveMeetingWithCmd:LeaveMeetingCmd_End];
          resolve(@"Successfully ended meeting");
      } @catch (NSError *ex) {
          reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing endMeeting", ex);
      }
  }
}

// Lock meeting

RCT_EXPORT_METHOD(
  isMeetingLocked:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    BOOL isMeetingLocked = [service isMeetingLocked];
    resolve([NSNumber numberWithBool:isMeetingLocked]);
  }
}

RCT_EXPORT_METHOD(
  lockMeeting: (BOOL*)lockMeeting
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
      @try {
         [service lockMeeting:lockMeeting];
          resolve(@"Successfully locked meeting");
      } @catch (NSError *ex) {
          reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing lockMeeting", ex);
      }
  }
}

// Lock share

RCT_EXPORT_METHOD(
  isShareLocked:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    BOOL isShareLocked = [service isShareLocked];
    resolve([NSNumber numberWithBool:isShareLocked]);
  }
}

RCT_EXPORT_METHOD(
  lockShare: (BOOL*)lockShare
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
      @try {
        [service lockShare:lockShare];
        resolve(@"Successfully locked meeting");
      } @catch (NSError *ex) {
        reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing lockShare", ex);
      }
  }
}

RCT_EXPORT_METHOD(
  startAppShare:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
      @try {
         [service startAppShare];
         resolve(@"Successfully started app share");
      } @catch (NSError *ex) {
          reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing startAppShare", ex);
      }
  }
}

RCT_EXPORT_METHOD(
  stopAppShare:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
      @try {
         [service stopAppShare];
         resolve(@"Successfully stopped app share");
      } @catch (NSError *ex) {
          reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing stopAppShare", ex);
      }
  }
}

RCT_EXPORT_METHOD(
  isStartingShare:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCMeetingService *service = [[MobileRTC sharedRTC] getMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    BOOL isStartingShare = [service isStartingShare];
    resolve([NSNumber numberWithBool:isStartingShare]);
  }
}

// Meetings managment

RCT_EXPORT_METHOD(
  listMeeting:
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCPremeetingService *service = [[MobileRTC sharedRTC] getPreMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the premeeting service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
    premeetingPromiseResolve = resolve;
    premeetingPromiseReject = reject;
    [service listMeeting];
  }
}

RCT_EXPORT_METHOD(
  createMeeting:
  withParams: (NSDictionary *)params
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCPremeetingService *service = [[MobileRTC sharedRTC] getPreMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the premeeting service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
      premeetingPromiseResolve = resolve;
      premeetingPromiseReject = reject;
      
      id<MobileRTCMeetingItem> item = [service createMeetingItem];
      
      id topic = params[@"topic"];
      if ((topic != nil) && (topic != (id)[NSNull null])) {
        [item setMeetingTopic:topic];
      }
      
      id date = params[@"date"];
      if ((date != nil) && (date != (id)[NSNull null])) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
        NSDate *startDate = [dateFormatter dateFromString:date];
      
        [item setStartTime:startDate];
      }
      
      id timzone = params[@"timzone"];
      if ((timzone != nil) && (timzone != (id)[NSNull null])) {
        [item setTimeZoneID:timzone];
      }
      
      id duration = params[@"duration"];
      if ((duration != nil) && (duration != (id)[NSNull null])) {
        [item setDurationInMinutes:[duration integerValue]];
      }
      
      [service scheduleMeeting:item WithScheduleFor:@""];
      [service destroyMeetingItem:item];
  }
}

RCT_EXPORT_METHOD(
  updateMeeting: (NSUInteger*)uniqueId
  withParams: (NSDictionary *)params
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCPremeetingService *service = [[MobileRTC sharedRTC] getPreMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the premeeting service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
      id<MobileRTCMeetingItem> item = [service getMeetingItemByUniquedID:(unsigned long)uniqueId];

      if (item) {
        premeetingPromiseResolve = resolve;
        premeetingPromiseReject = reject;
          
        
        [item setMeetingNumber:123456789];
        [item setMeetingPassword:@"yyy"];
          
        id topic = params[@"topic"];
        if ((topic != nil) && (topic != (id)[NSNull null])) {
          [item setMeetingTopic:topic];
        }
      
        id date = params[@"date"];
        if ((date != nil) && (date != (id)[NSNull null])) {
          NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
          [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
          NSDate *startDate = [dateFormatter dateFromString:date];
          
          [item setStartTime:startDate];
        }
      
        id timzone = params[@"timzone"];
        if ((timzone != nil) && (timzone != (id)[NSNull null])) {
           [item setTimeZoneID:timzone];
        }
      
        id duration = params[@"duration"];
        if ((duration != nil) && (duration != (id)[NSNull null])) {
           [item setDurationInMinutes:[duration integerValue]];
        }

        [service editMeeting:item];
          
      } else {
        reject(
          @"ERR_ZOOM_SERVICE",
          [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the meeting item."],
          [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
        );
      }
  }
}

RCT_EXPORT_METHOD(
  deleteMeeting: (NSUInteger*)uniqueId
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  MobileRTCPremeetingService *service = [[MobileRTC sharedRTC] getPreMeetingService];
  if (!service) {
    reject(
      @"ERR_ZOOM_SERVICE",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the premeeting service."],
      [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
    );
  } else {
      id<MobileRTCMeetingItem> item = [service getMeetingItemByUniquedID:(unsigned long)uniqueId];
      if (item) {
          premeetingPromiseResolve = resolve;
          premeetingPromiseReject = reject;
          
          [service deleteMeeting:item];
      } else {
          reject(
            @"ERR_ZOOM_SERVICE",
            [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", -1, @"Cannot get the meeting item."],
            [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
          );
      }
  }
}

#pragma mark - Premeeting delegate

- (void)sinkDeleteMeeting:(PreMeetingError)result {
    if (result == PreMeetingError_Success) {
        premeetingPromiseResolve(@"Successfuly deleted meeting");
    } else {
        premeetingPromiseReject(
          @"ERR_ZOOM_SERVICE",
          [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@, result%d", -1, @"Cannot delete the meeting item.", result],
          [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
        );
    }
    
    premeetingPromiseResolve = nil;
    premeetingPromiseReject = nil;
}

- (void)sinkEditMeeting:(PreMeetingError)result MeetingUniquedID:(unsigned long long)uniquedID {
    if (result == PreMeetingError_Success) {
        premeetingPromiseResolve(@"Successfuly editied meeting");
    } else {
        premeetingPromiseReject(
          @"ERR_ZOOM_SERVICE",
          [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@, result%d, forMeetingId%llu", -1, @"Cannot edit the meeting item.", result, uniquedID],
          [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
        );
    }
    
    premeetingPromiseResolve = nil;
    premeetingPromiseReject = nil;
}


- (void)sinkSchedultMeeting:(PreMeetingError)result MeetingUniquedID:(unsigned long long)uniquedID {
    if (result == PreMeetingError_Success) {
        premeetingPromiseResolve(@"Successfuly schedult meeting");
    } else {
        premeetingPromiseReject(
          @"ERR_ZOOM_SERVICE",
          [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@, result%d, forMeetingId%llu", -1, @"Cannot schedule the meeting.", result, uniquedID],
          [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
        );
    }
    
    premeetingPromiseResolve = nil;
    premeetingPromiseReject = nil;
}


- (void)sinkListMeeting:(PreMeetingError)result withMeetingItems:(nonnull NSArray *)array {
    if (result == PreMeetingError_Success) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error: &error];
        
        premeetingPromiseResolve(@{@"meetingsList": [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]});
    } else {
        premeetingPromiseReject(
          @"ERR_ZOOM_SERVICE",
          [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@, result%d", -1, @"Cannot list the meetings.", result],
          [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]
        );
    }
    
    premeetingPromiseResolve = nil;
    premeetingPromiseReject = nil;
}

@end
