#import "EMSAuthentication.h"
#import "EMSSchemaContract.h"
#import "Kiwi.h"
#import "MEInboxV2.h"
#import "FakeInboxNotificationRestClient.h"
#import "MEDefaultHeaders.h"
#import "EMSRequestModelMatcher.h"
#import "FakeTimeStampProvider.h"
#import "EMSWaiter.h"
#import "MEExperimental.h"
#import "MEExperimental+Test.h"

static NSString *const kAppId = @"kAppId";
static NSString *const kAppSecret = @"kAppSecret";

SPEC_BEGIN(MEInboxV2Tests)

        registerMatchers(@"EMS");

        NSString *applicationCode = kAppId;
        NSString *applicationPassword = @"appSecret";
        NSString *meId = @"ordinaryMeId";
        __block MERequestContext *requestContext;
        __block NSMutableArray *notifications;
        __block NSMutableArray<EMSNotification *> *fakeNotifications;
        __block EMSRequestManager *requestManager;

        EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
            [builder setMobileEngageApplicationCode:applicationCode
                                applicationPassword:applicationPassword];
            [builder setMerchantId:@"dummyMerchantId"];
            [builder setContactFieldId:@3];
        }];

        id (^inboxWithParameters)(EMSRESTClient *restClient, BOOL withMeId) = ^id(EMSRESTClient *restClient, BOOL withMeId) {
            notifications = [NSMutableArray array];
            requestContext = [[MERequestContext alloc] initWithConfig:config];
            if (withMeId) {
                requestContext.meId = meId;
            } else {
                requestContext.meId = nil;
            }
            requestManager = [EMSRequestManager mock];
            MEInboxV2 *inbox = [[MEInboxV2 alloc] initWithConfig:config
                                                  requestContext:requestContext
                                                      restClient:restClient
                                                   notifications:notifications
                                               timestampProvider:[EMSTimestampProvider new]
                                                  requestManager:requestManager];
            return inbox;
        };

        id (^inboxWithTimestampProvider)(EMSRESTClient *restClient, EMSTimestampProvider *timestampProvider) = ^id(EMSRESTClient *restClient, EMSTimestampProvider *timestampProvider) {
            notifications = [NSMutableArray array];
            requestContext = [[MERequestContext alloc] initWithConfig:config];
            requestContext.meId = meId;
            requestManager = [EMSRequestManager mock];
            MEInboxV2 *inbox = [[MEInboxV2 alloc] initWithConfig:config
                                                  requestContext:requestContext
                                                      restClient:restClient
                                                   notifications:notifications
                                               timestampProvider:timestampProvider
                                                  requestManager:requestManager];
            return inbox;
        };

        id (^expectedHeaders)(void) = ^id() {
            NSDictionary *defaultHeaders = [MEDefaultHeaders additionalHeadersWithConfig:config];
            NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionaryWithDictionary:defaultHeaders];
            mutableHeaders[@"x-ems-me-application-code"] = config.applicationCode;
            mutableHeaders[@"Authorization"] = [EMSAuthentication createBasicAuthWithUsername:config.applicationCode
                                                                                     password:config.applicationPassword];
            return [NSDictionary dictionaryWithDictionary:mutableHeaders];
        };

        beforeEach(^{
            NSDictionary *jsonResponse = @{@"notifications": @[
                @{@"id": @"id1", @"title": @"title1", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678129)},
                @{@"id": @"id2", @"title": @"title2", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678128)},
                @{@"id": @"id3", @"title": @"title3", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678127)},
                @{@"id": @"id4", @"title": @"title4", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678126)},
                @{@"id": @"id5", @"title": @"title5", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678125)},
                @{@"id": @"id6", @"title": @"title6", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678124)},
                @{@"id": @"id7", @"title": @"title7", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678123)},
            ]};

            NSMutableArray<EMSNotification *> *nots = [NSMutableArray array];
            for (NSDictionary *notificationDict in jsonResponse[@"notifications"]) {
                [nots addObject:[[EMSNotification alloc] initWithNotificationDictionary:notificationDict]];
            }
            fakeNotifications = nots;
        });


        describe(@"initWithConfig:requestContext:restClient:notifications:timestampProvider:requestManager:", ^{

            it(@"should throw exception when timestampProvider is nil", ^{
                @try {
                    [[MEInboxV2 alloc] initWithConfig:config
                                       requestContext:requestContext
                                           restClient:[EMSRESTClient mock]
                                        notifications:notifications
                                    timestampProvider:nil
                                       requestManager:[EMSRequestManager mock]];
                    fail(@"Expected Exception when timestampProvider is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: timestampProvider"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });


            it(@"should throw exception when notifications is nil", ^{
                @try {
                    [[MEInboxV2 alloc] initWithConfig:config
                                       requestContext:requestContext
                                           restClient:[EMSRESTClient mock]
                                        notifications:nil
                                    timestampProvider:[EMSTimestampProvider new]
                                       requestManager:[EMSRequestManager mock]];
                    fail(@"Expected Exception when notifications is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: notifications"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when config is nil", ^{
                @try {
                    [[MEInboxV2 alloc] initWithConfig:nil
                                       requestContext:requestContext
                                           restClient:[EMSRESTClient mock]
                                        notifications:[NSMutableArray new]
                                    timestampProvider:[EMSTimestampProvider new]
                                       requestManager:[EMSRequestManager mock]];
                    fail(@"Expected Exception when config is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: config"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when requestContext is nil", ^{
                @try {
                    [[MEInboxV2 alloc] initWithConfig:config
                                       requestContext:nil
                                           restClient:[EMSRESTClient mock]
                                        notifications:[NSMutableArray new]
                                    timestampProvider:[EMSTimestampProvider new]
                                       requestManager:[EMSRequestManager mock]];
                    fail(@"Expected Exception when requestContext is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: requestContext"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when restClient is nil", ^{
                @try {
                    [[MEInboxV2 alloc] initWithConfig:config
                                       requestContext:[MERequestContext mock]
                                           restClient:nil
                                        notifications:[NSMutableArray new]
                                    timestampProvider:[EMSTimestampProvider new]
                                       requestManager:[EMSRequestManager mock]];
                    fail(@"Expected Exception when restClient is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: restClient"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when requestManager is nil", ^{
                @try {
                    [[MEInboxV2 alloc] initWithConfig:config
                                       requestContext:[MERequestContext mock]
                                           restClient:[EMSRESTClient mock]
                                        notifications:[NSMutableArray new]
                                    timestampProvider:[EMSTimestampProvider new]
                                       requestManager:nil];
                    fail(@"Expected Exception when requestManager is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: requestManager"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

        });

        context(@"Rate limiting", ^{

            describe(@"inbox.fetchNotificationsWithResultBlock", ^{

                it(@"should only do one request in a minute even if multiple fetch called at the same time synchronously and return the same cached result", ^{
                    FakeInboxNotificationRestClient *fakeRestClient = [[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess];

                    MEInboxV2 *inbox = inboxWithTimestampProvider(fakeRestClient, [EMSTimestampProvider new]);

                    XCTestExpectation *exp1 = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                    XCTestExpectation *exp2 = [[XCTestExpectation alloc] initWithDescription:@"waitForResult2"];
                    __block EMSNotificationInboxStatus *firstInboxStatus;
                    __block EMSNotificationInboxStatus *secondInboxStatus;

                    [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                        if (inboxStatus) {
                            firstInboxStatus = inboxStatus;
                            [exp1 fulfill];
                        }
                    }];
                    [EMSWaiter waitForExpectations:@[exp1] timeout:30];

                    [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                        if (inboxStatus) {
                            secondInboxStatus = inboxStatus;
                            [exp2 fulfill];
                        }
                    }];
                    [EMSWaiter waitForExpectations:@[exp2] timeout:30];

                    [[theValue([fakeRestClient.submittedRequests count]) shouldEventually] equal:theValue(1)];
                    [[firstInboxStatus.notifications should] equal:fakeNotifications];
                    [[secondInboxStatus.notifications should] equal:fakeNotifications];
                });

                it(@"should only do one request in a minute even if multiple fetch called at the same time asynchronously and return the same cached result", ^{
                    FakeInboxNotificationRestClient *fakeRestClient = [[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess];

                    MEInboxV2 *inbox = inboxWithTimestampProvider(fakeRestClient, [EMSTimestampProvider new]);

                    XCTestExpectation *exp1 = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                    XCTestExpectation *exp2 = [[XCTestExpectation alloc] initWithDescription:@"waitForResult2"];
                    __block EMSNotificationInboxStatus *firstInboxStatus;
                    __block EMSNotificationInboxStatus *secondInboxStatus;

                    [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                        if (inboxStatus) {
                            firstInboxStatus = inboxStatus;
                            [exp1 fulfill];
                        }
                    }];

                    [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                        if (inboxStatus) {
                            secondInboxStatus = inboxStatus;
                            [exp2 fulfill];
                        }
                    }];

                    [EMSWaiter waitForExpectations:@[exp1, exp2] timeout:30];

                    [[theValue([fakeRestClient.submittedRequests count]) shouldEventually] equal:theValue(1)];
                    [[firstInboxStatus.notifications should] equal:fakeNotifications];
                    [[secondInboxStatus.notifications should] equal:fakeNotifications];
                });

                it(@"should do two requests when multiple fetch calls are spread over more than a minute", ^{
                    FakeInboxNotificationRestClient *fakeRestClient = [[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess];

                    NSDate *firstDate = [NSDate date];
                    NSDate *secondDate = [firstDate dateByAddingTimeInterval:60];
                    FakeTimeStampProvider *const timestampProvider = [[FakeTimeStampProvider alloc] initWithTimestamps:@[firstDate, secondDate]];
                    MEInboxV2 *inbox = inboxWithTimestampProvider(fakeRestClient, timestampProvider);

                    XCTestExpectation *exp1 = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                    XCTestExpectation *exp2 = [[XCTestExpectation alloc] initWithDescription:@"waitForResult2"];
                    __block EMSNotificationInboxStatus *firstInboxStatus;
                    __block EMSNotificationInboxStatus *secondInboxStatus;

                    [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                        if (inboxStatus) {
                            firstInboxStatus = inboxStatus;
                            [exp1 fulfill];
                        }
                    }];
                    [EMSWaiter waitForExpectations:@[exp1] timeout:30];

                    [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                        if (inboxStatus) {
                            secondInboxStatus = inboxStatus;
                            [exp2 fulfill];
                        }
                    }];
                    [EMSWaiter waitForExpectations:@[exp2] timeout:30];

                    [[theValue([fakeRestClient.submittedRequests count]) shouldEventually] equal:theValue(2)];
                    [[firstInboxStatus.notifications should] equal:fakeNotifications];
                    [[secondInboxStatus.notifications should] equal:fakeNotifications];
                });

                it(@"should only call success blocks one time for every fetch", ^{
                    FakeInboxNotificationRestClient *fakeRestClient = [[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess];

                    NSDate *firstDate = [NSDate date];
                    NSDate *secondDate = [firstDate dateByAddingTimeInterval:60];
                    FakeTimeStampProvider *const timestampProvider = [[FakeTimeStampProvider alloc] initWithTimestamps:@[firstDate, secondDate]];

                    MEInboxV2 *inbox = inboxWithTimestampProvider(fakeRestClient, timestampProvider);

                    XCTestExpectation *exp1 = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                    XCTestExpectation *exp2 = [[XCTestExpectation alloc] initWithDescription:@"waitForResult2"];
                    XCTestExpectation *exp3 = [[XCTestExpectation alloc] initWithDescription:@"waitForResult3"];

                    __block int successCount = 0;
                    [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                        if (inboxStatus) {
                            successCount++;
                            [exp1 fulfill];
                        }
                    }];
                    [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                        if (inboxStatus) {
                            successCount++;
                            [exp2 fulfill];
                        }
                    }];
                    [EMSWaiter waitForExpectations:@[exp1, exp2] timeout:30];

                    [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                        if (inboxStatus) {
                            successCount++;
                            [exp3 fulfill];
                        }
                    }];
                    [EMSWaiter waitForExpectations:@[exp3] timeout:30];

                    [[theValue(successCount) should] equal:theValue(3)];
                });

                it(@"should only call success blocks one time for every fetch", ^{
                    FakeInboxNotificationRestClient *fakeRestClient = [[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeFailure];

                    NSDate *firstDate = [NSDate date];
                    NSDate *secondDate = [firstDate dateByAddingTimeInterval:60];
                    FakeTimeStampProvider *const timestampProvider = [[FakeTimeStampProvider alloc] initWithTimestamps:@[firstDate, secondDate]];

                    MEInboxV2 *inbox = inboxWithTimestampProvider(fakeRestClient, timestampProvider);

                    XCTestExpectation *exp1 = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                    XCTestExpectation *exp2 = [[XCTestExpectation alloc] initWithDescription:@"waitForResult2"];
                    XCTestExpectation *exp3 = [[XCTestExpectation alloc] initWithDescription:@"waitForResult3"];

                    __block int errorCount = 0;
                    [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                        if (inboxStatus) {
                        } else {
                            errorCount++;
                            [exp1 fulfill];
                        }
                    }];
                    [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                        if (inboxStatus) {
                        } else {
                            errorCount++;
                            [exp2 fulfill];
                        }
                    }];
                    [EMSWaiter waitForExpectations:@[exp1, exp2] timeout:30];

                    [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                        if (inboxStatus) {
                        } else {
                            errorCount++;
                            [exp3 fulfill];
                        }
                    }];
                    [EMSWaiter waitForExpectations:@[exp3] timeout:30];

                    [[theValue(errorCount) should] equal:theValue(3)];
                });

            });

        });

        describe(@"inbox.fetchNotificationsWithResultBlock", ^{

            it(@"should not return nil in resultBlock", ^{
                __block EMSNotificationInboxStatus *result;
                MEInboxV2 *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (inboxStatus) {
                        result = inboxStatus;
                    } else {
                    }
                }];

                [[expectFutureValue(result) shouldNotEventually] beNil];
            });

            it(@"should run asyncronously", ^{
                __block EMSNotificationInboxStatus *result;
                MEInboxV2 *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (inboxStatus) {
                        result = inboxStatus;
                    } else {
                    }
                }];

                [[result should] beNil];
                [[expectFutureValue(result) shouldNotEventually] beNil];
            });

            it(@"should call EMSRestClient's executeTaskWithRequestModel: and parse the notifications correctly", ^{
                MEInboxV2 *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
                __block NSArray<EMSNotification *> *_notifications;
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (inboxStatus) {
                        _notifications = inboxStatus.notifications;
                    } else {
                        fail(@"errorblock invoked");
                    }
                }];

                [[expectFutureValue(_notifications) shouldEventually] equal:fakeNotifications];
            });

            it(@"should call EMSRestClient's executeTaskWithRequestModel: with correct RequestModel", ^{
                EMSRESTClient *client = [EMSRESTClient mock];
                MEInboxV2 *inbox = inboxWithParameters(client, YES);

                KWCaptureSpy *requestModelSpy = [client captureArgument:@selector(executeTaskWithRequestModel:successBlock:errorBlock:)
                                                                atIndex:0];
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                }];

                EMSRequestModel *capturedRequestModel = requestModelSpy.argument;

                [[capturedRequestModel.url should] equal:[NSURL URLWithString:[NSString stringWithFormat:@"https://me-inbox.eservice.emarsys.net/api/v1/notifications/%@",
                                                                                                         meId]]];
                [[capturedRequestModel.method should] equal:@"GET"];
                [[capturedRequestModel.headers should] equal:expectedHeaders()];
            });

            it(@"should throw an exception, when resultBlock is nil", ^{
                MEInboxV2 *inbox = inboxWithParameters([EMSRESTClient mock], NO);
                @try {
                    [inbox fetchNotificationsWithResultBlock:nil];
                    fail(@"Assertion doesn't called!");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should invoke resultBlock on main thread", ^{
                __block NSNumber *onMainThread = @NO;
                MEInboxV2 *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (inboxStatus) {
                        if ([NSThread isMainThread]) {
                            onMainThread = @YES;
                        }
                    } else {
                    }
                }];
                [[expectFutureValue(onMainThread) shouldEventually] equal:@YES];
            });

            it(@"should invoke errorBlock when meId is not available", ^{
                MEInboxV2 *inbox = inboxWithParameters([EMSRESTClient mock], NO);
                __block NSError *receivedError;
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (inboxStatus) {
                        fail(@"resultBlock invoked");
                    } else {
                        receivedError = error;
                    }
                }];
                [[expectFutureValue(receivedError) shouldNotEventually] beNil];
            });


            it(@"should not invoke errorBlock when there is no errorBlock without meId", ^{
                MEInboxV2 *inbox = inboxWithParameters([EMSRESTClient mock], NO);
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (inboxStatus) {
                        fail(@"resultBlock invoked");
                    } else {
                    }
                }];
            });

            it(@"should invoke errorBlock when there is an error with meId", ^{

                MEInboxV2 *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeFailure], YES);

                __block NSError *receivedError;
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (inboxStatus) {
                        fail(@"resultBlock invoked");
                    } else {
                        receivedError = error;
                    }
                }];
                [[expectFutureValue(receivedError) shouldNotEventually] beNil];
            });

            it(@"should not invoke errorBlock when there is no errorBlock with meId", ^{
                MEInboxV2 *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeFailure], YES);
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (inboxStatus) {
                        fail(@"resultBlock invoked");
                    } else {
                    }
                }];
            });

            it(@"should invoke errorBlock on main thread when there is error with meId", ^{
                __block NSNumber *onMainThread = @NO;

                MEInboxV2 *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeFailure], YES);
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (inboxStatus) {
                        fail(@"resultBlock invoked");
                    } else {
                        if ([NSThread isMainThread]) {
                            onMainThread = @YES;
                        }
                    }
                }];
                [[expectFutureValue(onMainThread) shouldEventually] equal:@YES];
            });

            it(@"should invoke errorBlock on main thread when meId is not available", ^{
                __block NSNumber *onMainThread = @NO;

                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    MEInboxV2 *inbox = inboxWithParameters([EMSRESTClient mock], NO);
                    [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                        if (inboxStatus) {
                            fail(@"resultBlock invoked");
                        } else {
                            if ([NSThread isMainThread]) {
                                onMainThread = @YES;
                            }
                        }
                    }];
                });

                [[expectFutureValue(onMainThread) shouldEventually] equal:@YES];
            });

        });

        describe(@"inbox.addNotification:", ^{

            it(@"should increase the notifications with the notification", ^{
                MEInboxV2 *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
                EMSNotification *notification = [EMSNotification new];

                [[theValue([notifications count]) should] equal:theValue(0)];
                [inbox addNotification:notification];
                [[theValue([notifications count]) should] equal:theValue(1)];
            });
        });

        describe(@"inbox.fetchNotificationsWithResultBlock include cached notifications", ^{
            it(@"should return with the added notification", ^{
                MEInboxV2 *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
                EMSNotification *notification = [EMSNotification new];
                [inbox addNotification:notification];

                __block EMSNotificationInboxStatus *status;
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (inboxStatus) {
                        status = inboxStatus;
                    } else {
                    }
                }];

                [[expectFutureValue(theValue([status.notifications containsObject:notification])) shouldEventually] beYes];
            });

            it(@"should return with the added notification on top", ^{
                MEInboxV2 *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
                EMSNotification *notification = [EMSNotification new];
                notification.expirationTime = @12345678130;
                [inbox addNotification:notification];

                __block EMSNotificationInboxStatus *status;
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (inboxStatus) {
                        status = inboxStatus;
                    } else {
                    }
                }];

                [[expectFutureValue([status.notifications firstObject]) shouldEventually] equal:notification];
            });

            it(@"should not add the notification if there is a notification already in with the same ID", ^{
                MEInboxV2 *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
                EMSNotification *notification = [EMSNotification new];
                notification.title = @"dogsOrCats";
                notification.id = @"id1";
                [inbox addNotification:notification];

                __block EMSNotification *returnedNotification;
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (inboxStatus) {
                        for (EMSNotification *noti in inboxStatus.notifications) {
                            if ([noti.id isEqualToString:notification.id]) {
                                returnedNotification = noti;
                                break;
                            }
                        }
                    } else {
                        fail(@"error block invoked");
                    }
                }];

                [[expectFutureValue(returnedNotification.id) shouldEventually] equal:@"id1"];
                [[expectFutureValue(returnedNotification.title) shouldNotEventually] equal:@"asdfghjk"];
                [[expectFutureValue(returnedNotification.title) shouldEventually] equal:@"title1"];
            });

            it(@"should remove notifications from cache when they are already present in the fetched list", ^{
                MEInboxV2 *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);

                EMSNotification *notification1 = [EMSNotification new];
                notification1.title = @"helloSunshine";
                notification1.id = @"id1";
                [inbox addNotification:notification1];

                EMSNotification *notification2 = [EMSNotification new];
                notification2.title = @"happySkiing";
                notification2.id = @"id0";
                [inbox addNotification:notification2];

                __block EMSNotification *returnedNotification;
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (inboxStatus) {
                        for (EMSNotification *noti in inboxStatus.notifications) {
                            if ([noti.id isEqualToString:notification1.id]) {
                                returnedNotification = noti;
                                break;
                            }
                        }
                    } else {
                        fail(@"error block invoked");
                    }
                }];

                [[expectFutureValue(returnedNotification.id) shouldEventually] equal:@"id1"];
                [[expectFutureValue(theValue([notifications count])) shouldEventually] equal:@1];
                [[expectFutureValue(notifications[0]) shouldEventually] equal:notification2];
            });

            it(@"should be idempotent", ^{
                MEInboxV2 *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
                EMSNotification *notification = [EMSNotification new];
                [inbox addNotification:notification];

                __block EMSNotificationInboxStatus *status1;
                __block EMSNotificationInboxStatus *status2;
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (inboxStatus) {
                        status1 = inboxStatus;
                    } else {
                    }
                }];
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (inboxStatus) {
                        status2 = inboxStatus;
                    } else {
                    }
                }];

                [[expectFutureValue(@([status1.notifications count])) shouldEventually] equal:theValue(8)];
                [[expectFutureValue(@([status2.notifications count])) shouldEventually] equal:theValue(8)];
            });

        });


        describe(@"inbox.resetBadgeCountWithSuccessBlock:errorBlock:", ^{

            it(@"should invoke restClient when meId is present", ^{
                EMSRESTClient *restClientMock = [EMSRESTClient mock];
                [[restClientMock should] receive:@selector(executeTaskWithRequestModel:successBlock:errorBlock:)];

                MEInboxV2 *inbox = inboxWithParameters(restClientMock, YES);

                [inbox resetBadgeCountWithCompletionBlock:nil];
            });

            it(@"should not invoke restClient when meId is not available", ^{
                EMSRESTClient *restClientMock = [EMSRESTClient mock];
                [[restClientMock shouldNot] receive:@selector(executeTaskWithRequestModel:successBlock:errorBlock:)];

                MEInboxV2 *inbox = inboxWithParameters(restClientMock, NO);

                [inbox resetBadgeCountWithCompletionBlock:nil];
            });

            it(@"should invoke restClient with the correct requestModel", ^{
                EMSRequestModel *expectedRequestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setMethod:HTTPMethodDELETE];
                        [builder setUrl:[NSString stringWithFormat:@"https://me-inbox.eservice.emarsys.net/api/v1/notifications/%@/count",
                                                                   meId]];
                        [builder setHeaders:expectedHeaders()];
                    }
                                                                       timestampProvider:requestContext.timestampProvider
                                                                            uuidProvider:requestContext.uuidProvider];

                EMSRESTClient *restClientMock = [EMSRESTClient mock];
                [[restClientMock should] receive:@selector(executeTaskWithRequestModel:successBlock:errorBlock:)];
                KWCaptureSpy *requestModelSpy = [restClientMock captureArgument:@selector(executeTaskWithRequestModel:successBlock:errorBlock:)
                                                                        atIndex:0];
                MEInboxV2 *inbox = inboxWithParameters(restClientMock, YES);

                [inbox resetBadgeCountWithCompletionBlock:nil];

                EMSRequestModel *capturedModel = requestModelSpy.argument;
                [[capturedModel should] beSimilarWithRequest:expectedRequestModel];
            });

            it(@"should invoke successBlock when success", ^{
                __block BOOL successBlockInvoked = NO;

                MEInboxV2 *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
                [inbox resetBadgeCountWithCompletionBlock:^(NSError *error) {
                    if (!error) {
                        successBlockInvoked = YES;
                    } else {
                        fail(@"errorBlock invoked");
                    }
                }];

                [[expectFutureValue(theValue(successBlockInvoked)) shouldEventually] beYes];
            });

            it(@"should not invoke successBlock when there is no successBlock", ^{
                MEInboxV2 *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
                [inbox resetBadgeCountWithCompletionBlock:nil];
            });

            it(@"should invoke errorBlock when failure with meId", ^{
                __block NSError *_error;
                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];

                MEInboxV2 *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeFailure], YES);
                [inbox resetBadgeCountWithCompletionBlock:^(NSError *error) {
                    if (!error) {
                        fail(@"successBlock invoked");
                    } else {
                        _error = error;
                        [exp fulfill];
                    }
                }];
                [EMSWaiter waitForExpectations:@[exp] timeout:30];

                [[_error shouldNot] beNil];
            });

            it(@"should not invoke errorBlock when there is no errorBlock with meId", ^{
                MEInboxV2 *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeFailure], YES);
                [inbox resetBadgeCountWithCompletionBlock:nil];
            });

            it(@"should invoke errorBlock when failure without meId", ^{
                __block NSError *_error;
                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                MEInboxV2 *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeFailure], NO);
                [inbox resetBadgeCountWithCompletionBlock:^(NSError *error) {
                    if (!error) {
                        fail(@"successBlock invoked");
                    } else {
                        _error = error;
                        [exp fulfill];
                    }
                }];
                [EMSWaiter waitForExpectations:@[exp] timeout:30];
                [[_error shouldNot] beNil];
            });


            it(@"should not invoke errorBlock when there is no errorBlock without meId", ^{
                MEInboxV2 *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeFailure], NO);
                [inbox resetBadgeCountWithCompletionBlock:nil];
            });


            it(@"should invoke successBlock on main thread", ^{
                __block BOOL onMainThread = NO;
                MEInboxV2 *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);

                [inbox resetBadgeCountWithCompletionBlock:^(NSError *error) {
                    if (!error) {
                        if ([NSThread isMainThread]) {
                            onMainThread = YES;
                        }
                    } else {
                        fail(@"errorBlock invoked");
                    }
                }];
                [[expectFutureValue(theValue(onMainThread)) shouldEventually] beYes];
            });

            it(@"should invoke errorBlock on main thread", ^{
                __block BOOL onMainThread = NO;
                MEInboxV2 *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeFailure], YES);

                [inbox resetBadgeCountWithCompletionBlock:^(NSError *error) {
                    if (!error) {
                        fail(@"successBlock invoked");
                    } else {
                        if ([NSThread isMainThread]) {
                            onMainThread = YES;
                        }
                    }
                }];
                [[expectFutureValue(theValue(onMainThread)) shouldEventually] beYes];
            });

            it(@"should invoke errorBlock on main thread when meId is not set", ^{
                __block BOOL onMainThread = NO;
                MEInboxV2 *inbox = inboxWithParameters([EMSRESTClient mock], NO);
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [inbox resetBadgeCountWithCompletionBlock:^(NSError *error) {
                        if (!error) {
                            fail(@"successBlock invoked");
                        } else {
                            if ([NSThread isMainThread]) {
                                onMainThread = YES;
                            }
                        }
                    }];
                });
                [[expectFutureValue(theValue(onMainThread)) shouldEventually] beYes];
            });
        });

        describe(@"inbox.resetBadgeCount", ^{
            it(@"should call resetBadgeCountWithCompletionBlock:", ^{
                MEInboxV2 *inbox = [MEInboxV2 new];
                __block NSNumber *resetCalled;
                [inbox stub:@selector(resetBadgeCountWithCompletionBlock:) withBlock:^id(NSArray *params) {
                    resetCalled = @YES;
                    return nil;
                }];

                [inbox resetBadgeCount];

                [[expectFutureValue(resetCalled) shouldNotEventually] beNil];
            });

            it(@"should reset the badge count in the lastNotificationStatus too", ^{
                NSArray<NSArray<NSDictionary *> *> *results = @[@[
                    @{@"id": @"id1", @"title": @"title1", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678129)},
                    @{@"id": @"id2", @"title": @"title2", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678128)},
                    @{@"id": @"id3", @"title": @"title3", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678127)},
                ], @[
                    @{@"id": @"id4", @"title": @"title4", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678126)},
                    @{@"id": @"id5", @"title": @"title5", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678125)},
                    @{@"id": @"id6", @"title": @"title6", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678124)},
                ]];

                NSMutableArray<EMSNotification *> *expectedNotifications1 = [NSMutableArray array];
                for (NSDictionary *notificationDict in results[0]) {
                    [expectedNotifications1 addObject:[[EMSNotification alloc] initWithNotificationDictionary:notificationDict]];
                }
                NSMutableArray<EMSNotification *> *expectedNotifications2 = [NSMutableArray array];
                for (NSDictionary *notificationDict in results[1]) {
                    [expectedNotifications2 addObject:[[EMSNotification alloc] initWithNotificationDictionary:notificationDict]];
                }

                FakeInboxNotificationRestClient *fakeRestClient = [[FakeInboxNotificationRestClient alloc] initWithSuccessResults:results];

                MEInboxV2 *inbox = inboxWithTimestampProvider(fakeRestClient, [EMSTimestampProvider new]);

                XCTestExpectation *exp1 = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                __block EMSNotificationInboxStatus *firstInboxStatus;
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (inboxStatus) {
                        firstInboxStatus = inboxStatus;
                        [exp1 fulfill];
                    } else {

                    }
                }];

                [EMSWaiter waitForExpectations:@[exp1] timeout:30];

                [[firstInboxStatus.notifications should] equal:expectedNotifications1];

                XCTestExpectation *expectationForReset = [[XCTestExpectation alloc] initWithDescription:@"waitForReset"];
                [inbox resetBadgeCountWithCompletionBlock:^(NSError *error) {
                    if (!error) {
                        [expectationForReset fulfill];
                    } else {
                    }
                }];
                [EMSWaiter waitForExpectations:@[expectationForReset] timeout:30];

                XCTestExpectation *exp2 = [[XCTestExpectation alloc] initWithDescription:@"waitForResult2"];
                __block EMSNotificationInboxStatus *secondInboxStatus;
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (inboxStatus) {
                        secondInboxStatus = inboxStatus;
                        [exp2 fulfill];
                    } else {

                    }
                }];

                [EMSWaiter waitForExpectations:@[exp2] timeout:30];

                [[secondInboxStatus.notifications should] equal:expectedNotifications1];
                [[theValue(secondInboxStatus.badgeCount) should] equal:theValue(0)];
            });
        });

        describe(@"purgeNotificationCache", ^{
            it(@"should allow fetch after calling purgeNotificationCache", ^{
                NSArray<NSArray<NSDictionary *> *> *results = @[@[
                    @{@"id": @"id1", @"title": @"title1", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678129)},
                    @{@"id": @"id2", @"title": @"title2", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678128)},
                    @{@"id": @"id3", @"title": @"title3", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678127)},
                ], @[
                    @{@"id": @"id4", @"title": @"title4", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678126)},
                    @{@"id": @"id5", @"title": @"title5", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678125)},
                    @{@"id": @"id6", @"title": @"title6", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678124)},
                ]];

                NSMutableArray<EMSNotification *> *expectedNotifications1 = [NSMutableArray array];
                for (NSDictionary *notificationDict in results[0]) {
                    [expectedNotifications1 addObject:[[EMSNotification alloc] initWithNotificationDictionary:notificationDict]];
                }
                NSMutableArray<EMSNotification *> *expectedNotifications2 = [NSMutableArray array];
                for (NSDictionary *notificationDict in results[1]) {
                    [expectedNotifications2 addObject:[[EMSNotification alloc] initWithNotificationDictionary:notificationDict]];
                }

                FakeInboxNotificationRestClient *fakeRestClient = [[FakeInboxNotificationRestClient alloc] initWithSuccessResults:results];

                MEInboxV2 *inbox = inboxWithTimestampProvider(fakeRestClient, [EMSTimestampProvider new]);

                XCTestExpectation *exp1 = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                XCTestExpectation *exp2 = [[XCTestExpectation alloc] initWithDescription:@"waitForResult2"];
                __block EMSNotificationInboxStatus *firstInboxStatus;
                __block EMSNotificationInboxStatus *secondInboxStatus;

                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (inboxStatus) {
                        firstInboxStatus = inboxStatus;
                        [exp1 fulfill];
                    } else {

                    }
                }];

                [EMSWaiter waitForExpectations:@[exp1] timeout:30];

                [[firstInboxStatus.notifications should] equal:expectedNotifications1];

                [inbox purgeNotificationCache];

                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (inboxStatus) {
                        secondInboxStatus = inboxStatus;
                        [exp2 fulfill];
                    } else {

                    }
                }];

                [EMSWaiter waitForExpectations:@[exp2] timeout:30];

                [[secondInboxStatus.notifications should] equal:expectedNotifications2];
            });

            it(@"should not do anything when method has been called already in 60 sec", ^{
                NSArray<NSArray<NSDictionary *> *> *results = @[@[
                    @{@"id": @"id1", @"title": @"title1", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678129)},
                    @{@"id": @"id2", @"title": @"title2", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678128)},
                    @{@"id": @"id3", @"title": @"title3", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678127)},
                ], @[
                    @{@"id": @"id4", @"title": @"title4", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678126)},
                    @{@"id": @"id5", @"title": @"title5", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678125)},
                    @{@"id": @"id6", @"title": @"title6", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678124)},
                ], @[
                    @{@"id": @"id7", @"title": @"title7", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678126)},
                    @{@"id": @"id8", @"title": @"title8", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678125)},
                    @{@"id": @"id9", @"title": @"title9", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678124)},
                ]];

                NSMutableArray<EMSNotification *> *expectedNotifications1 = [NSMutableArray array];
                for (NSDictionary *notificationDict in results[0]) {
                    [expectedNotifications1 addObject:[[EMSNotification alloc] initWithNotificationDictionary:notificationDict]];
                }
                NSMutableArray<EMSNotification *> *expectedNotifications2 = [NSMutableArray array];
                for (NSDictionary *notificationDict in results[1]) {
                    [expectedNotifications2 addObject:[[EMSNotification alloc] initWithNotificationDictionary:notificationDict]];
                }

                FakeInboxNotificationRestClient *fakeRestClient = [[FakeInboxNotificationRestClient alloc] initWithSuccessResults:results];

                MEInboxV2 *inbox = inboxWithTimestampProvider(fakeRestClient, [EMSTimestampProvider new]);

                XCTestExpectation *exp1 = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                __block EMSNotificationInboxStatus *firstInboxStatus;
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (inboxStatus) {
                        firstInboxStatus = inboxStatus;
                        [exp1 fulfill];
                    } else {

                    }
                }];

                [EMSWaiter waitForExpectations:@[exp1] timeout:30];

                [[firstInboxStatus.notifications should] equal:expectedNotifications1];

                [inbox purgeNotificationCache];

                XCTestExpectation *exp2 = [[XCTestExpectation alloc] initWithDescription:@"waitForResult2"];
                __block EMSNotificationInboxStatus *secondInboxStatus;
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (inboxStatus) {
                        secondInboxStatus = inboxStatus;
                        [exp2 fulfill];
                    } else {

                    }
                }];

                [EMSWaiter waitForExpectations:@[exp2] timeout:30];

                [[secondInboxStatus.notifications should] equal:expectedNotifications2];

                [inbox purgeNotificationCache];

                XCTestExpectation *exp3 = [[XCTestExpectation alloc] initWithDescription:@"waitForResult3"];
                __block EMSNotificationInboxStatus *thirdInboxStatus;
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (inboxStatus) {
                        thirdInboxStatus = inboxStatus;
                        [exp3 fulfill];
                    } else {

                    }
                }];

                [EMSWaiter waitForExpectations:@[exp3] timeout:30];

                [[thirdInboxStatus.notifications should] equal:expectedNotifications2];
            });

            it(@"should allow purge after 60 seconds", ^{
                NSArray<NSArray<NSDictionary *> *> *results = @[@[
                    @{@"id": @"id1", @"title": @"title1", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678129)},
                    @{@"id": @"id2", @"title": @"title2", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678128)},
                    @{@"id": @"id3", @"title": @"title3", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678127)},
                ], @[
                    @{@"id": @"id4", @"title": @"title4", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678126)},
                    @{@"id": @"id5", @"title": @"title5", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678125)},
                    @{@"id": @"id6", @"title": @"title6", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678124)},
                ]];

                NSMutableArray<EMSNotification *> *expectedNotifications1 = [NSMutableArray array];
                for (NSDictionary *notificationDict in results[0]) {
                    [expectedNotifications1 addObject:[[EMSNotification alloc] initWithNotificationDictionary:notificationDict]];
                }
                NSMutableArray<EMSNotification *> *expectedNotifications2 = [NSMutableArray array];
                for (NSDictionary *notificationDict in results[1]) {
                    [expectedNotifications2 addObject:[[EMSNotification alloc] initWithNotificationDictionary:notificationDict]];
                }

                FakeInboxNotificationRestClient *fakeRestClient = [[FakeInboxNotificationRestClient alloc] initWithSuccessResults:results];

                FakeTimeStampProvider *fakeTimeStampProvider = [[FakeTimeStampProvider alloc] initWithTimestamps:@[
                    [NSDate date],
                    [NSDate date],
                    [[NSDate date] dateByAddingTimeInterval:60],
                    [[NSDate date] dateByAddingTimeInterval:30]
                ]];

                MEInboxV2 *inbox = inboxWithTimestampProvider(fakeRestClient, fakeTimeStampProvider);

                [inbox purgeNotificationCache];

                XCTestExpectation *exp1 = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                __block EMSNotificationInboxStatus *firstInboxStatus;
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (inboxStatus) {
                        firstInboxStatus = inboxStatus;
                        [exp1 fulfill];
                    } else {

                    }
                }];

                [EMSWaiter waitForExpectations:@[exp1] timeout:30];

                [[firstInboxStatus.notifications should] equal:expectedNotifications1];

                [inbox purgeNotificationCache];

                XCTestExpectation *exp2 = [[XCTestExpectation alloc] initWithDescription:@"waitForResult2"];
                __block EMSNotificationInboxStatus *secondInboxStatus;
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (inboxStatus) {
                        secondInboxStatus = inboxStatus;
                        [exp2 fulfill];
                    } else {

                    }
                }];

                [EMSWaiter waitForExpectations:@[exp2] timeout:30];

                [[secondInboxStatus.notifications should] equal:expectedNotifications2];
            });
        });

        context(@"user centric inbox", ^{

            __block MEInboxV2 *inbox;
            __block EMSRESTClient *restClient;
            __block EMSRequestManager *requestManager;

            beforeEach(^{
                MERequestContext *context = [[MERequestContext alloc] initWithConfig:config];
                restClient = [EMSRESTClient mock];
                requestManager = [EMSRequestManager mock];

                inbox = [[MEInboxV2 alloc] initWithConfig:config
                                           requestContext:context
                                               restClient:restClient
                                            notifications:[@[] mutableCopy]
                                        timestampProvider:[EMSTimestampProvider new]
                                           requestManager:requestManager];
            });

            afterEach(^{
                [MEExperimental reset];
            });

            it(@"should return an error on completionHandler instead of submitting an invalid request without messageId", ^{
                EMSNotification *message = [EMSNotification new];
                message.sid = @"testID";
                message.title = @"title";
                message.body = @"body";
                message.customData = @{};
                message.rootParams = @{};
                message.expirationTime = @100;
                message.receivedAtTimestamp = @50;

                [[requestManager shouldNot] receive:@selector(submitRequestModel:)];

                __block NSError *reportedError;
                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"expectation"];
                [inbox trackMessageOpenWith:message
                            completionBlock:^(NSError *error) {
                                reportedError = error;
                                [expectation fulfill];
                            }];
                XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:2];

                [[reportedError.localizedDescription should] equal:@"Missing messageId"];
            });

            it(@"should return an error on completionHandler instead of submitting an invalid request without sid", ^{
                EMSNotification *message = [EMSNotification new];
                message.id = @"testID";
                message.title = @"title";
                message.body = @"body";
                message.customData = @{};
                message.rootParams = @{};
                message.expirationTime = @100;
                message.receivedAtTimestamp = @50;

                [[requestManager shouldNot] receive:@selector(submitRequestModel:)];

                __block NSError *reportedError;
                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"expectation"];
                [inbox trackMessageOpenWith:message
                            completionBlock:^(NSError *error) {
                                reportedError = error;
                                [expectation fulfill];
                            }];
                XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:2];

                [[reportedError.localizedDescription should] equal:@"Missing sid"];
            });
        });

SPEC_END
