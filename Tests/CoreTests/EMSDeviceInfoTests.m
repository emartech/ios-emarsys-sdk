//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSDeviceInfo.h"
#import "EMSStorage.h"
#import "OCMock.h"
#import <AdSupport/AdSupport.h>
#import <UserNotifications/UserNotifications.h>

#define kEMSHardwareIdKey @"kHardwareIdKey"

SPEC_BEGIN(EMSDeviceInfoTests)

        __block EMSDeviceInfo *deviceInfo;
        __block UNUserNotificationCenter *mockCenter;
        __block EMSStorage *mockStorage;
        __block ASIdentifierManager *mockIdentifierManager;

        beforeEach(^{
            mockCenter = [UNUserNotificationCenter nullMock];
            mockStorage = [EMSStorage nullMock];
            mockIdentifierManager = [ASIdentifierManager nullMock];
            deviceInfo = [[EMSDeviceInfo alloc] initWithSDKVersion:@"testSdkVersion"
                                                notificationCenter:mockCenter
                                                           storage:mockStorage
                                                 identifierManager:mockIdentifierManager];
        });

        describe(@"init", ^{
            it(@"should throw an exception when sdkVersion is nil", ^{
                @try {
                    [[EMSDeviceInfo alloc] initWithSDKVersion:nil
                                           notificationCenter:[UNUserNotificationCenter mock]
                                                      storage:mockStorage
                                            identifierManager:mockIdentifierManager];
                    fail(@"Expected Exception when sdkVersion is nil!");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: sdkVersion"];
                }
            });

            it(@"should throw an exception when notificationCenter is nil", ^{
                @try {
                    [[EMSDeviceInfo alloc] initWithSDKVersion:@""
                                           notificationCenter:nil
                                                      storage:mockStorage
                                            identifierManager:mockIdentifierManager];
                    fail(@"Expected Exception when notificationCenter is nil!");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: notificationCenter"];
                }
            });

            it(@"should throw an exception when storage is nil", ^{
                @try {
                    [[EMSDeviceInfo alloc] initWithSDKVersion:@""
                                           notificationCenter:[UNUserNotificationCenter mock]
                                                      storage:nil
                                            identifierManager:mockIdentifierManager];
                    fail(@"Expected Exception when storage is nil!");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: storage"];
                }
            });

            it(@"should throw an exception when identifierManager is nil", ^{
                @try {
                    [[EMSDeviceInfo alloc] initWithSDKVersion:@""
                                           notificationCenter:[UNUserNotificationCenter mock]
                                                      storage:mockStorage
                                            identifierManager:nil];
                    fail(@"Expected Exception when identifierManager is nil!");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: identifierManager"];
                }
            });
        });

        context(@"Timezone", ^{
            __block NSTimeZone *cachedTimeZone;

            beforeAll(^{
                cachedTimeZone = [NSTimeZone defaultTimeZone];
                [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Budapest"]];
            });

            afterAll(^{
                [NSTimeZone setDefaultTimeZone:cachedTimeZone];
            });

            describe(@"timeZone", ^{

                it(@"should not return nil", ^{
                    [[[deviceInfo timeZone] shouldNot] beNil];
                });

                it(@"should return with the current timeZone", ^{
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    formatter.timeZone = [NSTimeZone localTimeZone];
                    formatter.dateFormat = @"xxxx";
                    NSString *expected = [formatter stringFromDate:[NSDate date]];

                    NSString *timeZone = [deviceInfo timeZone];
                    [[timeZone should] equal:expected];
                });

            });

            describe(@"languageCode", ^{
                it(@"should return with languageCode", ^{
                    NSString *expectedLanguage = [NSLocale preferredLanguages].firstObject;

                    [[[deviceInfo languageCode] should] equal:expectedLanguage];
                });
            });

            describe(@"deviceModel", ^{
                it(@"should not return nil", ^{
                    [[[deviceInfo deviceModel] shouldNot] beNil];
                });
            });

            describe(@"deviceType", ^{

                void (^setUserInterfaceIdiom)(NSInteger userInterfaceIdiom) = ^(NSInteger userInterfaceIdiom) {
                    UIDevice *uiDevice = [UIDevice mock];
                    [[uiDevice should] receive:@selector(userInterfaceIdiom) andReturn:theValue(userInterfaceIdiom)];

                    [[UIDevice should] receive:@selector(currentDevice) andReturn:uiDevice];
                };

                it(@"should not return nil", ^{
                    [[[deviceInfo deviceType] shouldNot] beNil];
                });

                it(@"should return iPhone type", ^{
                    setUserInterfaceIdiom(UIUserInterfaceIdiomPhone);

                    [[[deviceInfo deviceType] should] equal:@"iPhone"];
                });

                it(@"should return iPad type", ^{
                    setUserInterfaceIdiom(UIUserInterfaceIdiomPad);

                    [[[deviceInfo deviceType] should] equal:@"iPad"];
                });

            });

            describe(@"osVersion", ^{
                it(@"should not return nil", ^{
                    [[[deviceInfo osVersion] shouldNot] beNil];
                });
            });

            describe(@"systemName", ^{
                it(@"should not return nil", ^{
                    [[[deviceInfo systemName] shouldNot] beNil];
                });
            });

            describe(@"platform", ^{
                it(@"should return iOS", ^{
                    [[[deviceInfo platform] should] equal:@"ios"];
                });
            });
        });

        describe(@"pushSettings", ^{

            NSDictionary *(^setupNotificationSetting)(SEL sel, NSInteger returnValue) = ^NSDictionary *(SEL sel, NSInteger returnValue) {
                KWCaptureSpy *spy = [mockCenter captureArgument:@selector(getNotificationSettingsWithCompletionHandler:)
                                                        atIndex:0];

                NSDictionary *result = [deviceInfo pushSettings];

                void (^notificationSettingsBlock)(UNNotificationSettings *notificationSetting) = spy.argument;


                UNNotificationSettings *mockNotificationSetting = [UNNotificationSettings nullMock];
                [mockNotificationSetting stub:sel
                                    andReturn:theValue(returnValue)];

                notificationSettingsBlock(mockNotificationSetting);
                return result;
            };

            it(@"should contain authorizationStatus with value authorized", ^{
                NSDictionary *result = setupNotificationSetting(@selector(authorizationStatus), UNAuthorizationStatusAuthorized);

                [[result[@"authorizationStatus"] should] equal:@"authorized"];
            });

            it(@"should contain authorizationStatus with value denied", ^{
                NSDictionary *result = setupNotificationSetting(@selector(authorizationStatus), UNAuthorizationStatusDenied);

                [[result[@"authorizationStatus"] should] equal:@"denied"];
            });

            if (@available(iOS 12.0, *)) {
                it(@"should contain authorizationStatus with value provisional", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(authorizationStatus), UNAuthorizationStatusProvisional);

                    [[result[@"authorizationStatus"] should] equal:@"provisional"];
                });
            }

            it(@"should contain authorizationStatus with value notDetermined", ^{
                NSDictionary *result = setupNotificationSetting(@selector(authorizationStatus), UNAuthorizationStatusNotDetermined);

                [[result[@"authorizationStatus"] should] equal:@"notDetermined"];
            });

            it(@"should contain soundSetting with value notSupported", ^{
                NSDictionary *result = setupNotificationSetting(@selector(soundSetting), UNNotificationSettingNotSupported);

                [[result[@"soundSetting"] should] equal:@"notSupported"];
            });

            it(@"should contain soundSetting with value disabled", ^{
                NSDictionary *result = setupNotificationSetting(@selector(soundSetting), UNNotificationSettingDisabled);

                [[result[@"soundSetting"] should] equal:@"disabled"];
            });

            it(@"should contain soundSetting with value enabled", ^{
                NSDictionary *result = setupNotificationSetting(@selector(soundSetting), UNNotificationSettingEnabled);

                [[result[@"soundSetting"] should] equal:@"enabled"];
            });

            it(@"should contain badgeSetting with value notSupported", ^{
                NSDictionary *result = setupNotificationSetting(@selector(badgeSetting), UNNotificationSettingNotSupported);

                [[result[@"badgeSetting"] should] equal:@"notSupported"];
            });

            it(@"should contain badgeSetting with value disabled", ^{
                NSDictionary *result = setupNotificationSetting(@selector(badgeSetting), UNNotificationSettingDisabled);

                [[result[@"badgeSetting"] should] equal:@"disabled"];
            });

            it(@"should contain badgeSetting with value enabled", ^{
                NSDictionary *result = setupNotificationSetting(@selector(badgeSetting), UNNotificationSettingEnabled);

                [[result[@"badgeSetting"] should] equal:@"enabled"];
            });

            it(@"should contain alertSetting with value notSupported", ^{
                NSDictionary *result = setupNotificationSetting(@selector(alertSetting), UNNotificationSettingNotSupported);

                [[result[@"alertSetting"] should] equal:@"notSupported"];
            });

            it(@"should contain alertSetting with value disabled", ^{
                NSDictionary *result = setupNotificationSetting(@selector(alertSetting), UNNotificationSettingDisabled);

                [[result[@"alertSetting"] should] equal:@"disabled"];
            });

            it(@"should contain alertSetting with value enabled", ^{
                NSDictionary *result = setupNotificationSetting(@selector(alertSetting), UNNotificationSettingEnabled);

                [[result[@"alertSetting"] should] equal:@"enabled"];
            });

            it(@"should contain notificationCenterSetting with value notSupported", ^{
                NSDictionary *result = setupNotificationSetting(@selector(notificationCenterSetting), UNNotificationSettingNotSupported);

                [[result[@"notificationCenterSetting"] should] equal:@"notSupported"];
            });

            it(@"should contain notificationCenterSetting with value disabled", ^{
                NSDictionary *result = setupNotificationSetting(@selector(notificationCenterSetting), UNNotificationSettingDisabled);

                [[result[@"notificationCenterSetting"] should] equal:@"disabled"];
            });

            it(@"should contain notificationCenterSetting with value enabled", ^{
                NSDictionary *result = setupNotificationSetting(@selector(notificationCenterSetting), UNNotificationSettingEnabled);

                [[result[@"notificationCenterSetting"] should] equal:@"enabled"];
            });

            it(@"should contain lockScreenSetting with value notSupported", ^{
                NSDictionary *result = setupNotificationSetting(@selector(lockScreenSetting), UNNotificationSettingNotSupported);

                [[result[@"lockScreenSetting"] should] equal:@"notSupported"];
            });

            it(@"should contain lockScreenSetting with value disabled", ^{
                NSDictionary *result = setupNotificationSetting(@selector(lockScreenSetting), UNNotificationSettingDisabled);

                [[result[@"lockScreenSetting"] should] equal:@"disabled"];
            });

            it(@"should contain lockScreenSetting with value enabled", ^{
                NSDictionary *result = setupNotificationSetting(@selector(lockScreenSetting), UNNotificationSettingEnabled);

                [[result[@"lockScreenSetting"] should] equal:@"enabled"];
            });

            it(@"should contain carPlaySetting with value notSupported", ^{
                NSDictionary *result = setupNotificationSetting(@selector(carPlaySetting), UNNotificationSettingNotSupported);

                [[result[@"carPlaySetting"] should] equal:@"notSupported"];
            });

            it(@"should contain carPlaySetting with value disabled", ^{
                NSDictionary *result = setupNotificationSetting(@selector(carPlaySetting), UNNotificationSettingDisabled);

                [[result[@"carPlaySetting"] should] equal:@"disabled"];
            });

            it(@"should contain carPlaySetting with value enabled", ^{
                NSDictionary *result = setupNotificationSetting(@selector(carPlaySetting), UNNotificationSettingEnabled);

                [[result[@"carPlaySetting"] should] equal:@"enabled"];
            });

            it(@"should contain alertStyle with value none", ^{
                NSDictionary *result = setupNotificationSetting(@selector(alertStyle), UNAlertStyleNone);

                [[result[@"alertStyle"] should] equal:@"none"];
            });

            it(@"should contain alertStyle with value banner", ^{
                NSDictionary *result = setupNotificationSetting(@selector(alertStyle), UNAlertStyleBanner);

                [[result[@"alertStyle"] should] equal:@"banner"];
            });

            it(@"should contain alertStyle with value alert", ^{
                NSDictionary *result = setupNotificationSetting(@selector(alertStyle), UNAlertStyleAlert);

                [[result[@"alertStyle"] should] equal:@"alert"];
            });

            it(@"should contain showPreviewsSetting with value never", ^{
                NSDictionary *result = setupNotificationSetting(@selector(showPreviewsSetting), UNShowPreviewsSettingNever);

                [[result[@"showPreviewsSetting"] should] equal:@"never"];
            });

            it(@"should contain showPreviewsSetting with value whenAuthenticated", ^{
                NSDictionary *result = setupNotificationSetting(@selector(showPreviewsSetting), UNShowPreviewsSettingWhenAuthenticated);

                [[result[@"showPreviewsSetting"] should] equal:@"whenAuthenticated"];
            });

            it(@"should contain showPreviewsSetting with value always", ^{
                NSDictionary *result = setupNotificationSetting(@selector(showPreviewsSetting), UNShowPreviewsSettingAlways);

                [[result[@"showPreviewsSetting"] should] equal:@"always"];
            });
            if (@available(iOS 12.0, *)) {
                it(@"should contain criticalAlertSetting with value notSupported", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(criticalAlertSetting), UNNotificationSettingNotSupported);

                    [[result[@"criticalAlertSetting"] should] equal:@"notSupported"];
                });

                it(@"should contain criticalAlertSetting with value disabled", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(criticalAlertSetting), UNNotificationSettingDisabled);

                    [[result[@"criticalAlertSetting"] should] equal:@"disabled"];
                });

                it(@"should contain criticalAlertSetting with value enabled", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(criticalAlertSetting), UNNotificationSettingEnabled);

                    [[result[@"criticalAlertSetting"] should] equal:@"enabled"];
                });

                it(@"should contain providesAppNotificationSettings with value NO", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(providesAppNotificationSettings), NO);

                    [[result[@"providesAppNotificationSettings"] should] equal:@(NO)];
                });

                it(@"should contain providesAppNotificationSettings with value YES", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(providesAppNotificationSettings), YES);

                    [[result[@"providesAppNotificationSettings"] should] equal:@(YES)];
                });
            }
        });

        context(@"HWID", ^{

            beforeEach(^{
                NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.emarsys.core"];
                [userDefaults removeObjectForKey:kEMSHardwareIdKey];
            });

            it(@"should return hwid when it's available in storage", ^{
                NSString *const kHwId = @"testHWID";
                [[mockStorage should] receive:@selector(stringForKey:) andReturn:kHwId];

                NSString *result = [deviceInfo hardwareId];

                [[result should] equal:kHwId];
            });

            it(@"should store new hwid in storage when hwid isn't available in userDefaults neither in storage", ^{
                [[mockStorage should] receive:@selector(setString:forKey:) withArguments:kw_any(), kEMSHardwareIdKey];

                NSString *result = [deviceInfo hardwareId];

                [[result shouldNot] beNil];
            });

            it(@"should return idfv if idfa is not available and there is no cached hardwareId", ^{
                NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

                [[mockIdentifierManager should] receive:@selector(isAdvertisingTrackingEnabled) andReturn:theValue(NO)];
                [[mockStorage should] receive:@selector(setString:forKey:) withArguments:idfv, kEMSHardwareIdKey];

                [[[deviceInfo hardwareId] should] equal:idfv];
            });

            it(@"should return idfa if available and there is no cached hardwareId", ^{
                NSUUID *idfaUUID = [NSUUID UUID];
                NSString *idfa = [idfaUUID UUIDString];

                [[mockIdentifierManager should] receive:@selector(isAdvertisingTrackingEnabled)
                                              andReturn:theValue(YES)];
                [[mockIdentifierManager should] receive:@selector(advertisingIdentifier) andReturn:idfaUUID];
                [[mockStorage should] receive:@selector(setString:forKey:) withArguments:idfa, kEMSHardwareIdKey];

                [[[deviceInfo hardwareId] should] equal:idfa];
            });
        });

SPEC_END