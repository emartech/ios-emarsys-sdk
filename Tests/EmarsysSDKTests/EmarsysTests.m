//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Kiwi.h"
#import "Emarsys.h"
#import "EMSPredictInternal.h"
#import "EMSSQLiteHelper.h"
#import "EMSDBTriggerKey.h"
#import "EMSDependencyContainer.h"
#import "EmarsysTestUtils.h"
#import "EMSAbstractResponseHandler.h"
#import "MEIAMResponseHandler.h"
#import "MEIAMCleanupResponseHandler.h"
#import "EMSVisitorIdResponseHandler.h"
#import "EMSDependencyInjection.h"
#import "MENotificationCenterManager.h"
#import "FakeDependencyContainer.h"
#import "AppStartBlockProvider.h"
#import "MERequestContext.h"
#import "EMSDeviceInfo.h"
#import "EMSRequestFactory.h"
#import "EMSClientStateResponseHandler.h"
#import "EMSLogger.h"
#import "EMSRequestManager.h"
#import "EMSPushV3Internal.h"
#import "MEInbox.h"
#import "MEInApp.h"
#import "MEUserNotificationDelegate.h"
#import "EMSLoggingPushInternal.h"
#import "EMSLoggingInbox.h"
#import "EMSLoggingInApp.h"
#import "EMSLoggingPredictInternal.h"
#import "EMSLoggingUserNotificationDelegate.h"
#import "EMSMobileEngageV3Internal.h"
#import "EMSLoggingMobileEngageInternal.h"
#import "EMSDeepLinkInternal.h"
#import "EMSLoggingDeepLinkInternal.h"

