#import "Kiwi.h"
#import <UserNotifications/UserNotifications.h>
#import "MEUserNotificationDelegate.h"
#import "MEInAppMessage.h"
#import "EMSWaiter.h"
#import "MEInApp.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSPushNotificationProtocol.h"
#import "EMSRequestManager.h"
#import "EMSRequestFactory.h"
#import "EMSMobileEngageV3Internal.h"

@interface MEUserNotificationDelegate ()

- (NSDictionary *)actionFromResponse:(UNNotificationResponse *)response;

@end

SPEC_BEGIN(MEUserNotificationDelegateTests)
        id (^notificationResponseWithUserInfoWithActionId)(NSDictionary *userInfo, NSString *actionId) = ^id(NSDictionary *userInfo, NSString *actionId) {
            UNNotificationResponse *response = [UNNotificationResponse mock];
            UNNotification *notification = [UNNotification mock];
            UNNotificationRequest *request = [UNNotificationRequest mock];
            UNNotificationContent *content = [UNNotificationContent mock];
            [response stub:@selector(notification) andReturn:notification];
            [response stub:@selector(actionIdentifier) andReturn:actionId];
            [notification stub:@selector(request) andReturn:request];
            [request stub:@selector(content) andReturn:content];
            [content stub:@selector(userInfo) andReturn:userInfo];
            return response;
        };

        id (^notificationResponseWithUserInfo)(NSDictionary *userInfo) = ^id(NSDictionary *userInfo) {
            return notificationResponseWithUserInfoWithActionId(userInfo, @"uniqueId");
        };

        __block id application;
        __block id mobileEngageInternal;
        __block id inApp;
        __block id timestampProvider;
        __block id uuidProvider;
        __block id pushInternal;
        __block id requestManager;
        __block id requestFactory;

        beforeEach(^{
            application = [UIApplication mock];
            mobileEngageInternal = [EMSMobileEngageV3Internal mock];
            inApp = [MEInApp mock];
            timestampProvider = [EMSTimestampProvider nullMock];
            uuidProvider = [EMSUUIDProvider nullMock];
            pushInternal = [KWMock nullMockForProtocol:@protocol(EMSPushNotificationProtocol)];
            requestManager = [EMSRequestManager nullMock];
            requestFactory = [EMSRequestFactory nullMock];
        });

        describe(@"init", ^{

            it(@"should throw an exception when there is no application", ^{
                @try {
                    [[MEUserNotificationDelegate alloc] initWithApplication:nil
                                                       mobileEngageInternal:mobileEngageInternal
                                                                      inApp:inApp
                                                          timestampProvider:timestampProvider
                                                               uuidProvider:uuidProvider
                                                               pushInternal:pushInternal
                                                             requestManager:requestManager
                                                             requestFactory:requestFactory];
                    fail(@"Expected Exception when application is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: application"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw an exception when there is no mobileEngageInternal", ^{
                @try {
                    [[MEUserNotificationDelegate alloc] initWithApplication:application
                                                       mobileEngageInternal:nil
                                                                      inApp:inApp
                                                          timestampProvider:timestampProvider
                                                               uuidProvider:uuidProvider
                                                               pushInternal:pushInternal
                                                             requestManager:requestManager
                                                             requestFactory:requestFactory];
                    fail(@"Expected Exception when mobileEngage is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: mobileEngage"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw an exception when there is no inApp", ^{
                @try {
                    [[MEUserNotificationDelegate alloc] initWithApplication:application
                                                       mobileEngageInternal:mobileEngageInternal
                                                                      inApp:nil
                                                          timestampProvider:timestampProvider
                                                               uuidProvider:uuidProvider
                                                               pushInternal:pushInternal
                                                             requestManager:requestManager
                                                             requestFactory:requestFactory];
                    fail(@"Expected Exception when inApp is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: inApp"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw an exception when there is no timestampProvider", ^{
                @try {
                    [[MEUserNotificationDelegate alloc] initWithApplication:application
                                                       mobileEngageInternal:mobileEngageInternal
                                                                      inApp:inApp
                                                          timestampProvider:nil
                                                               uuidProvider:uuidProvider
                                                               pushInternal:pushInternal
                                                             requestManager:requestManager
                                                             requestFactory:requestFactory];
                    fail(@"Expected Exception when timestampProvider is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: timestampProvider"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw an exception when there is no uuidProvider", ^{
                @try {
                    [[MEUserNotificationDelegate alloc] initWithApplication:application
                                                       mobileEngageInternal:mobileEngageInternal
                                                                      inApp:inApp
                                                          timestampProvider:timestampProvider
                                                               uuidProvider:nil
                                                               pushInternal:pushInternal
                                                             requestManager:requestManager
                                                             requestFactory:requestFactory];
                    fail(@"Expected Exception when uuidProvider is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: uuidProvider"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw an exception when there is no pushInternal", ^{
                @try {
                    [[MEUserNotificationDelegate alloc] initWithApplication:[UIApplication mock]
                                                       mobileEngageInternal:[EMSMobileEngageV3Internal mock]
                                                                      inApp:[MEInApp mock]
                                                          timestampProvider:[EMSTimestampProvider mock]
                                                               uuidProvider:uuidProvider
                                                               pushInternal:nil
                                                             requestManager:[EMSRequestManager mock]
                                                             requestFactory:[EMSRequestFactory mock]];
                    fail(@"Expected Exception when pushInternal is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: pushInternal"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });
            it(@"should throw an exception when there is no requestManager", ^{
                @try {
                    [[MEUserNotificationDelegate alloc] initWithApplication:application
                                                       mobileEngageInternal:mobileEngageInternal
                                                                      inApp:inApp
                                                          timestampProvider:timestampProvider
                                                               uuidProvider:uuidProvider
                                                               pushInternal:pushInternal
                                                             requestManager:nil
                                                             requestFactory:requestFactory];
                    fail(@"Expected Exception when requestManager is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: requestManager"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });
            it(@"should throw an exception when there is no requestFactory", ^{
                @try {
                    [[MEUserNotificationDelegate alloc] initWithApplication:application
                                                       mobileEngageInternal:mobileEngageInternal
                                                                      inApp:inApp
                                                          timestampProvider:timestampProvider
                                                               uuidProvider:uuidProvider
                                                               pushInternal:pushInternal
                                                             requestManager:requestManager
                                                             requestFactory:nil];
                    fail(@"Expected Exception when requestFactory is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: requestFactory"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });
        });

        describe(@"userNotificationCenter:willPresentNotification:withCompletionHandler:", ^{

            it(@"should call the injected delegate's userNotificationCenter:willPresentNotification:withCompletionHandler: method", ^{
                id userNotificationCenterDelegate = [KWMock mockForProtocol:@protocol(UNUserNotificationCenterDelegate)];
                UNUserNotificationCenter *mockCenter = [UNUserNotificationCenter mock];
                UNNotification *mockNotification = [UNNotification mock];
                void (^ const completionHandler)(UNNotificationPresentationOptions) =^(UNNotificationPresentationOptions options) {
                };

                [[userNotificationCenterDelegate should] receive:@selector(userNotificationCenter:willPresentNotification:withCompletionHandler:)
                                                   withArguments:mockCenter,
                                                                 mockNotification,
                                                                 completionHandler];

                MEUserNotificationDelegate *userNotification = [MEUserNotificationDelegate new];
                userNotification.delegate = userNotificationCenterDelegate;

                [userNotification userNotificationCenter:mockCenter
                                 willPresentNotification:mockNotification
                                   withCompletionHandler:completionHandler];
            });

            it(@"should call completion handler with UNNotificationPresentationOptionAlert", ^{
                MEUserNotificationDelegate *userNotification = [MEUserNotificationDelegate new];
                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                __block UNNotificationPresentationOptions _option;
                [userNotification userNotificationCenter:[UNUserNotificationCenter mock]
                                 willPresentNotification:nil
                                   withCompletionHandler:^(UNNotificationPresentationOptions options) {
                                       _option = options;
                                       [exp fulfill];
                                   }];

                XCTWaiterResult result = [XCTWaiter waitForExpectations:@[exp] timeout:5];
                [[theValue(result) should] equal:theValue(XCTWaiterResultCompleted)];
                [[theValue(_option) should] equal:theValue(UNNotificationPresentationOptionAlert)];
            });

        });

        describe(@"userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:", ^{

            it(@"should call the injected delegate's userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler: method", ^{
                id userNotificationCenterDelegate = [KWMock mockForProtocol:@protocol(UNUserNotificationCenterDelegate)];
                UNUserNotificationCenter *center = [UNUserNotificationCenter nullMock];
                UNNotificationResponse *notificationResponse = [UNNotificationResponse nullMock];
                void (^ const completionHandler)(void) =^{
                };

                [[userNotificationCenterDelegate should] receive:@selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:)
                                                   withArguments:center,
                                                                 notificationResponse,
                                                                 completionHandler];

                MEUserNotificationDelegate *userNotification = [[MEUserNotificationDelegate alloc] initWithApplication:[UIApplication mock]
                                                                                                  mobileEngageInternal:[EMSMobileEngageV3Internal nullMock]
                                                                                                                 inApp:[MEInApp nullMock]
                                                                                                     timestampProvider:[EMSTimestampProvider nullMock]
                                                                                                          uuidProvider:uuidProvider
                                                                                                          pushInternal:pushInternal
                                                                                                        requestManager:requestManager
                                                                                                        requestFactory:requestFactory];
                userNotification.delegate = userNotificationCenterDelegate;

                [userNotification userNotificationCenter:center
                          didReceiveNotificationResponse:notificationResponse
                                   withCompletionHandler:completionHandler];
            });

            it(@"should call completion handler", ^{
                MEUserNotificationDelegate *userNotification = [MEUserNotificationDelegate new];
                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [userNotification userNotificationCenter:[UNUserNotificationCenter mock]
                          didReceiveNotificationResponse:nil
                                   withCompletionHandler:^{
                                       [exp fulfill];
                                   }];

                XCTWaiterResult result = [XCTWaiter waitForExpectations:@[exp] timeout:5];
                [[theValue(result) should] equal:theValue(XCTWaiterResultCompleted)];
            });

            it(@"should call MobileEngage.notification.eventHandler with the defined eventName and payload if the action is type of MEAppEvent", ^{
                id eventHandlerMock = [KWMock mockForProtocol:@protocol(EMSEventHandler)];
                NSString *eventName = @"testEventName";
                NSDictionary *payload = @{@"key1": @"value1", @"key2": @"value2", @"key3": @"value3"};
                [[eventHandlerMock should] receive:@selector(handleEvent:payload:)
                                     withArguments:eventName,
                                                   payload];

                MEUserNotificationDelegate *userNotification = [MEUserNotificationDelegate new];
                userNotification.eventHandler = eventHandlerMock;

                NSDictionary *userInfo = @{@"ems": @{
                    @"actions": @[
                        @{
                            @"id": @"uniqueId",
                            @"title": @"actionTitle",
                            @"type": @"MEAppEvent",
                            @"name": eventName,
                            @"payload": payload
                        }
                    ]},
                    @"u": @"{\"sid\": \"123456789\"}"
                };

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [userNotification userNotificationCenter:[UNUserNotificationCenter mock]
                          didReceiveNotificationResponse:notificationResponseWithUserInfo(userInfo)
                                   withCompletionHandler:^{
                                       [exp fulfill];
                                   }];
                [EMSWaiter waitForExpectations:@[exp] timeout:5];
            });

            it(@"should not call MobileEngage.notification.eventHandler with the defined eventName and payload if the action is not MEAppEvent type", ^{
                id eventHandlerMock = [KWMock mockForProtocol:@protocol(EMSEventHandler)];
                [[eventHandlerMock shouldNot] receive:@selector(handleEvent:payload:)];

                MEUserNotificationDelegate *userNotification = [MEUserNotificationDelegate new];
                userNotification.eventHandler = eventHandlerMock;

                NSDictionary *userInfo = @{@"ems": @{
                    @"actions": @[
                        @{
                            @"id": @"uniqueId",
                            @"title": @"actionTitle",
                            @"type": @"someStuff",
                            @"name": @"testEventName",
                            @"payload": @{@"key1": @"value1", @"key2": @"value2", @"key3": @"value3"}
                        }
                    ]},
                    @"u": @"{\"sid\": \"123456789\"}"
                };

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [userNotification userNotificationCenter:[UNUserNotificationCenter mock]
                          didReceiveNotificationResponse:notificationResponseWithUserInfo(userInfo)
                                   withCompletionHandler:^{
                                       [exp fulfill];
                                   }];
                [EMSWaiter waitForExpectations:@[exp] timeout:5];
            });

            it(@"should call trackCustomEvent on MobileEngage with the defined eventName and payload if the action is type of MECustomEvent", ^{
                NSString *eventName = @"testEventName";
                NSDictionary *payload = @{@"key1": @"value1", @"key2": @"value2", @"key3": @"value3"};
                EMSMobileEngageV3Internal *mobileEngage = [EMSMobileEngageV3Internal nullMock];

                MEUserNotificationDelegate *userNotification = [[MEUserNotificationDelegate alloc] initWithApplication:[UIApplication mock]
                                                                                                  mobileEngageInternal:mobileEngage
                                                                                                                 inApp:[MEInApp nullMock]
                                                                                                     timestampProvider:[EMSTimestampProvider nullMock]
                                                                                                          uuidProvider:uuidProvider
                                                                                                          pushInternal:pushInternal
                                                                                                        requestManager:requestManager
                                                                                                        requestFactory:requestFactory];

                NSDictionary *userInfo = @{@"ems": @{
                    @"actions": @[
                        @{
                            @"id": @"uniqueId",
                            @"title": @"actionTitle",
                            @"type": @"MECustomEvent",
                            @"name": eventName,
                            @"payload": payload
                        }
                    ]},
                    @"u": @"{\"sid\": \"123456789\"}"
                };
                [[mobileEngage should] receive:@selector(trackCustomEventWithName:eventAttributes:completionBlock:)
                                 withArguments:eventName,
                                               payload, kw_any()];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [userNotification userNotificationCenter:[UNUserNotificationCenter mock]
                          didReceiveNotificationResponse:notificationResponseWithUserInfo(userInfo)
                                   withCompletionHandler:^{
                                       [exp fulfill];
                                   }];
                [EMSWaiter waitForExpectations:@[exp] timeout:5];

            });

            it(@"should call track click with richNotification:actionClicked eventName and title and action id in the payload", ^{
                EMSMobileEngageV3Internal *mobileEngage = [EMSMobileEngageV3Internal nullMock];
                MEUserNotificationDelegate *userNotification = [[MEUserNotificationDelegate alloc] initWithApplication:[UIApplication mock]
                                                                                                  mobileEngageInternal:mobileEngage
                                                                                                                 inApp:[MEInApp nullMock]
                                                                                                     timestampProvider:[EMSTimestampProvider nullMock]
                                                                                                          uuidProvider:uuidProvider
                                                                                                          pushInternal:pushInternal
                                                                                                        requestManager:requestManager
                                                                                                        requestFactory:requestFactory];
                NSDictionary *userInfo = @{@"ems": @{
                    @"actions": @[
                        @{
                            @"id": @"uniqueId",
                            @"title": @"actionTitle",
                            @"key": @"value"
                        }
                    ]}, @"u": @"{\"sid\": \"123456789\"}"
                };

                EMSRequestModel *requestModel = [EMSRequestModel mock];

                [[requestFactory should] receive:@selector(createEventRequestModelWithEventName:eventAttributes:eventType:)
                                       andReturn:requestModel
                                   withArguments:@"push:click",
                                                 @{
                                                     @"origin": @"button",
                                                     @"button_id": @"uniqueId",
                                                     @"sid": @"123456789"
                                                 },
                        theValue(EventTypeInternal)];

                [[requestManager should] receive:@selector(submitRequestModel:withCompletionBlock:)
                                   withArguments:requestModel, kw_any()];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [userNotification userNotificationCenter:[UNUserNotificationCenter mock]
                          didReceiveNotificationResponse:notificationResponseWithUserInfo(userInfo)
                                   withCompletionHandler:^{
                                       [exp fulfill];
                                   }];
                [EMSWaiter waitForExpectations:@[exp] timeout:5];

            });

            it(@"should call mobileEngage with the correct action", ^{
                EMSMobileEngageV3Internal *mockMEInternal = [EMSMobileEngageV3Internal nullMock];
                MEUserNotificationDelegate *userNotification = [[MEUserNotificationDelegate alloc] initWithApplication:[UIApplication mock]
                                                                                                  mobileEngageInternal:mockMEInternal
                                                                                                                 inApp:[MEInApp nullMock]
                                                                                                     timestampProvider:[EMSTimestampProvider nullMock]
                                                                                                          uuidProvider:uuidProvider
                                                                                                          pushInternal:pushInternal
                                                                                                        requestManager:requestManager
                                                                                                        requestFactory:requestFactory];

                NSDictionary *payload = @{@"key1": @"value1", @"key2": @"value2", @"key3": @"value3"};
                NSString *eventName = @"eventName";
                NSDictionary *userInfo = @{@"ems": @{@"actions": @[
                    @{
                        @"id": @"uniqueId",
                        @"title": @"actionTitle",
                        @"type": @"OpenExternalUrl",
                        @"url": @"https://www.emarsys.com"
                    }, @{
                        @"id": @"uniqueId2",
                        @"title": @"actionTitle",
                        @"type": @"MECustomEvent",
                        @"name": eventName,
                        @"payload": payload
                    }
                ]},
                    @"u": @"{\"sid\": \"123456789\"}"
                };

                [[mockMEInternal should] receive:@selector(trackCustomEventWithName:eventAttributes:completionBlock:)
                                   withArguments:eventName,
                                                 payload, kw_any()];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [userNotification userNotificationCenter:[UNUserNotificationCenter mock]
                          didReceiveNotificationResponse:notificationResponseWithUserInfoWithActionId(userInfo, @"uniqueId2")
                                   withCompletionHandler:^{
                                       [exp fulfill];
                                   }];
                [EMSWaiter waitForExpectations:@[exp] timeout:5];

            });

            it(@"should call trackMessageOpenWithUserInfo on MobileEngage with the userInfo when didReceiveNotificationResponse:withCompletionHandler: is called", ^{
                EMSMobileEngageV3Internal *mobileEngage = [EMSMobileEngageV3Internal nullMock];

                MEUserNotificationDelegate *notificationDelegate = [[MEUserNotificationDelegate alloc] initWithApplication:[UIApplication mock]
                                                                                                      mobileEngageInternal:mobileEngage
                                                                                                                     inApp:[MEInApp nullMock]
                                                                                                         timestampProvider:[EMSTimestampProvider nullMock]
                                                                                                              uuidProvider:uuidProvider
                                                                                                              pushInternal:pushInternal
                                                                                                            requestManager:requestManager
                                                                                                            requestFactory:requestFactory];
                NSDictionary *userInfo = @{@"ems": @{
                    @"u": @{
                        @"sid": @"123456789"
                    }}};
                [[pushInternal should] receive:@selector(trackMessageOpenWithUserInfo:)
                                 withArguments:userInfo];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [notificationDelegate userNotificationCenter:nil
                              didReceiveNotificationResponse:notificationResponseWithUserInfo(userInfo)
                                       withCompletionHandler:^{
                                           [exp fulfill];
                                       }];
                [EMSWaiter waitForExpectations:@[exp] timeout:5];

            });

            it(@"should call openURL:options:completionHandler: with the defined url if the action is type of OpenExternalUrl", ^{
                UIApplication *application = [UIApplication mock];
                [[application should] receive:@selector(openURL:options:completionHandler:)
                                withArguments:[NSURL URLWithString:@"https://www.emarsys.com"],
                                              @{}, kw_any()];

                MEUserNotificationDelegate *userNotification = [[MEUserNotificationDelegate alloc] initWithApplication:application
                                                                                                  mobileEngageInternal:[EMSMobileEngageV3Internal nullMock]
                                                                                                                 inApp:[MEInApp nullMock]
                                                                                                     timestampProvider:[EMSTimestampProvider nullMock]
                                                                                                          uuidProvider:uuidProvider
                                                                                                          pushInternal:pushInternal
                                                                                                        requestManager:requestManager
                                                                                                        requestFactory:requestFactory];
                NSDictionary *userInfo = @{@"ems": @{@"actions": @[
                    @{
                        @"id": @"uniqueId",
                        @"title": @"actionTitle",
                        @"type": @"OpenExternalUrl",
                        @"url": @"https://www.emarsys.com"
                    }
                ]}, @"u": @"{\"sid\": \"123456789\"}"};

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [userNotification userNotificationCenter:[UNUserNotificationCenter mock]
                          didReceiveNotificationResponse:notificationResponseWithUserInfo(userInfo)
                                   withCompletionHandler:^{
                                       [exp fulfill];
                                   }];
                [EMSWaiter waitForExpectations:@[exp] timeout:5];
            });

            it(@"should call showMessage:completionHandler: on IAM with InAppMessage when didReceiveNotificationResponse:withCompletionHandler: is called with inApp payload", ^{
                NSDate *responseTimestamp = [NSDate date];
                [[timestampProvider should] receive:@selector(provideTimestamp) andReturn:responseTimestamp];
                MEInAppMessage *inAppMessage = [[MEInAppMessage alloc] initWithCampaignId:@"42"
                                                                                      sid:@"123456789"
                                                                                      url:@"https://www.test.com"
                                                                                     html:@"<html/>"
                                                                        responseTimestamp:responseTimestamp];
                KWCaptureSpy *messageSpy = [inApp captureArgument:@selector(showMessage:completionHandler:) atIndex:0];
                MEUserNotificationDelegate *notificationDelegate = [[MEUserNotificationDelegate alloc] initWithApplication:[UIApplication mock]
                                                                                                      mobileEngageInternal:[EMSMobileEngageV3Internal nullMock]
                                                                                                                     inApp:inApp
                                                                                                         timestampProvider:timestampProvider
                                                                                                              uuidProvider:uuidProvider
                                                                                                              pushInternal:pushInternal
                                                                                                            requestManager:requestManager
                                                                                                            requestFactory:requestFactory];
                NSDictionary *userInfo = @{@"ems": @{
                    @"inapp": @{
                        @"campaign_id": @"42",
                        @"url": @"https://www.test.com",
                        @"inAppData": [@"<html/>" dataUsingEncoding:NSUTF8StringEncoding]
                    }},
                    @"u": @"{\"sid\": \"123456789\"}"};

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [notificationDelegate userNotificationCenter:nil
                              didReceiveNotificationResponse:notificationResponseWithUserInfo(userInfo)
                                       withCompletionHandler:^{
                                           [exp fulfill];
                                       }];
                [EMSWaiter waitForExpectations:@[exp] timeout:5];
                MEInAppMessage *message = [messageSpy argument];
                [[message.campaignId should] equal:@"42"];
                [[message.sid should] equal:@"123456789"];
                [[message.url should] equal:@"https://www.test.com"];
                [[message.html should] equal:@"<html/>"];
                [[message.responseTimestamp should] equal:responseTimestamp];
            });

            it(@"should download inapp and trigger it when inAppData missing", ^{
                NSDate *responseTimestamp = [NSDate date];
                [[timestampProvider should] receive:@selector(provideTimestamp)
                                          andReturn:responseTimestamp
                                          withCount:2];

                NSDictionary *userInfo = @{@"ems": @{
                    @"inapp": @{
                        @"campaign_id": @"42",
                        @"url": @"https://www.test.com"
                    }},
                    @"u": @"{\"sid\": \"123456789\"}"};

                KWCaptureSpy *spy = [requestManager captureArgument:@selector(submitRequestModelNow:successBlock:errorBlock:)
                                                            atIndex:1];

                MEUserNotificationDelegate *notificationDelegate = [[MEUserNotificationDelegate alloc] initWithApplication:[UIApplication mock]
                                                                                                      mobileEngageInternal:[EMSMobileEngageV3Internal nullMock]
                                                                                                                     inApp:inApp
                                                                                                         timestampProvider:timestampProvider
                                                                                                              uuidProvider:uuidProvider
                                                                                                              pushInternal:pushInternal
                                                                                                            requestManager:requestManager
                                                                                                            requestFactory:requestFactory];

                [notificationDelegate userNotificationCenter:nil
                              didReceiveNotificationResponse:notificationResponseWithUserInfo(userInfo)
                                       withCompletionHandler:^{
                                       }];

                CoreSuccessBlock successBlock = spy.argument;

                EMSResponseModel *responseModel = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                       headers:@{}
                                                                                          body:[@"<html/>" dataUsingEncoding:NSUTF8StringEncoding]
                                                                                  requestModel:[EMSRequestModel nullMock]
                                                                                     timestamp:responseTimestamp];

                MEInAppMessage *inAppMessage = [[MEInAppMessage alloc] initWithCampaignId:@"42"
                                                                                      sid:@"123456789"
                                                                                      url:@"https://www.test.com"
                                                                                     html:@"<html/>"
                                                                        responseTimestamp:responseTimestamp];

                [[inApp should] receive:@selector(showMessage:completionHandler:) withArguments:inAppMessage, kw_any()];

                successBlock(@"testRequestId", responseModel);
            });

            it(@"should call mobileEngage with default action", ^{
                EMSMobileEngageV3Internal *mockMEInternal = [EMSMobileEngageV3Internal nullMock];
                MEUserNotificationDelegate *userNotification = [[MEUserNotificationDelegate alloc] initWithApplication:[UIApplication mock]
                                                                                                  mobileEngageInternal:mockMEInternal
                                                                                                                 inApp:[MEInApp nullMock]
                                                                                                     timestampProvider:[EMSTimestampProvider nullMock]
                                                                                                          uuidProvider:uuidProvider
                                                                                                          pushInternal:pushInternal
                                                                                                        requestManager:requestManager
                                                                                                        requestFactory:requestFactory];
                NSDictionary *payload = @{@"key1": @"value1", @"key2": @"value2", @"key3": @"value3"};
                NSString *eventName = @"eventName";
                NSDictionary *defaultAction = @{
                    @"type": @"MECustomEvent",
                    @"name": eventName,
                    @"payload": payload
                };
                NSDictionary *userInfo = @{@"ems": @{
                    @"default_action": defaultAction,
                    @"actions": @[
                        @{
                            @"id": @"uniqueId",
                            @"title": @"actionTitle",
                            @"type": @"OpenExternalUrl",
                            @"url": @"https://www.emarsys.com"
                        }
                    ]},
                    @"u": @"{\"sid\": \"123456789\"}"
                };

                [[mockMEInternal should] receive:@selector(trackCustomEventWithName:eventAttributes:completionBlock:)
                                   withArguments:eventName,
                                                 payload, kw_any()];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [userNotification userNotificationCenter:[UNUserNotificationCenter mock]
                          didReceiveNotificationResponse:notificationResponseWithUserInfoWithActionId(userInfo, UNNotificationDefaultActionIdentifier)
                                   withCompletionHandler:^{
                                       [exp fulfill];
                                   }];
                [EMSWaiter waitForExpectations:@[exp]
                                       timeout:5];
            });
        });

        describe(@"actionFromResponse:", ^{

            it(@"should return the default action when the action identifier is UNNotificationDefaultActionIdentifier", ^{
                MEUserNotificationDelegate *userNotification = [[MEUserNotificationDelegate alloc] initWithApplication:[UIApplication mock]
                                                                                                  mobileEngageInternal:[EMSMobileEngageV3Internal nullMock]
                                                                                                                 inApp:[MEInApp nullMock]
                                                                                                     timestampProvider:[EMSTimestampProvider nullMock]
                                                                                                          uuidProvider:uuidProvider
                                                                                                          pushInternal:pushInternal
                                                                                                        requestManager:requestManager
                                                                                                        requestFactory:requestFactory];
                NSDictionary *expectedAction = @{
                    @"type": @"MEAppEvent",
                    @"name": @"nameValue",
                    @"payload": @{
                        @"someKey": @"someValue"
                    }
                };
                NSDictionary *userInfo = @{@"ems": @{
                    @"default_action": expectedAction,
                    @"actions": @[
                        @{
                            @"id": @"uniqueId",
                            @"title": @"actionTitle",
                            @"type": @"OpenExternalUrl",
                            @"url": @"https://www.emarsys.com"
                        }
                    ]
                }, @"u": @"{\"sid\": \"123456789\"}"};

                NSDictionary *action = [userNotification actionFromResponse:notificationResponseWithUserInfoWithActionId(userInfo, UNNotificationDefaultActionIdentifier)];

                [[action should] equal:expectedAction];
            });

            it(@"should return nil when the action identifier is not UNNotificationDefaultActionIdentifier and no custom actions", ^{
                MEUserNotificationDelegate *userNotification = [[MEUserNotificationDelegate alloc] initWithApplication:[UIApplication mock]
                                                                                                  mobileEngageInternal:[EMSMobileEngageV3Internal nullMock]
                                                                                                                 inApp:[MEInApp nullMock]
                                                                                                     timestampProvider:[EMSTimestampProvider nullMock]
                                                                                                          uuidProvider:uuidProvider
                                                                                                          pushInternal:pushInternal
                                                                                                        requestManager:requestManager
                                                                                                        requestFactory:requestFactory];
                NSDictionary *expectedAction = @{
                    @"type": @"MEAppEvent",
                    @"name": @"nameValue",
                    @"payload": @{
                        @"someKey": @"someValue"
                    }
                };
                NSDictionary *userInfo = @{@"ems": @{
                    @"default_action": expectedAction,
                    @"actions": @[
                        @{
                            @"id": @"uniqueId",
                            @"title": @"actionTitle",
                            @"type": @"OpenExternalUrl",
                            @"url": @"https://www.emarsys.com"
                        }
                    ]
                }, @"u": @"{\"sid\": \"123456789\"}"};

                NSDictionary *action = [userNotification actionFromResponse:notificationResponseWithUserInfoWithActionId(userInfo, UNNotificationDismissActionIdentifier)];

                [[action should] beNil];
            });
        });

SPEC_END
