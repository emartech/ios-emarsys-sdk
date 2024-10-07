//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSDeviceInfo.h"
#import "EMSStorage.h"
#import <OCMock/OCMock.h>
#import <UserNotifications/UserNotifications.h>
#import "EMSUUIDProvider.h"

#define kEMSHardwareIdKey @"kHardwareIdKey"

@interface EMSDeviceInfoTests : XCTestCase

@property (nonatomic, strong) EMSDeviceInfo *deviceInfo;
@property (nonatomic, strong) UNUserNotificationCenter *mockCenter;
@property (nonatomic, strong) id mockStorage;
@property (nonatomic, strong) id mockUUIDProvider;

@end

@implementation EMSDeviceInfoTests

- (void)setUp {
    [super setUp];
    self.mockCenter = OCMClassMock([UNUserNotificationCenter class]);
    self.mockStorage = OCMClassMock([EMSStorage class]);
    self.mockUUIDProvider = OCMClassMock([EMSUUIDProvider class]);
    self.deviceInfo = [[EMSDeviceInfo alloc] initWithSDKVersion:@"testSdkVersion"
                                             notificationCenter:self.mockCenter
                                                        storage:self.mockStorage
                                                   uuidProvider:self.mockUUIDProvider];
}

- (void)testInit_sdkVersion_mustNotBeNil {
    @try {
        [[EMSDeviceInfo alloc] initWithSDKVersion:nil
                               notificationCenter:OCMClassMock([UNUserNotificationCenter class])
                                          storage:self.mockStorage
                                     uuidProvider:self.mockUUIDProvider];
        XCTFail(@"Expected Exception when sdkVersion is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: sdkVersion");
    }
}

- (void)testInit_notificationCenter_mustNotBeNil {
    @try {
        [[EMSDeviceInfo alloc] initWithSDKVersion:@""
                               notificationCenter:nil
                                          storage:self.mockStorage
                                     uuidProvider:self.mockUUIDProvider];
        XCTFail(@"Expected Exception when notificationCenter is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: notificationCenter");
    }
}

- (void)testInit_storage_mustNotBeNil {
    @try {
        [[EMSDeviceInfo alloc] initWithSDKVersion:@""
                               notificationCenter:OCMClassMock([UNUserNotificationCenter class])
                                          storage:nil
                                     uuidProvider:self.mockUUIDProvider];
        XCTFail(@"Expected Exception when storage is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: storage");
    }
}

- (void)testInit_uuidProvider_mustNotBeNil {
    @try {
        [[EMSDeviceInfo alloc] initWithSDKVersion:@""
                               notificationCenter:OCMClassMock([UNUserNotificationCenter class])
                                          storage:self.mockStorage
                                     uuidProvider:nil];
        XCTFail(@"Expected Exception when uuidProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: uuidProvider");
    }
}

- (void)testTimeZone {
    NSTimeZone *originalTimeZone = [NSTimeZone defaultTimeZone];
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Budapest"]];
    
    XCTAssertNotNil([self.deviceInfo timeZone]);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone localTimeZone];
    formatter.dateFormat = @"xxxx";
    NSString *expected = [formatter stringFromDate:[NSDate date]];
    
    XCTAssertEqualObjects([self.deviceInfo timeZone], expected);
    
    [NSTimeZone setDefaultTimeZone:originalTimeZone];
}

- (void)testLanguageCode {
    NSString *expectedLanguage = [NSBundle mainBundle].preferredLocalizations[0];
    
    XCTAssertNotNil(expectedLanguage);
    XCTAssertEqualObjects([self.deviceInfo languageCode], expectedLanguage);
}

- (void)testDeviceModel {
    XCTAssertNotNil([self.deviceInfo deviceModel]);
}

- (void)testDeviceType {
    id mockDevice = OCMClassMock([UIDevice class]);

    [[[[mockDevice stub] classMethod] andReturn:mockDevice] currentDevice];
    OCMStub([mockDevice userInterfaceIdiom]).andReturn(UIUserInterfaceIdiomPhone);
    
    XCTAssertEqualObjects([self.deviceInfo deviceType], @"iPhone");
}

- (void)testOSVersion {
    XCTAssertNotNil([self.deviceInfo osVersion]);
}

- (void)testSystemName {
    XCTAssertNotNil([self.deviceInfo systemName]);
}

- (void)testPlatform {
    XCTAssertEqualObjects([self.deviceInfo platform], @"ios");
}