SPEC_BEGIN(EmarsysTests)


        context(@"EmarsysTests", ^{


            __block id engage;
            __block id push;
            __block id deepLink;
            __block EMSPredictInternal *predict;
            __block MERequestContext *requestContext;
            __block EMSDeviceInfo *deviceInfo;
            __block EMSRequestFactory *requestFactory;
            __block EMSRequestManager *requestManager;
            __block MENotificationCenterManager *notificationCenterManagerMock;
            __block AppStartBlockProvider *appStartBlockProvider;
            __block id deviceInfoClient;

            __block EMSConfig *baseConfig;
            __block id <EMSDependencyContainerProtocol> dependencyContainer;

            NSString *const customerId = @"customerId";

            beforeEach(^{
                engage = [KWMock nullMockForProtocol:@protocol(EMSMobileEngageProtocol)];
                push = [KWMock nullMockForProtocol:@protocol(EMSPushNotificationProtocol)];
                deepLink = [KWMock nullMockForProtocol:@protocol(EMSDeepLinkProtocol)];
                predict = [EMSPredictInternal nullMock];
                requestContext = [MERequestContext nullMock];
                deviceInfo = [EMSDeviceInfo nullMock];
                [requestContext stub:@selector(meId) andReturn:@"fakeMeId"];
                [requestContext stub:@selector(deviceInfo) andReturn:deviceInfo];
                requestFactory = [EMSRequestFactory nullMock];
                requestManager = [EMSRequestManager nullMock];
                notificationCenterManagerMock = [MENotificationCenterManager nullMock];
                appStartBlockProvider = [AppStartBlockProvider nullMock];
                deviceInfoClient = [KWMock nullMockForProtocol:@protocol(EMSDeviceInfoClientProtocol)];

                dependencyContainer = [[FakeDependencyContainer alloc] initWithDbHelper:nil
                                                                           mobileEngage:engage
                                                                               deepLink:deepLink
                                                                                   push:push
                                                                                  inbox:nil
                                                                                    iam:nil
                                                                                predict:predict
                                                                         requestContext:requestContext
                                                                         requestFactory:requestFactory
                                                                      requestRepository:nil
                                                                      notificationCache:nil
                                                                       responseHandlers:nil
                                                                         requestManager:requestManager
                                                                         operationQueue:nil
                                                              notificationCenterManager:notificationCenterManagerMock
                                                                  appStartBlockProvider:appStartBlockProvider
                                                                       deviceInfoClient:deviceInfoClient
                                                                                 logger:[EMSLogger nullMock]];

                [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                                   withDependencyContainer:dependencyContainer];
            });

            afterEach(^{
                [EmarsysTestUtils tearDownEmarsys];
            });

            describe(@"setupWithConfig:", ^{

                it(@"should initialize category for push", ^{
                    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"testExpectation"];

                    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                                       withDependencyContainer:nil];

                    __block NSSet *categorySet = nil;
                    [[UNUserNotificationCenter currentNotificationCenter] getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> *categories) {
                        categorySet = categories;
                        [expectation fulfill];
                    }];

                    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation]
                                                                    timeout:5];

                    XCTAssertGreaterThan(categorySet.count, 0);
                    XCTAssertEqual(result, XCTWaiterResultCompleted);
                });

                it(@"should set predict", ^{
                    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                                       withDependencyContainer:nil];
                    [[(NSObject *) [Emarsys predict] shouldNot] beNil];
                });

                it(@"should set push", ^{
                    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                                       withDependencyContainer:nil];
                    [[(NSObject *) [Emarsys push] shouldNot] beNil];
                });

                it(@"should set notificationCenterDelegate", ^{
                    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                                       withDependencyContainer:nil];
                    [[(NSObject *) [Emarsys notificationCenterDelegate] shouldNot] beNil];
                });

                it(@"should set config", ^{
                    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                                       withDependencyContainer:nil];
                    [[(NSObject *) [Emarsys config] shouldNot] beNil];
                });

                it(@"register triggers_when_PredictTurnedOn", ^{
                    [EmarsysTestUtils tearDownEmarsys];
                    [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                                [builder setMobileEngageApplicationCode:@"14C19-A121F"];
                                [builder setMerchantId:@"1428C8EE286EC34B"];
                                [builder setContactFieldId:@3];
                            }]
                                         dependencyContainer:nil];
                    NSDictionary *triggers = [[Emarsys sqliteHelper] registeredTriggers];

                    NSArray *afterInsertTriggers = triggers[[[EMSDBTriggerKey alloc] initWithTableName:@"shard"
                                                                                             withEvent:[EMSDBTriggerEvent insertEvent]
                                                                                              withType:[EMSDBTriggerType afterType]]];
                    [[theValue([afterInsertTriggers count]) should] equal:theValue(2)];
                    [[afterInsertTriggers should] contain:EMSDependencyInjection.dependencyContainer.loggerTrigger];
                    [[afterInsertTriggers should] contain:EMSDependencyInjection.dependencyContainer.predictTrigger];
                });

                it(@"register triggers", ^{
                    [EmarsysTestUtils tearDownEmarsys];
                    [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                                [builder setMobileEngageApplicationCode:@"14C19-A121F"];
                                [builder setContactFieldId:@3];
                            }]
                                         dependencyContainer:nil];
                    NSDictionary *triggers = [[Emarsys sqliteHelper] registeredTriggers];

                    NSArray *afterInsertTriggers = triggers[[[EMSDBTriggerKey alloc] initWithTableName:@"shard"
                                                                                             withEvent:[EMSDBTriggerEvent insertEvent]
                                                                                              withType:[EMSDBTriggerType afterType]]];
                    [[theValue([afterInsertTriggers count]) should] equal:theValue(1)];
                    [[afterInsertTriggers should] contain:EMSDependencyInjection.dependencyContainer.loggerTrigger];
                });

                it(@"should throw an exception when there is no config set", ^{
                    @try {
                        [Emarsys setupWithConfig:nil];
                        fail(@"Expected Exception when config is nil!");
                    } @catch (NSException *exception) {
                        [[exception.reason should] equal:@"Invalid parameter not satisfying: config"];
                        [[theValue(exception) shouldNot] beNil];
                    }
                });

                context(@"ResponseHandlers", ^{

                    it(@"should register MEIAMResponseHandler", ^{
                        [EmarsysTestUtils setupEmarsysWithFeatures:@[] withDependencyContainer:nil];

                        BOOL registered = NO;
                        for (EMSAbstractResponseHandler *responseHandler in EMSDependencyInjection.dependencyContainer.responseHandlers) {
                            if ([responseHandler isKindOfClass:[MEIAMResponseHandler class]]) {
                                registered = YES;
                            }
                        }

                        [[theValue(registered) should] beYes];
                    });

                    it(@"should register MEIAMCleanupResponseHandler", ^{
                        [EmarsysTestUtils setupEmarsysWithFeatures:@[] withDependencyContainer:nil];

                        BOOL registered = NO;
                        for (EMSAbstractResponseHandler *responseHandler in EMSDependencyInjection.dependencyContainer.responseHandlers) {
                            if ([responseHandler isKindOfClass:[MEIAMCleanupResponseHandler class]]) {
                                registered = YES;
                            }
                        }

                        [[theValue(registered) should] beYes];
                    });

                    it(@"should register EMSVisitorIdResponseHandler if no features are turned on", ^{
                        [EmarsysTestUtils setupEmarsysWithFeatures:@[] withDependencyContainer:nil];

                        NSUInteger registerCount = 0;
                        for (EMSAbstractResponseHandler *responseHandler in EMSDependencyInjection.dependencyContainer.responseHandlers) {
                            if ([responseHandler isKindOfClass:[EMSVisitorIdResponseHandler class]]) {
                                registerCount++;
                            }
                        }

                        [[theValue(registerCount) should] equal:theValue(1)];
                    });

                    it(@"should register EMSVisitorIdResponseHandler", ^{
                        [EmarsysTestUtils setupEmarsysWithFeatures:@[] withDependencyContainer:nil];

                        NSUInteger registerCount = 0;
                        for (EMSAbstractResponseHandler *responseHandler in EMSDependencyInjection.dependencyContainer.responseHandlers) {
                            if ([responseHandler isKindOfClass:[EMSVisitorIdResponseHandler class]]) {
                                registerCount++;
                            }
                        }

                        [[theValue(registerCount) should] equal:theValue(1)];
                    });

                    it(@"should register EMSClientStateResponseHandler", ^{
                        [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                                           withDependencyContainer:nil];

                        NSUInteger registerCount = 0;
                        for (EMSAbstractResponseHandler *responseHandler in EMSDependencyInjection.dependencyContainer.responseHandlers) {
                            if ([responseHandler isKindOfClass:[EMSClientStateResponseHandler class]]) {
                                registerCount++;
                            }
                        }

                        [[theValue(registerCount) should] equal:theValue(1)];
                    });

                    it(@"should initialize responseHandlers", ^{
                        [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                                           withDependencyContainer:nil];

                        [[theValue([EMSDependencyInjection.dependencyContainer.responseHandlers count]) should] equal:theValue(7)];
                    });
                });

                context(@"appStart", ^{

                    it(@"should register UIApplicationDidBecomeActiveNotification", ^{
                        void (^appStartBlock)() = ^{
                        };
                        void (^appStartBlock2)() = ^{
                        };
                        void (^appStartBlock3)() = ^{
                        };
                        [[appStartBlockProvider should] receive:@selector(createAppStartEventBlock)
                                                      andReturn:appStartBlock
                                                  withArguments:requestManager, requestContext];
                        [[appStartBlockProvider should] receive:@selector(createDeviceInfoEventBlock)
                                                      andReturn:appStartBlock2
                                                  withArguments:requestManager, requestFactory, deviceInfo];
                        [[appStartBlockProvider shouldNot] receive:@selector(createRemoteConfigEventBlock)
                                                         andReturn:appStartBlock3];
                        [[notificationCenterManagerMock should] receive:@selector(addHandlerBlock:forNotification:)
                                                          withArguments:appStartBlock,
                                                                        UIApplicationDidFinishLaunchingNotification];
                        [[notificationCenterManagerMock should] receive:@selector(addHandlerBlock:forNotification:)
                                                          withArguments:appStartBlock2,
                                                                        UIApplicationDidBecomeActiveNotification];
                        [[notificationCenterManagerMock shouldNot] receive:@selector(addHandlerBlock:forNotification:)
                                                             withArguments:appStartBlock3,
                                                                           UIApplicationDidFinishLaunchingNotification];
                        [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                                           withDependencyContainer:dependencyContainer];
                    });

                });

                context(@"automatic anonym applogin", ^{

                    it(@"setupWithConfig should send deviceInfo and login", ^{
                        EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                            [builder setMobileEngageApplicationCode:@"14C19-A121F"];
                            [builder setMerchantId:@"1428C8EE286EC34B"];
                            [builder setContactFieldId:@3];
                        }];
                        [EmarsysTestUtils tearDownEmarsys];
                        [EmarsysTestUtils setupEmarsysWithConfig:config
                                             dependencyContainer:dependencyContainer];

                        [[deviceInfoClient should] receive:@selector(sendDeviceInfoWithCompletionBlock:)];
                        [[engage should] receive:@selector(setContactWithContactFieldValue:)
                                   withArguments:kw_any()];

                        [Emarsys setupWithConfig:config];
                    });

                    it(@"setupWithConfig should not send deviceInfo and login when contactFieldValue is available", ^{
                        [requestContext stub:@selector(contactFieldValue)
                                   andReturn:@"testContactFieldValue"];

                        EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                            [builder setMobileEngageApplicationCode:@"14C19-A121F"];
                            [builder setMerchantId:@"1428C8EE286EC34B"];
                            [builder setContactFieldId:@3];
                        }];
                        [EmarsysTestUtils tearDownEmarsys];
                        [EmarsysTestUtils setupEmarsysWithConfig:config
                                             dependencyContainer:dependencyContainer];

                        [[deviceInfoClient shouldNot] receive:@selector(sendDeviceInfoWithCompletionBlock:)];
                        [[engage shouldNot] receive:@selector(setContactWithContactFieldValue:)
                                      withArguments:kw_any()];

                        [Emarsys setupWithConfig:config];
                    });

                    it(@"setupWithConfig should not send deviceInfo and login when contactToken is available", ^{
                        [requestContext stub:@selector(contactToken)
                                   andReturn:@"testContactToken"];

                        EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                            [builder setMobileEngageApplicationCode:@"14C19-A121F"];
                            [builder setMerchantId:@"1428C8EE286EC34B"];
                            [builder setContactFieldId:@3];
                        }];
                        [EmarsysTestUtils tearDownEmarsys];
                        [EmarsysTestUtils setupEmarsysWithConfig:config
                                             dependencyContainer:dependencyContainer];

                        [[deviceInfoClient shouldNot] receive:@selector(sendDeviceInfoWithCompletionBlock:)];
                        [[engage shouldNot] receive:@selector(setContactWithContactFieldValue:)
                                      withArguments:kw_any()];

                        [Emarsys setupWithConfig:config];
                    });

                });
            });

            describe(@"trackDeepLinkWithUserActivity:sourceHandler:", ^{

                it(@"should delegate call to MobileEngage", ^{
                    NSUserActivity *userActivity = [NSUserActivity mock];
                    EMSSourceHandler sourceHandler = ^(NSString *source) {
                    };

                    [[deepLink should] receive:@selector(trackDeepLinkWith:sourceHandler:)
                                 withArguments:userActivity, sourceHandler];

                    [Emarsys trackDeepLinkWithUserActivity:userActivity
                                             sourceHandler:sourceHandler];
                });
            });

            describe(@"trackCustomEventWithName:eventAttributes:completionBlock:", ^{

                it(@"should delegate call to MobileEngage with nil completionBlock", ^{
                    NSString *eventName = @"eventName";
                    NSDictionary<NSString *, NSString *> *eventAttributes = @{@"key": @"value"};

                    [[engage should] receive:@selector(trackCustomEventWithName:eventAttributes:completionBlock:)
                               withArguments:eventName, eventAttributes, kw_any()];

                    [Emarsys trackCustomEventWithName:eventName
                                      eventAttributes:eventAttributes];
                });

                it(@"should delegate call to MobileEngage", ^{
                    NSString *eventName = @"eventName";
                    NSDictionary<NSString *, NSString *> *eventAttributes = @{@"key": @"value"};
                    EMSCompletionBlock completionBlock = ^(NSError *error) {
                    };

                    [[engage should] receive:@selector(trackCustomEventWithName:eventAttributes:completionBlock:)
                               withArguments:eventName, eventAttributes, completionBlock];

                    [Emarsys trackCustomEventWithName:eventName
                                      eventAttributes:eventAttributes
                                      completionBlock:completionBlock];
                });
            });

            describe(@"trackMessageOpenWithUserInfo:completionBlock:", ^{

                NSDictionary *const userInfo = @{@"u": @"{\"sid\":\"dd8_zXfDdndBNEQi\"}"};

                it(@"should delegate call to MobileEngage with nil completionBlock", ^{
                    [[push should] receive:@selector(trackMessageOpenWithUserInfo:)
                             withArguments:userInfo];

                    [Emarsys.push trackMessageOpenWithUserInfo:userInfo];
                });

                it(@"should delegate call to MobileEngage", ^{
                    EMSCompletionBlock completionBlock = ^(NSError *error) {
                    };

                    [[push should] receive:@selector(trackMessageOpenWithUserInfo:completionBlock:)
                             withArguments:userInfo, completionBlock];

                    [Emarsys.push trackMessageOpenWithUserInfo:userInfo
                                               completionBlock:completionBlock];
                });
            });

            describe(@"setContactWithContactFieldValue delegates properly based on enabled features", ^{
                beforeEach(^{
                    [EmarsysTestUtils tearDownEmarsys];
                });

                it(@"setContactWithContactFieldValue is not called by predict when predict is disabled", ^{
                    EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        [builder setMobileEngageApplicationCode:@"14C19-A121F"];
                        [builder setContactFieldId:@3];
                    }];
                    [EmarsysTestUtils setupEmarsysWithConfig:config
                                         dependencyContainer:dependencyContainer];

                    [[predict shouldNot] receive:@selector(setContactWithContactFieldValue:)];

                    [Emarsys setContactWithContactFieldValue:@"contact"];
                });

                it(@"setContactWithContactFieldValue is called by predict when predict is enabled", ^{
                    EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        [builder setMerchantId:@"14C19-A121F"];
                        [builder setContactFieldId:@3];
                    }];
                    [EmarsysTestUtils setupEmarsysWithConfig:config
                                         dependencyContainer:dependencyContainer];

                    [[predict should] receive:@selector(setContactWithContactFieldValue:)];

                    [Emarsys setContactWithContactFieldValue:@"contact"];
                });

                it(@"setContactWithContactFieldValue is not called by mobileEngage when mobileEngage is disabled", ^{
                    EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        [builder setMerchantId:@"14C19-A121F"];
                        [builder setContactFieldId:@3];
                    }];
                    [EmarsysTestUtils setupEmarsysWithConfig:config
                                         dependencyContainer:dependencyContainer];

                    [[engage shouldNot] receive:@selector(setContactWithContactFieldValue:completionBlock:)];

                    [Emarsys setContactWithContactFieldValue:@"contact"];
                });

                it(@"setContactWithContactFieldValue is called by mobileEngage when mobileEngage is enabled", ^{
                    EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        [builder setMobileEngageApplicationCode:@"14C19-A121F"];
                        [builder setContactFieldId:@3];
                    }];
                    [EmarsysTestUtils setupEmarsysWithConfig:config
                                         dependencyContainer:dependencyContainer];

                    [[engage should] receive:@selector(setContactWithContactFieldValue:completionBlock:)];

                    [Emarsys setContactWithContactFieldValue:@"contact"];
                });

                it(@"setContactWithContactFieldValue is only called once when mobileEngage and predict are disabled", ^{
                    EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                    }];
                    [EmarsysTestUtils setupEmarsysWithConfig:config
                                         dependencyContainer:dependencyContainer];

                    [[predict shouldNot] receive:@selector(setContactWithContactFieldValue:)];
                    [[engage should] receive:@selector(setContactWithContactFieldValue:completionBlock:)];

                    [Emarsys setContactWithContactFieldValue:@"contact"];
                });
            });

            describe(@"clearContact delegates properly based on enabled features", ^{
                beforeEach(^{
                    [EmarsysTestUtils tearDownEmarsys];
                });

                it(@"clearContact is not called by predict when predict is disabled", ^{
                    EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        [builder setMobileEngageApplicationCode:@"14C19-A121F"];
                        [builder setContactFieldId:@3];
                    }];
                    [EmarsysTestUtils setupEmarsysWithConfig:config
                                         dependencyContainer:dependencyContainer];

                    [[predict shouldNot] receive:@selector(clearContact)];

                    [Emarsys clearContact];
                });

                it(@"clearContact is called by predict when predict is enabled", ^{
                    EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        [builder setMerchantId:@"14C19-A121F"];
                        [builder setContactFieldId:@3];
                    }];
                    [EmarsysTestUtils setupEmarsysWithConfig:config
                                         dependencyContainer:dependencyContainer];

                    [[predict should] receive:@selector(clearContact)];

                    [Emarsys clearContact];
                });

                it(@"clearContact is not called by mobileEngage when mobileEngage is disabled", ^{
                    EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        [builder setMerchantId:@"14C19-A121F"];
                        [builder setContactFieldId:@3];
                    }];
                    [EmarsysTestUtils setupEmarsysWithConfig:config
                                         dependencyContainer:dependencyContainer];

                    [[engage shouldNot] receive:@selector(clearContact)];

                    [Emarsys clearContact];
                });

                it(@"clearContact is called by mobileEngage when mobileEngage is enabled", ^{
                    EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        [builder setMobileEngageApplicationCode:@"14C19-A121F"];
                        [builder setContactFieldId:@3];
                    }];
                    [EmarsysTestUtils setupEmarsysWithConfig:config
                                         dependencyContainer:dependencyContainer];

                    [[engage should] receive:@selector(clearContactWithCompletionBlock:)];

                    [Emarsys clearContact];
                });

                it(@"clearContact is only called once when mobileEngage and predict are disabled", ^{
                    EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                    }];
                    [EmarsysTestUtils setupEmarsysWithConfig:config
                                         dependencyContainer:dependencyContainer];

                    [[predict shouldNot] receive:@selector(clearContact)];
                    [[engage should] receive:@selector(clearContactWithCompletionBlock:)];

                    [Emarsys clearContact];
                });
            });

        });
        context(@"production setup", ^{

            describe(@"mobileEngage and predict is turned on", ^{

                beforeEach(^{
                    [EmarsysTestUtils tearDownEmarsys];
                    [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                                [builder setMobileEngageApplicationCode:@"14C19-A121F"];
                                [builder setMerchantId:@"1428C8EE286EC34B"];
                                [builder setContactFieldId:@3];
                            }]
                                         dependencyContainer:nil];
                });

                afterEach(^{
                    [EmarsysTestUtils tearDownEmarsys];
                });

                describe(@"push", ^{
                    it(@"should be EMSPushV3Internal", ^{
                        [[((NSObject *) Emarsys.push) should] beKindOfClass:[EMSPushV3Internal class]];
                    });
                });

                describe(@"inbox", ^{
                    it(@"should be MEInbox", ^{
                        [[((NSObject *) Emarsys.inbox) should] beKindOfClass:[MEInbox class]];
                    });
                });

                describe(@"inApp", ^{
                    it(@"should be MEInApp", ^{
                        [[((NSObject *) Emarsys.inApp) should] beKindOfClass:[MEInApp class]];
                    });
                });

                describe(@"predict", ^{
                    it(@"should be EMSPredictInternal", ^{
                        [[((NSObject *) Emarsys.predict) should] beKindOfClass:[EMSPredictInternal class]];
                    });
                });

                describe(@"notificationCenterDelegate", ^{
                    it(@"should be MEUserNotificationDelegate", ^{
                        [[((NSObject *) Emarsys.notificationCenterDelegate) should] beKindOfClass:[MEUserNotificationDelegate class]];
                    });
                });

                describe(@"mobileEngage", ^{
                    it(@"should be EMSMobileEngageV3Internal", ^{
                        [[((NSObject *) EMSDependencyInjection.dependencyContainer.mobileEngage) should] beKindOfClass:[EMSMobileEngageV3Internal class]];
                    });
                });

                describe(@"deepLink", ^{
                    it(@"should be EMSDeepLinkInternal", ^{
                        [[((NSObject *) EMSDependencyInjection.dependencyContainer.deepLink) should] beKindOfClass:[EMSDeepLinkInternal class]];
                    });
                });
            });

            describe(@"mobileEngage and predict is turned off", ^{

                beforeEach(^{
                    [EmarsysTestUtils tearDownEmarsys];
                    [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                            }]
                                         dependencyContainer:nil];
                });

                afterEach(^{
                    [EmarsysTestUtils tearDownEmarsys];
                });

                describe(@"push", ^{
                    it(@"should be EMSLoggingPushInternal", ^{
                        [[((NSObject *) Emarsys.push) should] beKindOfClass:[EMSLoggingPushInternal class]];
                    });
                });

                describe(@"inbox", ^{
                    it(@"should be EMSLoggingInbox", ^{
                        [[((NSObject *) Emarsys.inbox) should] beKindOfClass:[EMSLoggingInbox class]];
                    });
                });

                describe(@"inApp", ^{
                    it(@"should be EMSLoggingInApp", ^{
                        [[((NSObject *) Emarsys.inApp) should] beKindOfClass:[EMSLoggingInApp class]];
                    });
                });

                describe(@"predict", ^{
                    it(@"should be EMSLoggingPredictInternal", ^{
                        [[((NSObject *) Emarsys.predict) should] beKindOfClass:[EMSLoggingPredictInternal class]];
                    });
                });

                describe(@"notificationCenterDelegate", ^{
                    it(@"should be EMSLoggingUserNotificationDelegate", ^{
                        [[((NSObject *) Emarsys.notificationCenterDelegate) should] beKindOfClass:[EMSLoggingUserNotificationDelegate class]];
                    });
                });

                describe(@"mobileEngage", ^{
                    it(@"should be EMSLoggingMobileEngageInternal", ^{
                        [[((NSObject *) EMSDependencyInjection.mobileEngage) should] beKindOfClass:[EMSLoggingMobileEngageInternal class]];
                    });
                });

                describe(@"deepLink", ^{
                    it(@"should be EMSDeepLinkInternal", ^{
                        [[((NSObject *) EMSDependencyInjection.deepLink) should] beKindOfClass:[EMSLoggingDeepLinkInternal class]];
                    });
                });
            });

        });

SPEC_END
