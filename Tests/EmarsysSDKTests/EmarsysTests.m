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

SPEC_BEGIN(EmarsysTests)

        __block PredictInternal *predict;
        __block MobileEngageInternal *engage;
        __block EMSDependencyContainer *container;
        NSString *const customerId = @"customerId";

        beforeEach(^{
            predict = [PredictInternal nullMock];
            engage = [MobileEngageInternal nullMock];
            container = [EMSDependencyContainer nullMock];

            EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                [builder setMobileEngageApplicationCode:@"applicationCode"
                                    applicationPassword:@"applicationPassword"];
                [builder setContactFieldId:@32];
                [builder setMerchantId:@"merchantId"];
            }];
            [Emarsys setupWithConfig:config];

            [container stub:@selector(mobileEngage)
                  andReturn:engage];
            [container stub:@selector(predict)
                  andReturn:predict];
            [Emarsys setDependencyContainer:container];
        });

        describe(@"setupWithConfig:", ^{

            it(@"should set predict", ^{
                [[(NSObject *) [Emarsys predict] shouldNot] beNil];
            });

            it(@"should set push", ^{
                [[(NSObject *) [Emarsys push] shouldNot] beNil];
            });

            it(@"register Predict trigger", ^{
                EMSConfig *configMock = [EMSConfig nullMock];
                [[configMock should] receive:@selector(merchantId) andReturn:@"merchantId"];
                [Emarsys setupWithConfig:configMock];

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

                afterEach(^{
                    [EmarsysTestUtils tearDownEmarsys];
                });

                it(@"should register MEIDResponseHandler if INAPP is turned on", ^{
                    [EmarsysTestUtils setUpEmarsysWithFeatures:@[INAPP_MESSAGING]];

                    BOOL registered = NO;
                    for (EMSAbstractResponseHandler *responseHandler in [Emarsys dependencyContainer].responseHandlers) {
                        if ([responseHandler isKindOfClass:[MEIdResponseHandler class]]) {
                            registered = YES;
                        }
                    }

                    [[theValue(registered) should] beYes];
                });

                it(@"should register MEIDResponseHandler if USER_CENTRIC_INBOX is turned on", ^{
                    [EmarsysTestUtils setUpEmarsysWithFeatures:@[USER_CENTRIC_INBOX]];

                    BOOL registered = NO;
                    for (EMSAbstractResponseHandler *responseHandler in [Emarsys dependencyContainer].responseHandlers) {
                        if ([responseHandler isKindOfClass:[MEIdResponseHandler class]]) {
                            registered = YES;
                        }
                    }

                    [[theValue(registered) should] beYes];
                });

                it(@"should  register MEIDResponseHandler only once if USER_CENTRIC_INBOX and INAPP is turned on", ^{
                    [EmarsysTestUtils setUpEmarsysWithFeatures:@[INAPP_MESSAGING, USER_CENTRIC_INBOX]];

                    NSUInteger registerCount = 0;
                    for (EMSAbstractResponseHandler *responseHandler in [Emarsys dependencyContainer].responseHandlers) {
                        if ([responseHandler isKindOfClass:[MEIdResponseHandler class]]) {
                            registerCount++;
                        }
                    }

                    [[theValue(registerCount) should] equal:theValue(1)];
                });

                it(@"should register MEIAMResponseHandler if INAPP is turned on", ^{
                    [EmarsysTestUtils setUpEmarsysWithFeatures:@[INAPP_MESSAGING]];

                    BOOL registered = NO;
                    for (EMSAbstractResponseHandler *responseHandler in [Emarsys dependencyContainer].responseHandlers) {
                        if ([responseHandler isKindOfClass:[MEIAMResponseHandler class]]) {
                            registered = YES;
                        }
                    }

                    [[theValue(registered) should] beYes];
                });

                it(@"should register MEIAMCleanupResponseHandler if INAPP is turned on", ^{
                    [EmarsysTestUtils setUpEmarsysWithFeatures:@[INAPP_MESSAGING]];

                    BOOL registered = NO;
                    for (EMSAbstractResponseHandler *responseHandler in [Emarsys dependencyContainer].responseHandlers) {
                        if ([responseHandler isKindOfClass:[MEIAMCleanupResponseHandler class]]) {
                            registered = YES;
                        }
                    }

                    [[theValue(registered) should] beYes];
                });

                it(@"should not register MEIAMCleanupResponseHandler & MEIAMResponseHandler if INAPP is turned off", ^{
                    [EmarsysTestUtils setUpEmarsysWithFeatures:@[]];

                    NSUInteger registerCount = 0;
                    for (EMSAbstractResponseHandler *responseHandler in [Emarsys dependencyContainer].responseHandlers) {
                        if ([responseHandler isKindOfClass:[MEIAMCleanupResponseHandler class]] || [responseHandler isKindOfClass:[MEIAMResponseHandler class]]) {
                            registerCount++;
                        }
                    }

                    [[theValue(registerCount) should] equal:theValue(0)];
                });

                it(@"should register EMSVisitorIdResponseHandler if no features are turned on", ^{
                    [EmarsysTestUtils setUpEmarsysWithFeatures:@[]];

                    NSUInteger registerCount = 0;
                    for (EMSAbstractResponseHandler *responseHandler in [Emarsys dependencyContainer].responseHandlers) {
                        if ([responseHandler isKindOfClass:[EMSVisitorIdResponseHandler class]]) {
                            registerCount++;
                        }
                    }

                    [[theValue(registerCount) should] equal:theValue(1)];
                });

                it(@"should register EMSVisitorIdResponseHandler if INAPP feature is turned on", ^{
                    [EmarsysTestUtils setUpEmarsysWithFeatures:@[INAPP_MESSAGING]];

                    NSUInteger registerCount = 0;
                    for (EMSAbstractResponseHandler *responseHandler in [Emarsys dependencyContainer].responseHandlers) {
                        if ([responseHandler isKindOfClass:[EMSVisitorIdResponseHandler class]]) {
                            registerCount++;
                        }
                    }

                    [[theValue(registerCount) should] equal:theValue(1)];
                });

                it(@"should register EMSVisitorIdResponseHandler if USER_CENTRIC_INBOX feature is turned on", ^{
                    [EmarsysTestUtils setUpEmarsysWithFeatures:@[USER_CENTRIC_INBOX]];

                    NSUInteger registerCount = 0;
                    for (EMSAbstractResponseHandler *responseHandler in [Emarsys dependencyContainer].responseHandlers) {
                        if ([responseHandler isKindOfClass:[EMSVisitorIdResponseHandler class]]) {
                            registerCount++;
                        }
                    }

                    [[theValue(registerCount) should] equal:theValue(1)];
                });
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
                EMSConfig *configMock = [EMSConfig nullMock];
                [[configMock should] receive:@selector(merchantId) andReturn:@"merchantId"];
                [Emarsys setupWithConfig:configMock];
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
