#import <UserNotifications/UserNotifications.h>
#import "Kiwi.h"
#import "MEUserNotificationDelegate.h"
#import "MEInAppMessage.h"
#import "EMSWaiter.h"
#import "MEInApp.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSPushNotificationProtocol.h"
#import "EMSRequestManager.h"
#import "EMSRequestFactory.h"
#import "EMSActionFactory.h"

@interface MEUserNotificationDelegate ()

- (NSDictionary *)actionFromResponse:(UNNotificationResponse *)response;

@end

@interface FakeNotificationDelegate : NSObject <UNUserNotificationCenterDelegate>

@property(nonatomic, strong) void (^willPresentBlock)(NSOperationQueue *operationQueue);
@property(nonatomic, strong) void (^didReceiveBlock)(NSOperationQueue *operationQueue);

@end

@implementation FakeNotificationDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    if (self.willPresentBlock) {
        self.willPresentBlock([NSOperationQueue currentQueue]);
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {
    if (self.didReceiveBlock) {
        self.didReceiveBlock([NSOperationQueue currentQueue]);
    }
}

@end

SPEC_BEGIN(MEUserNotificationDelegateTests)

        id (^notificationResponseWithUserInfoWithActionId)(NSDictionary *userInfo, NSString *actionId) = ^id(NSDictionary *userInfo, NSString *actionId) {
            UNNotificationResponse *response = [UNNotificationResponse mock];
            UNNotification *notification = [UNNotification mock];
            UNNotificationRequest *request = [UNNotificationRequest mock];
            UNNotificationContent *content = [UNNotificationContent mock];
            [response stub:@selector(notification)
                 andReturn:notification];
            [response stub:@selector(actionIdentifier)
                 andReturn:actionId];
            [notification stub:@selector(request)
                     andReturn:request];
            [request stub:@selector(content)
                andReturn:content];
            [content stub:@selector(userInfo)
                andReturn:userInfo];
            return response;
        };

        id (^notificationResponseWithUserInfo)(NSDictionary *userInfo) = ^id(NSDictionary *userInfo) {
            return notificationResponseWithUserInfoWithActionId(userInfo, @"uniqueId");
        };

        __block id actionFactory;
        __block id inApp;
        __block id timestampProvider;
        __block id uuidProvider;
        __block id pushInternal;
        __block id requestManager;
        __block id requestFactory;
        __block NSOperationQueue *operationQueue;

        beforeEach(^{
            actionFactory = [EMSActionFactory nullMock];
            inApp = [MEInApp mock];
            timestampProvider = [EMSTimestampProvider nullMock];
            uuidProvider = [EMSUUIDProvider nullMock];
            pushInternal = [KWMock nullMockForProtocol:@protocol(EMSPushNotificationProtocol)];
            requestManager = [EMSRequestManager nullMock];
            requestFactory = [EMSRequestFactory nullMock];
            operationQueue = [NSOperationQueue new];
            operationQueue.name = @"testOperationQueue";
        });

        describe(@"init", ^{


            it(@"should throw an exception when there is no actionFactory", ^{
                @try {
                    [[MEUserNotificationDelegate alloc] initWithActionFactory:nil
                                                                        inApp:inApp
                                                            timestampProvider:timestampProvider
                                                                 uuidProvider:uuidProvider
                                                                 pushInternal:pushInternal
                                                               requestManager:requestManager
                                                               requestFactory:requestFactory
                                                               operationQueue:operationQueue];
                    fail(@"Expected Exception when actionFactory is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: actionFactory"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw an exception when there is no inApp", ^{
                @try {
                    [[MEUserNotificationDelegate alloc] initWithActionFactory:actionFactory
                                                                        inApp:nil
                                                            timestampProvider:timestampProvider
                                                                 uuidProvider:uuidProvider
                                                                 pushInternal:pushInternal
                                                               requestManager:requestManager
                                                               requestFactory:requestFactory
                                                               operationQueue:operationQueue];
                    fail(@"Expected Exception when inApp is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: inApp"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw an exception when there is no timestampProvider", ^{
                @try {
                    [[MEUserNotificationDelegate alloc] initWithActionFactory:actionFactory
                                                                        inApp:inApp
                                                            timestampProvider:nil
                                                                 uuidProvider:uuidProvider
                                                                 pushInternal:pushInternal
                                                               requestManager:requestManager
                                                               requestFactory:requestFactory
                                                               operationQueue:operationQueue];
                    fail(@"Expected Exception when timestampProvider is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: timestampProvider"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw an exception when there is no uuidProvider", ^{
                @try {
                    [[MEUserNotificationDelegate alloc] initWithActionFactory:actionFactory
                                                                        inApp:inApp
                                                            timestampProvider:timestampProvider
                                                                 uuidProvider:nil
                                                                 pushInternal:pushInternal
                                                               requestManager:requestManager
                                                               requestFactory:requestFactory
                                                               operationQueue:nil];
                    fail(@"Expected Exception when uuidProvider is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: uuidProvider"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw an exception when there is no pushInternal", ^{
                @try {
                    [[MEUserNotificationDelegate alloc] initWithActionFactory:actionFactory
                                                                        inApp:[MEInApp mock]
                                                            timestampProvider:[EMSTimestampProvider mock]
                                                                 uuidProvider:uuidProvider
                                                                 pushInternal:nil
                                                               requestManager:[EMSRequestManager mock]
                                                               requestFactory:[EMSRequestFactory mock]
                                                               operationQueue:operationQueue];
                    fail(@"Expected Exception when pushInternal is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: pushInternal"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });
            it(@"should throw an exception when there is no requestManager", ^{
                @try {
                    [[MEUserNotificationDelegate alloc] initWithActionFactory:actionFactory
                                                                        inApp:inApp
                                                            timestampProvider:timestampProvider
                                                                 uuidProvider:uuidProvider
                                                                 pushInternal:pushInternal
                                                               requestManager:nil
                                                               requestFactory:requestFactory
                                                               operationQueue:operationQueue];
                    fail(@"Expected Exception when requestManager is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: requestManager"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });
            it(@"should throw an exception when there is no requestFactory", ^{
                @try {
                    [[MEUserNotificationDelegate alloc] initWithActionFactory:actionFactory
                                                                        inApp:inApp
                                                            timestampProvider:timestampProvider
                                                                 uuidProvider:uuidProvider
                                                                 pushInternal:pushInternal
                                                               requestManager:requestManager
                                                               requestFactory:nil
                                                               operationQueue:operationQueue];
                    fail(@"Expected Exception when requestFactory is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: requestFactory"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });
            it(@"should throw an exception when there is no operationQueue", ^{
                @try {
                    [[MEUserNotificationDelegate alloc] initWithActionFactory:actionFactory
                                                                        inApp:inApp
                                                            timestampProvider:timestampProvider
                                                                 uuidProvider:uuidProvider
                                                                 pushInternal:pushInternal
                                                               requestManager:requestManager
                                                               requestFactory:requestFactory
                                                               operationQueue:nil];
                    fail(@"Expected Exception when operationQueue is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: operationQueue"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });
        });

        describe(@"userNotificationCenter:willPresentNotification:withCompletionHandler:", ^{

            it(@"should call the injected delegate's userNotificationCenter:willPresentNotification:withCompletionHandler: method", ^{
                id userNotificationCenterDelegate = [KWMock mockForProtocol:@protocol(UNUserNotificationCenterDelegate)];
                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                UNUserNotificationCenter *mockCenter = [UNUserNotificationCenter mock];
                UNNotification *mockNotification = [UNNotification mock];
                void (^ const completionHandler)(UNNotificationPresentationOptions) =^(UNNotificationPresentationOptions options) {
                    [expectation fulfill];
                };

                [[userNotificationCenterDelegate shouldEventually] receive:@selector(userNotificationCenter:willPresentNotification:withCompletionHandler:)
                                                             withArguments:mockCenter,
                                                                           mockNotification,
                                                                           completionHandler];

                MEUserNotificationDelegate *userNotification = [[MEUserNotificationDelegate alloc] initWithActionFactory:actionFactory
                                                                                                                   inApp:[MEInApp nullMock]
                                                                                                       timestampProvider:[EMSTimestampProvider nullMock]
                                                                                                            uuidProvider:uuidProvider
                                                                                                            pushInternal:pushInternal
                                                                                                          requestManager:requestManager
                                                                                                          requestFactory:requestFactory
                                                                                                          operationQueue:operationQueue];
                userNotification.delegate = userNotificationCenterDelegate;

                [userNotification userNotificationCenter:mockCenter
                                 willPresentNotification:mockNotification
                                   withCompletionHandler:completionHandler];

                XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                                      timeout:2];
                XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
            });


            it(@"should call the injected delegate's userNotificationCenter:willPresentNotification:withCompletionHandler: method on main thread", ^{
                FakeNotificationDelegate *delegate = [FakeNotificationDelegate new];

                __block NSOperationQueue *returnedQueue = nil;
                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [delegate setWillPresentBlock:^(NSOperationQueue *operationQueue) {
                    returnedQueue = operationQueue;
                    [expectation fulfill];
                }];

                UNUserNotificationCenter *mockCenter = [UNUserNotificationCenter mock];
                UNNotification *mockNotification = [UNNotification mock];
                void (^ const completionHandler)(UNNotificationPresentationOptions) =^(UNNotificationPresentationOptions options) {

                };

                MEUserNotificationDelegate *userNotification = [[MEUserNotificationDelegate alloc] initWithActionFactory:actionFactory
                                                                                                                   inApp:[MEInApp nullMock]
                                                                                                       timestampProvider:[EMSTimestampProvider nullMock]
                                                                                                            uuidProvider:uuidProvider
                                                                                                            pushInternal:pushInternal
                                                                                                          requestManager:requestManager
                                                                                                          requestFactory:requestFactory
                                                                                                          operationQueue:operationQueue];
                userNotification.delegate = delegate;

                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [userNotification userNotificationCenter:mockCenter
                                     willPresentNotification:mockNotification
                                       withCompletionHandler:completionHandler];
                });

                XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                                      timeout:2];
                XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
                XCTAssertEqualObjects(returnedQueue, [NSOperationQueue mainQueue]);
            });

            it(@"should call completion handler with UNNotificationPresentationOptionAlert", ^{
                __block NSOperationQueue *currentQueue = nil;

                MEUserNotificationDelegate *userNotification = [[MEUserNotificationDelegate alloc] initWithActionFactory:actionFactory
                                                                                                                   inApp:[MEInApp nullMock]
                                                                                                       timestampProvider:[EMSTimestampProvider nullMock]
                                                                                                            uuidProvider:uuidProvider
                                                                                                            pushInternal:pushInternal
                                                                                                          requestManager:requestManager
                                                                                                          requestFactory:requestFactory
                                                                                                          operationQueue:operationQueue];
                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                __block UNNotificationPresentationOptions _option;
                [userNotification userNotificationCenter:[UNUserNotificationCenter mock]
                                 willPresentNotification:nil
                                   withCompletionHandler:^(UNNotificationPresentationOptions options) {
                                       _option = options;
                                       currentQueue = [NSOperationQueue currentQueue];
                                       [exp fulfill];
                                   }];

                XCTWaiterResult result = [XCTWaiter waitForExpectations:@[exp]
                                                                timeout:10];
                [[theValue(result) should] equal:theValue(XCTWaiterResultCompleted)];
                [[theValue(_option) should] equal:theValue(UNNotificationPresentationOptionAlert)];
                XCTAssertEqualObjects(currentQueue, [NSOperationQueue mainQueue]);
            });

        });

        describe(@"userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:", ^{

            it(@"should call the injected delegate's userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler: method", ^{
                id userNotificationCenterDelegate = [KWMock mockForProtocol:@protocol(UNUserNotificationCenterDelegate)];
                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                UNUserNotificationCenter *center = [UNUserNotificationCenter nullMock];
                UNNotificationResponse *notificationResponse = [UNNotificationResponse nullMock];
                void (^ const completionHandler)(void) =^{
                    [expectation fulfill];
                };

                [[userNotificationCenterDelegate shouldEventually] receive:@selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:)
                                                             withArguments:center,
                                                                           notificationResponse,
                                                                           completionHandler];

                MEUserNotificationDelegate *userNotification = [[MEUserNotificationDelegate alloc] initWithActionFactory:actionFactory
                                                                                                                   inApp:[MEInApp nullMock]
                                                                                                       timestampProvider:[EMSTimestampProvider nullMock]
                                                                                                            uuidProvider:uuidProvider
                                                                                                            pushInternal:pushInternal
                                                                                                          requestManager:requestManager
                                                                                                          requestFactory:requestFactory
                                                                                                          operationQueue:operationQueue];
                userNotification.delegate = userNotificationCenterDelegate;

                [userNotification userNotificationCenter:center
                          didReceiveNotificationResponse:notificationResponse
                                   withCompletionHandler:completionHandler];

                XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                                      timeout:2];
                XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
            });

            it(@"should call the injected delegate's userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler: method on main thread", ^{
                UNUserNotificationCenter *center = [UNUserNotificationCenter nullMock];
                UNNotificationResponse *notificationResponse = [UNNotificationResponse nullMock];
                void (^ const completionHandler)(void) =^{
                };

                MEUserNotificationDelegate *userNotification = [[MEUserNotificationDelegate alloc] initWithActionFactory:actionFactory
                                                                                                                   inApp:[MEInApp nullMock]
                                                                                                       timestampProvider:[EMSTimestampProvider nullMock]
                                                                                                            uuidProvider:uuidProvider
                                                                                                            pushInternal:pushInternal
                                                                                                          requestManager:requestManager
                                                                                                          requestFactory:requestFactory
                                                                                                          operationQueue:operationQueue];

                FakeNotificationDelegate *delegate = [FakeNotificationDelegate new];

                __block NSOperationQueue *returnedQueue = nil;
                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [delegate setDidReceiveBlock:^(NSOperationQueue *operationQueue) {
                    returnedQueue = operationQueue;
                    [expectation fulfill];
                }];

                userNotification.delegate = delegate;

                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [userNotification userNotificationCenter:center
                              didReceiveNotificationResponse:notificationResponse
                                       withCompletionHandler:completionHandler];
                });

                XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                                      timeout:2];
                XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
                XCTAssertEqualObjects(returnedQueue, [NSOperationQueue mainQueue]);
            });

            it(@"should call completion handler", ^{
                __block NSOperationQueue *currentQueue = nil;

                MEUserNotificationDelegate *userNotification = [[MEUserNotificationDelegate alloc] initWithActionFactory:actionFactory
                                                                                                                   inApp:inApp
                                                                                                       timestampProvider:timestampProvider
                                                                                                            uuidProvider:uuidProvider
                                                                                                            pushInternal:pushInternal
                                                                                                          requestManager:requestManager
                                                                                                          requestFactory:requestFactory
                                                                                                          operationQueue:operationQueue];
                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [userNotification userNotificationCenter:[UNUserNotificationCenter mock]
                          didReceiveNotificationResponse:nil
                                   withCompletionHandler:^{
                                       currentQueue = [NSOperationQueue currentQueue];
                                       [exp fulfill];
                                   }];

                XCTWaiterResult result = [XCTWaiter waitForExpectations:@[exp]
                                                                timeout:10];
                [[theValue(result) should] equal:theValue(XCTWaiterResultCompleted)];
                XCTAssertEqualObjects(currentQueue, [NSOperationQueue mainQueue]);
            });

            it(@"should call track click with richNotification:actionClicked eventName and title and action id in the payload", ^{
                MEUserNotificationDelegate *userNotification = [[MEUserNotificationDelegate alloc] initWithActionFactory:actionFactory
                                                                                                                   inApp:[MEInApp nullMock]
                                                                                                       timestampProvider:[EMSTimestampProvider nullMock]
                                                                                                            uuidProvider:uuidProvider
                                                                                                            pushInternal:pushInternal
                                                                                                          requestManager:requestManager
                                                                                                          requestFactory:requestFactory
                                                                                                          operationQueue:operationQueue];
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
                [EMSWaiter waitForExpectations:@[exp]
                                       timeout:10];

            });

            it(@"should call trackMessageOpenWithUserInfo on MobileEngage with the userInfo when didReceiveNotificationResponse:withCompletionHandler: is called", ^{
                MEUserNotificationDelegate *notificationDelegate = [[MEUserNotificationDelegate alloc] initWithActionFactory:actionFactory
                                                                                                                       inApp:[MEInApp nullMock]
                                                                                                           timestampProvider:[EMSTimestampProvider nullMock]
                                                                                                                uuidProvider:uuidProvider
                                                                                                                pushInternal:pushInternal
                                                                                                              requestManager:requestManager
                                                                                                              requestFactory:requestFactory
                                                                                                              operationQueue:operationQueue];
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
                [EMSWaiter waitForExpectations:@[exp]
                                       timeout:10];

            });

            it(@"should call showMessage:completionHandler: on IAM with InAppMessage when didReceiveNotificationResponse:withCompletionHandler: is called with inApp payload", ^{
                NSDate *responseTimestamp = [NSDate date];
                [[timestampProvider should] receive:@selector(provideTimestamp)
                                          andReturn:responseTimestamp];
                MEInAppMessage *inAppMessage = [[MEInAppMessage alloc] initWithCampaignId:@"42"
                                                                                      sid:@"123456789"
                                                                                      url:@"https://www.test.com"
                                                                                     html:@"<html/>"
                                                                        responseTimestamp:responseTimestamp];
                KWCaptureSpy *messageSpy = [inApp captureArgument:@selector(showMessage:completionHandler:)
                                                          atIndex:0];
                MEUserNotificationDelegate *notificationDelegate = [[MEUserNotificationDelegate alloc] initWithActionFactory:actionFactory
                                                                                                                       inApp:inApp
                                                                                                           timestampProvider:timestampProvider
                                                                                                                uuidProvider:uuidProvider
                                                                                                                pushInternal:pushInternal
                                                                                                              requestManager:requestManager
                                                                                                              requestFactory:requestFactory
                                                                                                              operationQueue:operationQueue];
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
                [EMSWaiter waitForExpectations:@[exp]
                                       timeout:10];
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

                MEUserNotificationDelegate *notificationDelegate = [[MEUserNotificationDelegate alloc] initWithActionFactory:actionFactory
                                                                                                                       inApp:inApp
                                                                                                           timestampProvider:timestampProvider
                                                                                                                uuidProvider:uuidProvider
                                                                                                                pushInternal:pushInternal
                                                                                                              requestManager:requestManager
                                                                                                              requestFactory:requestFactory
                                                                                                              operationQueue:operationQueue];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [notificationDelegate userNotificationCenter:[UNUserNotificationCenter mock]
                              didReceiveNotificationResponse:notificationResponseWithUserInfo(userInfo)
                                       withCompletionHandler:^{
                                           [exp fulfill];
                                       }];
                [EMSWaiter waitForExpectations:@[exp]
                                       timeout:10];

                CoreSuccessBlock successBlock = spy.argument;

                EMSResponseModel *responseModel = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                       headers:@{}
                                                                                          body:[@"<html/>" dataUsingEncoding:NSUTF8StringEncoding]
                                                                                    parsedBody:nil
                                                                                  requestModel:[EMSRequestModel nullMock]
                                                                                     timestamp:responseTimestamp];

                MEInAppMessage *inAppMessage = [[MEInAppMessage alloc] initWithCampaignId:@"42"
                                                                                      sid:@"123456789"
                                                                                      url:@"https://www.test.com"
                                                                                     html:@"<html/>"
                                                                        responseTimestamp:responseTimestamp];

                [[inApp should] receive:@selector(showMessage:completionHandler:)
                          withArguments:inAppMessage, kw_any()];

                successBlock(@"testRequestId", responseModel);
            });
        });

        describe(@"actionFromResponse:", ^{

            it(@"should return the default action when the action identifier is UNNotificationDefaultActionIdentifier", ^{
                MEUserNotificationDelegate *userNotification = [[MEUserNotificationDelegate alloc] initWithActionFactory:actionFactory
                                                                                                                   inApp:[MEInApp nullMock]
                                                                                                       timestampProvider:[EMSTimestampProvider nullMock]
                                                                                                            uuidProvider:uuidProvider
                                                                                                            pushInternal:pushInternal
                                                                                                          requestManager:requestManager
                                                                                                          requestFactory:requestFactory
                                                                                                          operationQueue:operationQueue];
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
                MEUserNotificationDelegate *userNotification = [[MEUserNotificationDelegate alloc] initWithActionFactory:actionFactory
                                                                                                                   inApp:[MEInApp nullMock]
                                                                                                       timestampProvider:[EMSTimestampProvider nullMock]
                                                                                                            uuidProvider:uuidProvider
                                                                                                            pushInternal:pushInternal
                                                                                                          requestManager:requestManager
                                                                                                          requestFactory:requestFactory
                                                                                                          operationQueue:operationQueue];
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

        it(@"should use actionFactory", ^{
            EMSEventHandlerBlock eventHandler = ^(NSString *eventName, NSDictionary<NSString *, id> *payload) {
            };
            NSString *eventName = @"testEventName";
            NSDictionary *payload = @{@"key1": @"value1", @"key2": @"value2", @"key3": @"value3"};
            NSDictionary *expectedAction = @{
                    @"id": @"uniqueId",
                    @"title": @"actionTitle",
                    @"type": @"MEAppEvent",
                    @"name": eventName,
                    @"payload": payload
            };
            id mockAction = [KWMock mockForProtocol:@protocol(EMSActionProtocol)];

            [[actionFactory should] receive:@selector(setEventHandler:)
                              withArguments:eventHandler];
            [[actionFactory should] receive:@selector(createActionWithActionDictionary:)
                                  andReturn:mockAction
                              withArguments:expectedAction];
            [[mockAction should] receive:@selector(execute)];

            MEUserNotificationDelegate *userNotification = [[MEUserNotificationDelegate alloc] initWithActionFactory:actionFactory
                                                                                                               inApp:inApp
                                                                                                   timestampProvider:timestampProvider
                                                                                                        uuidProvider:uuidProvider
                                                                                                        pushInternal:pushInternal
                                                                                                      requestManager:requestManager
                                                                                                      requestFactory:requestFactory
                                                                                                      operationQueue:operationQueue];
            userNotification.eventHandler = eventHandler;
            NSDictionary *userInfo = @{@"ems": @{
                    @"actions": @[
                            expectedAction
                    ]},
                    @"u": @"{\"sid\": \"123456789\"}"
            };

            XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
            [userNotification userNotificationCenter:[UNUserNotificationCenter mock]
                      didReceiveNotificationResponse:notificationResponseWithUserInfo(userInfo)
                               withCompletionHandler:^{
                                   [exp fulfill];
                               }];
            [EMSWaiter waitForExpectations:@[exp]
                                   timeout:10];
        });

        it(@"should call notificationInformationDelegate", ^{
            EMSNotificationInformation *notificationInformation = [[EMSNotificationInformation alloc] initWithCampaignId:@"testMultiChannelId"];

            MEUserNotificationDelegate *userNotification = [[MEUserNotificationDelegate alloc] initWithActionFactory:actionFactory
                                                                                                               inApp:inApp
                                                                                                   timestampProvider:timestampProvider
                                                                                                        uuidProvider:uuidProvider
                                                                                                        pushInternal:pushInternal
                                                                                                      requestManager:requestManager
                                                                                                      requestFactory:requestFactory
                                                                                                      operationQueue:operationQueue];
            __block NSOperationQueue *returnedQueue = nil;
            XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];

            userNotification.notificationInformationDelegate = ^(EMSNotificationInformation *notificationInformation) {
                returnedQueue = [NSOperationQueue currentQueue];
                [expectation fulfill];
            };
            NSDictionary *userInfo = @{@"ems": @{
                    @"multichannelId": @"testMultiChannelId"
            },
                    @"u": @"{\"sid\": \"123456789\"}"
            };

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [userNotification userNotificationCenter:[UNUserNotificationCenter mock]
                          didReceiveNotificationResponse:notificationResponseWithUserInfo(userInfo)
                                   withCompletionHandler:^{
                                   }];
            });
            [EMSWaiter waitForExpectations:@[expectation]
                                   timeout:5];

            XCTAssertEqualObjects(returnedQueue, [NSOperationQueue mainQueue]);
        });

SPEC_END

