#import "Kiwi.h"
#import "EMSConfigBuilder.h"
#import "EMSConfig.h"
#import "EMSDeviceInfo.h"
#import "MEDefaultHeaders.h"
#import "FakeInboxNotificationRequestManager.h"
#import "MEInbox.h"
#import "EMSRequestModelMatcher.h"
#import "EMSAuthentication.h"
#import "MEExperimental+Test.h"
#import "EMSUUIDProvider.h"
#import "EMSNotificationCache.h"
#import "EMSWaiter.h"
#import "Emarsys.h"
#import "EMSRequestFactory.h"
#import "EMSEndpoint.h"

static NSString *const kAppId = @"kAppId";

SPEC_BEGIN(MEInboxTests)

        registerMatchers(@"EMS");

        NSString *applicationCode = kAppId;
        NSNumber *contactFieldId = @3;
        NSString *contactFieldValue = @"valueOfContactField";

        __block EMSDeviceInfo *deviceInfo = [EMSDeviceInfo new];
        __block EMSTimestampProvider *timestampProvider = [EMSTimestampProvider new];
        __block EMSUUIDProvider *uuidProvider = [EMSUUIDProvider new];

        EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
            [builder setMobileEngageApplicationCode:applicationCode];
            [builder setMerchantId:@"dummyMerchantId"];
            [builder setContactFieldId:@3];
        }];

        __block EMSNotificationCache *notificationCache;

        id (^inboxWithParameters)(EMSRequestManager *requestManager, BOOL withContactFieldValue) = ^id(EMSRequestManager *requestManager, BOOL withContactFieldValue) {
            notificationCache = [EMSNotificationCache new];
            MERequestContext *context = [[MERequestContext alloc] initWithApplicationCode:applicationCode
                                                                           contactFieldId:contactFieldId
                                                                             uuidProvider:uuidProvider
                                                                        timestampProvider:timestampProvider
                                                                               deviceInfo:deviceInfo];
            if (withContactFieldValue) {
                [context setContactFieldValue:contactFieldValue];
            } else {
                [context setContactFieldValue:nil];
            }

            EMSEndpoint *endpoint = [EMSEndpoint mock];
            [endpoint stub:@selector(inboxUrl) andReturn:@"https://me-inbox.eservice.emarsys.net/api/"];

            MEInbox *inbox = [[MEInbox alloc] initWithRequestContext:context
                                                   notificationCache:notificationCache
                                                      requestManager:requestManager
                                                      requestFactory:[EMSRequestFactory mock]
                                                            endpoint:endpoint];
            return inbox;
        };

        __block MERequestContext *requestContext;
        __block EMSRequestManager *requestManagerMock;

        MEInbox *(^createInbox)(void) = ^id() {
            requestManagerMock = [EMSRequestManager nullMock];
            requestContext = [[MERequestContext alloc] initWithApplicationCode:nil contactFieldId:nil uuidProvider:uuidProvider timestampProvider:timestampProvider deviceInfo:deviceInfo];
            notificationCache = [EMSNotificationCache new];

            EMSEndpoint *endpoint = [EMSEndpoint mock];
            [endpoint stub:@selector(inboxUrl) andReturn:@"https://me-inbox.eservice.emarsys.net/api/"];

            MEInbox *inbox = [[MEInbox alloc] initWithRequestContext:requestContext
                                                   notificationCache:notificationCache
                                                      requestManager:requestManagerMock
                                                      requestFactory:[EMSRequestFactory mock]
                                                            endpoint:endpoint];
            return inbox;
        };

        id (^expectedHeaders)(void) = ^id() {
            NSDictionary *defaultHeaders = [MEDefaultHeaders additionalHeaders];
            NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionaryWithDictionary:defaultHeaders];
            mutableHeaders[@"x-ems-me-hardware-id"] = deviceInfo.hardwareId;
            mutableHeaders[@"x-ems-me-application-code"] = config.applicationCode;
            mutableHeaders[@"x-ems-me-contact-field-id"] = [NSString stringWithFormat:@"%@", contactFieldId];
            mutableHeaders[@"x-ems-me-contact-field-value"] = contactFieldValue;
            mutableHeaders[@"Authorization"] = [EMSAuthentication createBasicAuthWithUsername:config.applicationCode];
            return [NSDictionary dictionaryWithDictionary:mutableHeaders];
        };

        beforeEach(^{
            [MEExperimental reset];
        });

        describe(@"initWithRequestContext:notificationCache:requestManager:requestFactory:endpoint:", ^{

            it(@"should throw exception when requestContext is nil", ^{
                @try {
                    [[MEInbox alloc] initWithRequestContext:nil
                                          notificationCache:[EMSNotificationCache mock]
                                             requestManager:[EMSRequestManager mock]
                                             requestFactory:[EMSRequestFactory mock]
                                                   endpoint:[EMSEndpoint mock]];
                    fail(@"Expected Exception when requestContext is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: requestContext"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when notificationCache is nil", ^{
                @try {
                    [[MEInbox alloc] initWithRequestContext:[MERequestContext mock]
                                          notificationCache:nil
                                             requestManager:[EMSRequestManager mock]
                                             requestFactory:[EMSRequestFactory mock]
                                                   endpoint:[EMSEndpoint mock]];
                    fail(@"Expected Exception when notificationCache is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: notificationCache"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when requestManager is nil", ^{
                @try {
                    [[MEInbox alloc] initWithRequestContext:[MERequestContext mock]
                                          notificationCache:[EMSNotificationCache mock]
                                             requestManager:nil
                                             requestFactory:[EMSRequestFactory mock]
                                                   endpoint:[EMSEndpoint mock]];
                    fail(@"Expected Exception when requestManager is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: requestManager"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when requestFactory is nil", ^{
                @try {
                    [[MEInbox alloc] initWithRequestContext:[MERequestContext mock]
                                          notificationCache:[EMSNotificationCache mock]
                                             requestManager:[EMSRequestManager mock]
                                             requestFactory:nil
                                                   endpoint:[EMSEndpoint mock]];
                    fail(@"Expected Exception when requestFactory is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: requestFactory"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when endpoint is nil", ^{
                @try {
                    [[MEInbox alloc] initWithRequestContext:[MERequestContext mock]
                                          notificationCache:[EMSNotificationCache mock]
                                             requestManager:[EMSRequestManager mock]
                                             requestFactory:[EMSRequestFactory mock]
                                                   endpoint:nil];
                    fail(@"Expected Exception when endpoint is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: endpoint"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

        });

        describe(@"inbox.fetchNotificationsWithResultBlock", ^{

            it(@"should not return nil in resultBlock", ^{
                __block EMSNotificationInboxStatus *result;
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRequestManager alloc] initWithResultType:ResultTypeSuccess], YES);

                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    result = inboxStatus;
                }];

                [[expectFutureValue(result) shouldNotEventually] beNil];
            });

            it(@"should run asyncronously", ^{
                __block EMSNotificationInboxStatus *result;
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRequestManager alloc] initWithResultType:ResultTypeSuccess], YES);

                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    result = inboxStatus;
                }];


                [[result should] beNil];
                [[expectFutureValue(result) shouldNotEventually] beNil];
            });

            it(@"should call EMSRequestManager's submitRequestModelNow: and parse the notifications correctly", ^{
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRequestManager alloc] initWithResultType:ResultTypeSuccess], YES);
                __block NSArray<EMSNotification *> *_notifications;
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (!error) {
                        _notifications = inboxStatus.notifications;
                    } else {
                        fail(@"errorblock invoked");
                    }
                }];

                NSDictionary *jsonResponse = @{@"notifications": @[
                        @{@"id": @"id1", @"title": @"title1", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678129)},
                        @{@"id": @"id2", @"title": @"title2", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678128)},
                        @{@"id": @"id3", @"title": @"title3", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678127)},
                        @{@"id": @"id4", @"title": @"title4", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678126)},
                        @{@"id": @"id5", @"title": @"title5", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678125)},
                        @{@"id": @"id6", @"title": @"title6", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678124)},
                        @{@"id": @"id7", @"title": @"title7", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678123)},
                ]};

                NSMutableArray<EMSNotification *> *notifications = [NSMutableArray array];
                for (NSDictionary *notificationDict in jsonResponse[@"notifications"]) {
                    [notifications addObject:[[EMSNotification alloc] initWithNotificationDictionary:notificationDict]];
                }

                [[expectFutureValue(_notifications) shouldEventually] equal:notifications];
            });

            it(@"should call EMSRequestManager's submitRequestModelNow: with correct RequestModel", ^{
                EMSRequestManager *requestManager = [EMSRequestManager mock];
                MEInbox *inbox = inboxWithParameters(requestManager, YES);

                KWCaptureSpy *requestModelSpy = [requestManager captureArgument:@selector(submitRequestModelNow:successBlock:errorBlock:)
                                                                        atIndex:0];

                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                }];

                EMSRequestModel *capturedRequestModel = requestModelSpy.argument;

                [[capturedRequestModel.url should] equal:[NSURL URLWithString:@"https://me-inbox.eservice.emarsys.net/api/notifications"]];
                [[capturedRequestModel.method should] equal:@"GET"];
                [[capturedRequestModel.headers should] equal:expectedHeaders()];
            });

            it(@"should throw an exception, when resultBlock is nil", ^{
                MEInbox *inbox = inboxWithParameters([EMSRequestManager mock], NO);
                @try {
                    [inbox fetchNotificationsWithResultBlock:nil];
                    fail(@"Assertion doesn't called!");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should invoke resultBlock on main thread", ^{
                __block NSNumber *onMainThread = @NO;
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRequestManager alloc] initWithResultType:ResultTypeSuccess], YES);

                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if ([NSThread isMainThread]) {
                        onMainThread = @YES;
                    }
                }];

                [[expectFutureValue(onMainThread) shouldEventually] equal:@YES];
            });

            it(@"should invoke errorBlock when applogin parameters are not available", ^{
                MEInbox *inbox = inboxWithParameters([EMSRequestManager mock], NO);
                __block NSError *receivedError;
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (error) {
                        receivedError = error;
                    } else {
                        fail(@"resultblock invoked");
                    }
                }];
                [[expectFutureValue(receivedError) shouldNotEventually] beNil];
            });
        });

        describe(@"inbox.resetBadgeCountWithSuccessBlock:errorBlock:", ^{

            it(@"should invoke requestManager when appLoginParameters are set", ^{
                EMSRequestManager *requestManager = [EMSRequestManager mock];
                [[requestManager should] receive:@selector(submitRequestModelNow:successBlock:errorBlock:)];

                MEInbox *inbox = inboxWithParameters(requestManager, YES);

                [inbox resetBadgeCountWithCompletionBlock:nil];
            });

            it(@"should not invoke requestManager when appLoginParameters are not available", ^{
                EMSRequestManager *requestManager = [EMSRequestManager mock];
                [[requestManager shouldNot] receive:@selector(submitRequestModelNow:successBlock:errorBlock:)];

                MEInbox *inbox = inboxWithParameters(requestManager, NO);

                [inbox resetBadgeCountWithCompletionBlock:nil];
            });

            it(@"should invoke requestManager with the correct requestModel", ^{
                EMSRequestManager *requestManager = [EMSRequestManager mock];
                EMSRequestModel *expectedRequestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                            [builder setMethod:HTTPMethodPOST];
                            [builder setUrl:@"https://me-inbox.eservice.emarsys.net/api/reset-badge-count"];
                            [builder setHeaders:expectedHeaders()];
                        }
                                                                       timestampProvider:[EMSTimestampProvider new]
                                                                            uuidProvider:[EMSUUIDProvider new]];

                [[requestManager should] receive:@selector(submitRequestModelNow:successBlock:errorBlock:)];
                KWCaptureSpy *requestModelSpy = [requestManager captureArgument:@selector(submitRequestModelNow:successBlock:errorBlock:)
                                                                        atIndex:0];
                MEInbox *inbox = inboxWithParameters(requestManager, YES);

                [inbox resetBadgeCountWithCompletionBlock:nil];

                EMSRequestModel *capturedModel = requestModelSpy.argument;
                [[capturedModel should] beSimilarWithRequest:expectedRequestModel];
            });

            it(@"should invoke successBlock when success", ^{
                __block BOOL successBlockInvoked = NO;

                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRequestManager alloc] initWithResultType:ResultTypeSuccess], YES);
                [inbox resetBadgeCountWithCompletionBlock:^(NSError *error) {
                    if (!error) {
                        successBlockInvoked = YES;
                    } else {
                        fail(@"errorblock invoked");
                    }
                }];
                [[expectFutureValue(theValue(successBlockInvoked)) shouldEventually] beYes];
            });

            it(@"should invoke errorBlock when failure with apploginParameters", ^{
                __block NSError *_error;

                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRequestManager alloc] initWithResultType:ResultTypeFailure], YES);
                [inbox resetBadgeCountWithCompletionBlock:^(NSError *error) {
                    if (!error) {
                        fail(@"successblock invoked");
                    } else {
                        _error = error;
                    }
                }];
                [[_error shouldNotEventually] beNil];
            });

            it(@"should invoke errorBlock when failure without apploginParameters", ^{
                __block NSError *_error;

                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRequestManager alloc] initWithResultType:ResultTypeFailure], NO);
                [inbox resetBadgeCountWithCompletionBlock:^(NSError *error) {
                    if (!error) {
                        fail(@"successblock invoked");
                    } else {
                        _error = error;
                    }
                }];
                [[_error shouldNotEventually] beNil];
            });

            it(@"should not invoke successBlock when there is no successBlock", ^{
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRequestManager alloc] initWithResultType:ResultTypeSuccess], YES);
                [inbox resetBadgeCountWithCompletionBlock:nil];
            });

            it(@"should not invoke errorBlock when there is no errorBlock with apploginParameters", ^{
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRequestManager alloc] initWithResultType:ResultTypeFailure], YES);
                [inbox resetBadgeCountWithCompletionBlock:nil];
            });

            it(@"should not invoke errorBlock when there is no errorBlock without apploginParameters", ^{
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRequestManager alloc] initWithResultType:ResultTypeFailure], NO);
                [inbox resetBadgeCountWithCompletionBlock:nil];
            });

            it(@"should invoke successBlock on main thread", ^{
                __block BOOL onMainThread = NO;
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRequestManager alloc] initWithResultType:ResultTypeSuccess], YES);

                [inbox resetBadgeCountWithCompletionBlock:^(NSError *error) {
                    if (!error) {
                        if ([NSThread isMainThread]) {
                            onMainThread = YES;
                        }
                    } else {
                        fail(@"errorblock invoked");
                    }
                }];
                [[expectFutureValue(theValue(onMainThread)) shouldEventually] beYes];
            });

            it(@"should invoke errorBlock on main thread", ^{
                __block BOOL onMainThread = NO;
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRequestManager alloc] initWithResultType:ResultTypeFailure], YES);

                [inbox resetBadgeCountWithCompletionBlock:^(NSError *error) {
                    if (!error) {
                        fail(@"successblock invoked");
                    } else {
                        if ([NSThread isMainThread]) {
                            onMainThread = YES;
                        }
                    }
                }];
                [[expectFutureValue(theValue(onMainThread)) shouldEventually] beYes];
            });

            it(@"should invoke errorBlock on main thread when apploginParameters are not set", ^{
                __block BOOL onMainThread = NO;
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRequestManager alloc] initWithResultType:ResultTypeFailure], NO);

                [inbox resetBadgeCountWithCompletionBlock:^(NSError *error) {
                    if (!error) {
                        fail(@"successblock invoked");
                    } else {
                        if ([NSThread isMainThread]) {
                            onMainThread = YES;
                        }
                    }
                }];
                [[expectFutureValue(theValue(onMainThread)) shouldEventually] beYes];
            });
        });

        describe(@"inbox.resetBadgeCount", ^{
            it(@"should call resetBadgeCountWithCompletionBlock:", ^{
                MEInbox *inbox = [MEInbox new];
                __block NSNumber *resetCalled;
                [inbox stub:@selector(resetBadgeCountWithCompletionBlock:) withBlock:^id(NSArray *params) {
                    resetCalled = @YES;
                    return nil;
                }];

                [inbox resetBadgeCount];

                [[expectFutureValue(resetCalled) shouldNotEventually] beNil];
            });
        });

        describe(@"inbox.fetchNotificationsWithResultBlock include cached notifications", ^{
            it(@"should return with the added notification", ^{
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRequestManager alloc] initWithResultType:ResultTypeSuccess], YES);
                EMSNotification *notification = [EMSNotification new];
                [notificationCache cache:notification];

                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                __block EMSNotificationInboxStatus *status;
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    status = inboxStatus;
                    [expectation fulfill];
                }];

                [EMSWaiter waitForExpectations:@[expectation]
                                       timeout:20];

                [[theValue([status.notifications containsObject:notification]) should] beYes];
            });

            it(@"should be idempotent", ^{
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRequestManager alloc] initWithResultType:ResultTypeSuccess], YES);
                EMSNotification *notification = [EMSNotification new];
                [notificationCache cache:notification];

                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [expectation setExpectedFulfillmentCount:2];
                __block EMSNotificationInboxStatus *status1;
                __block EMSNotificationInboxStatus *status2;
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    status1 = inboxStatus;
                    [expectation fulfill];
                }];
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    status2 = inboxStatus;
                    [expectation fulfill];
                }];

                [EMSWaiter waitForExpectations:@[expectation]
                                       timeout:20];

                [[@([status1.notifications count]) should] equal:theValue(8)];
                [[@([status2.notifications count]) should] equal:theValue(8)];
            });

            it(@"should return with the added notification in good order", ^{
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRequestManager alloc] initWithResultType:ResultTypeSuccess], YES);
                EMSNotification *notification = [EMSNotification new];
                notification.expirationTime = @12345678130;
                [notificationCache cache:notification];

                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                __block EMSNotificationInboxStatus *status;
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    status = inboxStatus;
                    [expectation fulfill];
                }];
                [EMSWaiter waitForExpectations:@[expectation]
                                       timeout:20];

                [[[status.notifications firstObject] should] equal:notification];
            });

            it(@"should not add the notification if there is a notification already in with the same ID", ^{
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRequestManager alloc] initWithResultType:ResultTypeSuccess], YES);
                EMSNotification *notification = [EMSNotification new];
                notification.title = @"asdfghjk";
                notification.id = @"id1";
                [notificationCache cache:notification];

                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                __block EMSNotification *returnedNotification;
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    for (EMSNotification *noti in inboxStatus.notifications) {
                        if ([noti.id isEqualToString:notification.id]) {
                            returnedNotification = noti;
                            [expectation fulfill];
                            break;
                        }
                    }
                }];
                [EMSWaiter waitForExpectations:@[expectation]
                                       timeout:20];

                [[returnedNotification.id should] equal:@"id1"];
                [[returnedNotification.title should] equal:@"title1"];
            });

            it(@"should remove notifications from cache when they are already present in the fetched list", ^{
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRequestManager alloc] initWithResultType:ResultTypeSuccess], YES);

                EMSNotification *notification1 = [EMSNotification new];
                notification1.title = @"asdfghjk";
                notification1.id = @"id1";
                [notificationCache cache:notification1];

                EMSNotification *notification2 = [EMSNotification new];
                notification2.title = @"asdfghjk";
                notification2.id = @"id0";
                [notificationCache cache:notification2];

                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                __block EMSNotification *returnedNotification;
                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    for (EMSNotification *noti in inboxStatus.notifications) {
                        if ([noti.id isEqualToString:notification1.id]) {
                            returnedNotification = noti;
                            [expectation fulfill];
                            break;
                        }
                    }
                }];
                [EMSWaiter waitForExpectations:@[expectation]
                                       timeout:20];

                [[returnedNotification.id should] equal:@"id1"];
                [[theValue([notificationCache.notifications count]) should] equal:@1];
                [[notificationCache.notifications[0] should] equal:notification2];
            });

        });

        describe(@"inbox.trackMessageOpen", ^{

            it(@"should return with eventId, and finish with success for trackNotificationOpenWithNotification:", ^{
                [Emarsys setupWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                    [builder setMobileEngageApplicationCode:@"14C19-A121F"];
                    [builder setMerchantId:@"dummyMerchantId"];
                    [builder setContactFieldId:@3];
                }]];

                EMSNotification *notification = [EMSNotification new];
                notification.sid = @"161e_D/1UiO/jCmE4";

                __block NSError *returnedError = [NSError mock];

                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [Emarsys.inbox trackNotificationOpenWithNotification:notification
                                                     completionBlock:^(NSError *error) {
                                                         returnedError = error;
                                                         [expectation fulfill];
                                                     }];
                [EMSWaiter waitForExpectations:@[expectation]
                                       timeout:20];
                [[returnedError should] beNil];
            });
        });

        describe(@"trackNotificationOpenWithNotification:", ^{

            it(@"should throw exception when parameter is nil", ^{
                @try {
                    [createInbox() trackNotificationOpenWithNotification:nil];
                    fail(@"Expected Exception when notification is nil!");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should submit requestModel", ^{
                EMSCompletionBlock completionBlock = ^(NSError *error) {
                };
                EMSNotification *notification = [EMSNotification new];
                EMSRequestModel *requestModel = [EMSRequestModel new];

                EMSRequestFactory *mockRequestFactory = [EMSRequestFactory mock];

                requestManagerMock = [EMSRequestManager mock];

                [[mockRequestFactory should] receive:@selector(createMessageOpenWithNotification:)
                                           andReturn:requestModel
                                       withArguments:notification];

                [[requestManagerMock should] receive:@selector(submitRequestModel:withCompletionBlock:)
                                       withArguments:requestModel, completionBlock];

                MEInbox *inbox = [[MEInbox alloc] initWithRequestContext:[MERequestContext nullMock]
                                                       notificationCache:notificationCache
                                                          requestManager:requestManagerMock
                                                          requestFactory:mockRequestFactory
                                                                endpoint:[EMSEndpoint mock]];

                [inbox trackNotificationOpenWithNotification:notification
                                             completionBlock:completionBlock];
            });

        });

SPEC_END