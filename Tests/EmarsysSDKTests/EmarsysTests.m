//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Kiwi.h"
#import "Emarsys.h"
#import "PredictInternal.h"
#import "MobileEngageInternal.h"
#import "EMSSQLiteHelper.h"
#import "EMSDBTriggerKey.h"
#import "EMSDependencyContainer.h"
#import "EmarsysTestUtils.h"
#import "EMSAbstractResponseHandler.h"
#import "MEIdResponseHandler.h"
#import "MEIAMResponseHandler.h"
#import "MEIAMCleanupResponseHandler.h"
#import "EMSVisitorIdResponseHandler.h"
#import "MobileEngageVersion.h"
#import "EMSDependencyInjection.h"
#import "MENotificationCenterManager.h"
#import "FakeDependencyContainer.h"
#import "AppStartBlockProvider.h"
#import "MERequestContext.h"

SPEC_BEGIN(EmarsysTests)

        __block MobileEngageInternal *engage;
        __block PredictInternal *predict;
        __block MERequestContext *requestContext;
        __block EMSRequestManager *requestManager;
        __block MENotificationCenterManager *notificationCenterManagerMock;
        __block AppStartBlockProvider *appStartBlockProvider;

        __block EMSConfig *baseConfig;
        __block id <EMSDependencyContainerProtocol> dependencyContainer;

        NSString *const customerId = @"customerId";

        beforeEach(^{
            engage = [MobileEngageInternal nullMock];
            predict = [PredictInternal nullMock];
            requestContext = [MERequestContext nullMock];
            [requestContext stub:@selector(meId) andReturn:@"fakeMeId"];
            requestManager = [EMSRequestManager nullMock];
            notificationCenterManagerMock = [MENotificationCenterManager nullMock];
            appStartBlockProvider = [AppStartBlockProvider nullMock];

            dependencyContainer = [[FakeDependencyContainer alloc] initWithDbHelper:nil
                                                                       mobileEngage:engage
                                                                              inbox:nil
                                                                                iam:nil
                                                                            predict:predict
                                                                     requestContext:requestContext
                                                                  requestRepository:nil
                                                                  notificationCache:nil
                                                                   responseHandlers:nil
                                                                     requestManager:requestManager
                                                                     operationQueue:nil
                                                          notificationCenterManager:notificationCenterManagerMock
                                                              appStartBlockProvider:appStartBlockProvider];

            [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                               withDependencyContainer:dependencyContainer];
        });

        afterEach(^{
            [EmarsysTestUtils tearDownEmarsys];
        });

        describe(@"setupWithConfig:", ^{

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

            it(@"register Predict trigger", ^{
                [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                                   withDependencyContainer:nil];

                NSDictionary *triggers = [[Emarsys sqliteHelper] registeredTriggers];

                NSArray *afterInsertTriggers = triggers[[[EMSDBTriggerKey alloc] initWithTableName:@"shard"
                                                                                         withEvent:[EMSDBTriggerEvent insertEvent]
                                                                                          withType:[EMSDBTriggerType afterType]]];
                [[theValue([afterInsertTriggers count]) should] equal:theValue(1)];
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

                it(@"should register MEIDResponseHandler if INAPP is turned on", ^{
                    [EmarsysTestUtils setupEmarsysWithFeatures:@[INAPP_MESSAGING] withDependencyContainer:nil];

                    BOOL registered = NO;
                    for (EMSAbstractResponseHandler *responseHandler in EMSDependencyInjection.dependencyContainer.responseHandlers) {
                        if ([responseHandler isKindOfClass:[MEIdResponseHandler class]]) {
                            registered = YES;
                        }
                    }

                    [[theValue(registered) should] beYes];
                });

                it(@"should register MEIDResponseHandler if USER_CENTRIC_INBOX is turned on", ^{
                    [EmarsysTestUtils setupEmarsysWithFeatures:@[USER_CENTRIC_INBOX] withDependencyContainer:nil];

                    BOOL registered = NO;
                    for (EMSAbstractResponseHandler *responseHandler in EMSDependencyInjection.dependencyContainer.responseHandlers) {
                        if ([responseHandler isKindOfClass:[MEIdResponseHandler class]]) {
                            registered = YES;
                        }
                    }

                    [[theValue(registered) should] beYes];
                });

                it(@"should  register MEIDResponseHandler only once if USER_CENTRIC_INBOX and INAPP is turned on", ^{
                    [EmarsysTestUtils setupEmarsysWithFeatures:@[INAPP_MESSAGING, USER_CENTRIC_INBOX]
                                       withDependencyContainer:nil];

                    NSUInteger registerCount = 0;
                    for (EMSAbstractResponseHandler *responseHandler in EMSDependencyInjection.dependencyContainer.responseHandlers) {
                        if ([responseHandler isKindOfClass:[MEIdResponseHandler class]]) {
                            registerCount++;
                        }
                    }

                    [[theValue(registerCount) should] equal:theValue(1)];
                });

                it(@"should register MEIAMResponseHandler if INAPP is turned on", ^{
                    [EmarsysTestUtils setupEmarsysWithFeatures:@[INAPP_MESSAGING] withDependencyContainer:nil];

                    BOOL registered = NO;
                    for (EMSAbstractResponseHandler *responseHandler in EMSDependencyInjection.dependencyContainer.responseHandlers) {
                        if ([responseHandler isKindOfClass:[MEIAMResponseHandler class]]) {
                            registered = YES;
                        }
                    }

                    [[theValue(registered) should] beYes];
                });

                it(@"should register MEIAMCleanupResponseHandler if INAPP is turned on", ^{
                    [EmarsysTestUtils setupEmarsysWithFeatures:@[INAPP_MESSAGING] withDependencyContainer:nil];

                    BOOL registered = NO;
                    for (EMSAbstractResponseHandler *responseHandler in EMSDependencyInjection.dependencyContainer.responseHandlers) {
                        if ([responseHandler isKindOfClass:[MEIAMCleanupResponseHandler class]]) {
                            registered = YES;
                        }
                    }

                    [[theValue(registered) should] beYes];
                });

                it(@"should not register MEIAMCleanupResponseHandler & MEIAMResponseHandler if INAPP is turned off", ^{
                    [EmarsysTestUtils setupEmarsysWithFeatures:@[] withDependencyContainer:nil];

                    NSUInteger registerCount = 0;
                    for (EMSAbstractResponseHandler *responseHandler in EMSDependencyInjection.dependencyContainer.responseHandlers) {
                        if ([responseHandler isKindOfClass:[MEIAMCleanupResponseHandler class]] || [responseHandler isKindOfClass:[MEIAMResponseHandler class]]) {
                            registerCount++;
                        }
                    }

                    [[theValue(registerCount) should] equal:theValue(0)];
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

                it(@"should register EMSVisitorIdResponseHandler if INAPP feature is turned on", ^{
                    [EmarsysTestUtils setupEmarsysWithFeatures:@[INAPP_MESSAGING] withDependencyContainer:nil];

                    NSUInteger registerCount = 0;
                    for (EMSAbstractResponseHandler *responseHandler in EMSDependencyInjection.dependencyContainer.responseHandlers) {
                        if ([responseHandler isKindOfClass:[EMSVisitorIdResponseHandler class]]) {
                            registerCount++;
                        }
                    }

                    [[theValue(registerCount) should] equal:theValue(1)];
                });

                it(@"should register EMSVisitorIdResponseHandler if USER_CENTRIC_INBOX feature is turned on", ^{
                    [EmarsysTestUtils setupEmarsysWithFeatures:@[USER_CENTRIC_INBOX] withDependencyContainer:nil];

                    NSUInteger registerCount = 0;
                    for (EMSAbstractResponseHandler *responseHandler in EMSDependencyInjection.dependencyContainer.responseHandlers) {
                        if ([responseHandler isKindOfClass:[EMSVisitorIdResponseHandler class]]) {
                            registerCount++;
                        }
                    }

                    [[theValue(registerCount) should] equal:theValue(1)];
                });
            });

            it(@"should set additionalHeaders on requestManager", ^{
                [EMSDependencyInjection tearDown];
                [EmarsysTestUtils setupEmarsysWithFeatures:@[] withDependencyContainer:nil];

                [[[EMSDependencyInjection.dependencyContainer.requestManager additionalHeaders] should] equal:@{
                    @"Content-Type": @"application/json",
                    @"X-MOBILEENGAGE-SDK-VERSION": MOBILEENGAGE_SDK_VERSION,
                    @"X-MOBILEENGAGE-SDK-MODE": @"debug"
                }];
            });

            context(@"appStart", ^{

                it(@"should register UIApplicationDidBecomeActiveNotification", ^{
                    void (^appStartBlock)() = ^{
                    };
                    [[appStartBlockProvider should] receive:@selector(createAppStartBlockWithRequestManager:requestContext:)
                                                  andReturn:appStartBlock
                                              withArguments:requestManager, requestContext];
                    [[notificationCenterManagerMock should] receive:@selector(addHandlerBlock:forNotification:)
                                                      withArguments:appStartBlock,
                                                                    UIApplicationDidBecomeActiveNotification];

                    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                                       withDependencyContainer:dependencyContainer];
                });

            });
        });

        describe(@"setAnonymousCustomerWithCompletionBlock:", ^{
            it(@"should delegate the call to mobileEngageInternal", ^{
                [[engage should] receive:@selector(appLoginWithCompletionBlock:)
                           withArguments:nil];
                [Emarsys setAnonymousCustomer];
            });

            it(@"should delegate the call to mobileEngageInternal", ^{
                EMSCompletionBlock completionBlock = ^(NSError *error) {
                };

                [[engage should] receive:@selector(appLoginWithCompletionBlock:)
                           withArguments:completionBlock];
                [Emarsys setAnonymousCustomerWithCompletionBlock:completionBlock];
            });
        });

        describe(@"setCustomerWithCustomerId:resultBlock:", ^{
            it(@"should delegate the call to predictInternal", ^{
                [[predict should] receive:@selector(setCustomerWithId:)
                            withArguments:customerId];
                [Emarsys setCustomerWithId:customerId];
            });

            it(@"should delegate the call to mobileEngageInternal", ^{
                [[engage should] receive:@selector(appLoginWithContactFieldValue:completionBlock:)
                           withArguments:customerId, kw_any()];
                [Emarsys setCustomerWithId:customerId];
            });

            it(@"should delegate the call to mobileEngageInternal with customerId and completionBlock", ^{
                void (^ const completionBlock)(NSError *) = ^(NSError *error) {
                };

                [[engage should] receive:@selector(appLoginWithContactFieldValue:completionBlock:)
                           withArguments:customerId, completionBlock];

                [Emarsys setCustomerWithId:customerId
                           completionBlock:completionBlock];
            });
        });

        describe(@"clearCustomer", ^{
            it(@"should delegate call to MobileEngage", ^{
                [[engage should] receive:@selector(appLogoutWithCompletionBlock:)];

                [Emarsys clearCustomer];
            });

            it(@"should delegate call to Predict", ^{
                [[predict should] receive:@selector(clearCustomer)];

                [Emarsys clearCustomer];
            });
        });

        describe(@"trackDeepLinkWithUserActivity:sourceHandler:", ^{

            it(@"should delegate call to MobileEngage", ^{
                NSUserActivity *userActivity = [NSUserActivity mock];
                EMSSourceHandler sourceHandler = ^(NSString *source) {
                };

                [[engage should] receive:@selector(trackDeepLinkWith:sourceHandler:)
                           withArguments:userActivity, sourceHandler];

                [Emarsys trackDeepLinkWithUserActivity:userActivity
                                         sourceHandler:sourceHandler];
            });
        });

        describe(@"trackCustomEventWithName:eventAttributes:completionBlock:", ^{

            it(@"should delegate call to MobileEngage with nil completionBlock", ^{
                NSString *eventName = @"eventName";
                NSDictionary<NSString *, NSString *> *eventAttributes = @{@"key": @"value"};

                [[engage should] receive:@selector(trackCustomEvent:eventAttributes:completionBlock:)
                           withArguments:eventName, eventAttributes, kw_any()];

                [Emarsys trackCustomEventWithName:eventName
                                  eventAttributes:eventAttributes];
            });

            it(@"should delegate call to MobileEngage", ^{
                NSString *eventName = @"eventName";
                NSDictionary<NSString *, NSString *> *eventAttributes = @{@"key": @"value"};
                EMSCompletionBlock completionBlock = ^(NSError *error) {
                };

                [[engage should] receive:@selector(trackCustomEvent:eventAttributes:completionBlock:)
                           withArguments:eventName, eventAttributes, completionBlock];

                [Emarsys trackCustomEventWithName:eventName
                                  eventAttributes:eventAttributes
                                  completionBlock:completionBlock];
            });
        });

        describe(@"trackMessageOpenWithUserInfo:completionBlock:", ^{

            NSDictionary *const userInfo = @{@"u": @"{\"sid\":\"dd8_zXfDdndBNEQi\"}"};

            it(@"should delegate call to MobileEngage with nil completionBlock", ^{
                [[engage should] receive:@selector(trackMessageOpenWithUserInfo:)
                           withArguments:userInfo];

                [Emarsys.push trackMessageOpenWithUserInfo:userInfo];
            });

            it(@"should delegate call to MobileEngage", ^{
                EMSCompletionBlock completionBlock = ^(NSError *error) {
                };

                [[engage should] receive:@selector(trackMessageOpenWithUserInfo:completionBlock:)
                           withArguments:userInfo, completionBlock];

                [Emarsys.push trackMessageOpenWithUserInfo:userInfo
                                           completionBlock:completionBlock];
            });
        });

        context(@"production setup", ^{

            beforeEach(^{
                [EMSDependencyInjection tearDown];
                [EmarsysTestUtils setupEmarsysWithFeatures:@[] withDependencyContainer:nil];
            });

            describe(@"push", ^{
                it(@"should not be nil", ^{
                    [[((NSObject *) Emarsys.push) shouldNot] beNil];
                });
            });

            describe(@"inbox", ^{
                it(@"should not be nil", ^{
                    [[((NSObject *) Emarsys.inbox) shouldNot] beNil];
                });
            });

            describe(@"inApp", ^{
                it(@"should not be nil", ^{
                    [[((NSObject *) Emarsys.inApp) shouldNot] beNil];
                });
            });

            describe(@"predict", ^{
                it(@"should not be nil", ^{
                    [[((NSObject *) Emarsys.predict) shouldNot] beNil];
                });
            });
        });

SPEC_END