- (void)testAuthorizationStatusAuthorized {
    NSDictionary *result = [self setupNotificationSetting:@selector(authorizationStatus) returnValue:UNAuthorizationStatusAuthorized];
    XCTAssertEqualObjects(result[@"authorizationStatus"], @"authorized");
}

- (void)testAuthorizationStatusDenied {
    NSDictionary *result = [self setupNotificationSetting:@selector(authorizationStatus) returnValue:UNAuthorizationStatusDenied];
    XCTAssertEqualObjects(result[@"authorizationStatus"], @"denied");
}

- (void)testAuthorizationStatusProvisional {
    if (@available(iOS 12.0, *)) {
        NSDictionary *result = [self setupNotificationSetting:@selector(authorizationStatus) returnValue:UNAuthorizationStatusProvisional];
        XCTAssertEqualObjects(result[@"authorizationStatus"], @"provisional");
    }
}

- (void)testAuthorizationStatusNotDetermined {
    NSDictionary *result = [self setupNotificationSetting:@selector(authorizationStatus) returnValue:UNAuthorizationStatusNotDetermined];
    XCTAssertEqualObjects(result[@"authorizationStatus"], @"notDetermined");
}

- (void)testSoundSettingNotSupported {
    NSDictionary *result = [self setupNotificationSetting:@selector(soundSetting) returnValue:UNNotificationSettingNotSupported];
    XCTAssertEqualObjects(result[@"soundSetting"], @"notSupported");
}

- (void)testSoundSettingDisabled {
    NSDictionary *result = [self setupNotificationSetting:@selector(soundSetting) returnValue:UNNotificationSettingDisabled];
    XCTAssertEqualObjects(result[@"soundSetting"], @"disabled");
}

- (void)testSoundSettingEnabled {
    NSDictionary *result = [self setupNotificationSetting:@selector(soundSetting) returnValue:UNNotificationSettingEnabled];
    XCTAssertEqualObjects(result[@"soundSetting"], @"enabled");
}

- (void)testBadgeSettingNotSupported {
    NSDictionary *result = [self setupNotificationSetting:@selector(badgeSetting) returnValue:UNNotificationSettingNotSupported];
    XCTAssertEqualObjects(result[@"badgeSetting"], @"notSupported");
}

- (void)testBadgeSettingDisabled {
    NSDictionary *result = [self setupNotificationSetting:@selector(badgeSetting) returnValue:UNNotificationSettingDisabled];
    XCTAssertEqualObjects(result[@"badgeSetting"], @"disabled");
}

- (void)testBadgeSettingEnabled {
    NSDictionary *result = [self setupNotificationSetting:@selector(badgeSetting) returnValue:UNNotificationSettingEnabled];
    XCTAssertEqualObjects(result[@"badgeSetting"], @"enabled");
}

- (void)testAlertSettingNotSupported {
    NSDictionary *result = [self setupNotificationSetting:@selector(alertSetting) returnValue:UNNotificationSettingNotSupported];
    XCTAssertEqualObjects(result[@"alertSetting"], @"notSupported");
}

- (void)testAlertSettingDisabled {
    NSDictionary *result = [self setupNotificationSetting:@selector(alertSetting) returnValue:UNNotificationSettingDisabled];
    XCTAssertEqualObjects(result[@"alertSetting"], @"disabled");
}

- (void)testAlertSettingEnabled {
    NSDictionary *result = [self setupNotificationSetting:@selector(alertSetting) returnValue:UNNotificationSettingEnabled];
    XCTAssertEqualObjects(result[@"alertSetting"], @"enabled");
}

- (void)testNotificationCenterSettingNotSupported {
    NSDictionary *result = [self setupNotificationSetting:@selector(notificationCenterSetting) returnValue:UNNotificationSettingNotSupported];
    XCTAssertEqualObjects(result[@"notificationCenterSetting"], @"notSupported");
}

- (void)testNotificationCenterSettingDisabled {
    NSDictionary *result = [self setupNotificationSetting:@selector(notificationCenterSetting) returnValue:UNNotificationSettingDisabled];
    XCTAssertEqualObjects(result[@"notificationCenterSetting"], @"disabled");
}

- (void)testNotificationCenterSettingEnabled {
    NSDictionary *result = [self setupNotificationSetting:@selector(notificationCenterSetting) returnValue:UNNotificationSettingEnabled];
    XCTAssertEqualObjects(result[@"notificationCenterSetting"], @"enabled");
}

- (void)testLockScreenSettingNotSupported {
    NSDictionary *result = [self setupNotificationSetting:@selector(lockScreenSetting) returnValue:UNNotificationSettingNotSupported];
    XCTAssertEqualObjects(result[@"lockScreenSetting"], @"notSupported");
}

- (void)testLockScreenSettingDisabled {
    NSDictionary *result = [self setupNotificationSetting:@selector(lockScreenSetting) returnValue:UNNotificationSettingDisabled];
    XCTAssertEqualObjects(result[@"lockScreenSetting"], @"disabled");
}

- (void)testLockScreenSettingEnabled {
    NSDictionary *result = [self setupNotificationSetting:@selector(lockScreenSetting) returnValue:UNNotificationSettingEnabled];
    XCTAssertEqualObjects(result[@"lockScreenSetting"], @"enabled");
}

- (void)testCarPlaySettingNotSupported {
    NSDictionary *result = [self setupNotificationSetting:@selector(carPlaySetting) returnValue:UNNotificationSettingNotSupported];
    XCTAssertEqualObjects(result[@"carPlaySetting"], @"notSupported");
}

- (void)testCarPlaySettingDisabled {
    NSDictionary *result = [self setupNotificationSetting:@selector(carPlaySetting) returnValue:UNNotificationSettingDisabled];
    XCTAssertEqualObjects(result[@"carPlaySetting"], @"disabled");
}

- (void)testCarPlaySettingEnabled {
    NSDictionary *result = [self setupNotificationSetting:@selector(carPlaySetting) returnValue:UNNotificationSettingEnabled];
    XCTAssertEqualObjects(result[@"carPlaySetting"], @"enabled");
}

- (void)testAlertStyleNone {
    NSDictionary *result = [self setupNotificationSetting:@selector(alertStyle) returnValue:UNAlertStyleNone];
    XCTAssertEqualObjects(result[@"alertStyle"], @"none");
}

- (void)testAlertStyleBanner {
    NSDictionary *result = [self setupNotificationSetting:@selector(alertStyle) returnValue:UNAlertStyleBanner];
    XCTAssertEqualObjects(result[@"alertStyle"], @"banner");
}

- (void)testAlertStyleAlert {
    NSDictionary *result = [self setupNotificationSetting:@selector(alertStyle) returnValue:UNAlertStyleAlert];
    XCTAssertEqualObjects(result[@"alertStyle"], @"alert");
}

- (void)testShowPreviewsSettingNever {
    NSDictionary *result = [self setupNotificationSetting:@selector(showPreviewsSetting) returnValue:UNShowPreviewsSettingNever];
    XCTAssertEqualObjects(result[@"showPreviewsSetting"], @"never");
}

- (void)testShowPreviewsSettingWhenAuthenticated {
    NSDictionary *result = [self setupNotificationSetting:@selector(showPreviewsSetting) returnValue:UNShowPreviewsSettingWhenAuthenticated];
    XCTAssertEqualObjects(result[@"showPreviewsSetting"], @"whenAuthenticated");
}

- (void)testShowPreviewsSettingAlways {
    NSDictionary *result = [self setupNotificationSetting:@selector(showPreviewsSetting) returnValue:UNShowPreviewsSettingAlways];
    XCTAssertEqualObjects(result[@"showPreviewsSetting"], @"always");
}

- (void)testCriticalAlertSettingNotSupported {
    if (@available(iOS 12.0, *)) {
        NSDictionary *result = [self setupNotificationSetting:@selector(criticalAlertSetting) returnValue:UNNotificationSettingNotSupported];
        XCTAssertEqualObjects(result[@"criticalAlertSetting"], @"notSupported");
    }
}

- (void)testCriticalAlertSettingDisabled {
    if (@available(iOS 12.0, *)) {
        NSDictionary *result = [self setupNotificationSetting:@selector(criticalAlertSetting) returnValue:UNNotificationSettingDisabled];
        XCTAssertEqualObjects(result[@"criticalAlertSetting"], @"disabled");
    }
}

- (void)testCriticalAlertSettingEnabled {
    if (@available(iOS 12.0, *)) {
        NSDictionary *result = [self setupNotificationSetting:@selector(criticalAlertSetting) returnValue:UNNotificationSettingEnabled];
        XCTAssertEqualObjects(result[@"criticalAlertSetting"], @"enabled");
    }
}

- (void)testProvidesAppNotificationSettingsNO {
    if (@available(iOS 12.0, *)) {
        NSDictionary *result = [self setupNotificationSetting:@selector(providesAppNotificationSettings) returnValue:NO];
        XCTAssertEqualObjects(result[@"providesAppNotificationSettings"], @(NO));
    }
}

- (void)testProvidesAppNotificationSettingsYES {
    if (@available(iOS 12.0, *)) {
        NSDictionary *result = [self setupNotificationSetting:@selector(providesAppNotificationSettings) returnValue:YES];
        XCTAssertEqualObjects(result[@"providesAppNotificationSettings"], @(YES));
    }
}

- (void)testScheduledDeliverySettingEnabled {
    if (@available(iOS 15.0, *)) {
        NSDictionary *result = [self setupNotificationSetting:@selector(scheduledDeliverySetting) returnValue:UNNotificationSettingEnabled];
        XCTAssertEqualObjects(result[@"scheduledDeliverySetting"], @"enabled");
    }
}

- (void)testScheduledDeliverySettingDisabled {
    if (@available(iOS 15.0, *)) {
        NSDictionary *result = [self setupNotificationSetting:@selector(scheduledDeliverySetting) returnValue:UNNotificationSettingDisabled];
        XCTAssertEqualObjects(result[@"scheduledDeliverySetting"], @"disabled");
    }
}

- (void)testScheduledDeliverySettingNotSupported {
    if (@available(iOS 15.0, *)) {
        NSDictionary *result = [self setupNotificationSetting:@selector(scheduledDeliverySetting) returnValue:UNNotificationSettingNotSupported];
        XCTAssertEqualObjects(result[@"scheduledDeliverySetting"], @"notSupported");
    }
}

- (void)testTimeSensitiveSettingEnabled {
    if (@available(iOS 15.0, *)) {
        NSDictionary *result = [self setupNotificationSetting:@selector(timeSensitiveSetting) returnValue:UNNotificationSettingEnabled];
        XCTAssertEqualObjects(result[@"timeSensitiveSetting"], @"enabled");
    }
}

- (void)testTimeSensitiveSettingDisabled {
    if (@available(iOS 15.0, *)) {
        NSDictionary *result = [self setupNotificationSetting:@selector(timeSensitiveSetting) returnValue:UNNotificationSettingDisabled];
        XCTAssertEqualObjects(result[@"timeSensitiveSetting"], @"disabled");
    }
}

- (void)testTimeSensitiveSettingNotSupported {
    if (@available(iOS 15.0, *)) {
        NSDictionary *result = [self setupNotificationSetting:@selector(timeSensitiveSetting) returnValue:UNNotificationSettingNotSupported];
        XCTAssertEqualObjects(result[@"timeSensitiveSetting"], @"notSupported");
    }
}

- (void)testHWID_shouldReturnStoredHwId {
    NSData *dataHWID = [@"dataHWID" dataUsingEncoding:NSUTF8StringEncoding];
    OCMStub([self.mockStorage sharedDataForKey:@"kHardwareIdKey"]).andReturn(dataHWID);
    
    NSString *result = self.deviceInfo.hardwareId;
    XCTAssertEqualObjects(result, @"dataHWID");
}
    
- (void)testHWID_shouldReturnNewHwId {
    OCMStub([self.mockStorage sharedDataForKey:@"kHardwareIdKey"]).andReturn(nil);
    OCMStub([self.mockUUIDProvider provideUUIDString]).andReturn(@"testHWID");

    NSData *expectedDataHWID = [@"testHWID" dataUsingEncoding:NSUTF8StringEncoding];
    OCMExpect([self.mockStorage setSharedData:expectedDataHWID forKey:@"kHardwareIdKey"]);

    NSString *result = self.deviceInfo.hardwareId;
    XCTAssertEqualObjects(result, @"testHWID");
}

- (NSDictionary *)setupNotificationSetting:(SEL)sel
                               returnValue:(NSInteger)returnValue {
    UNNotificationSettings *mockNotificationSetting = OCMClassMock([UNNotificationSettings class]);
    OCMStub([mockNotificationSetting performSelector:sel]).andReturn(returnValue);

    OCMStub([self.mockCenter getNotificationSettingsWithCompletionHandler:([OCMArg invokeBlockWithArgs:mockNotificationSetting, nil])]);

    NSDictionary *result = [self.deviceInfo pushSettings];
    return result;
}

@end
