#import "Kiwi.h"
#import "EMSConfigBuilder.h"
#import "EMSConfig.h"
#import "EMSDeviceInfo.h"
#import "MEDefaultHeaders.h"
#import "MEAppLoginParameters.h"
#import "FakeInboxNotificationRestClient.h"
#import "MEInbox.h"
#import "EMSRequestModelMatcher.h"
#import "FakeStatusDelegate.h"
#import "EMSAuthentication.h"
#import "MEExperimental+Test.h"
#import "EMSUUIDProvider.h"
#import "EMSRequestManager.h"
#import "EMSNotificationCache.h"
#import "EMSWaiter.h"
#import "Emarsys.h"

static NSString *const kAppId = @"kAppId";

SPEC_BEGIN(MEInboxTests)

        registerMatchers(@"EMS");

        NSString *applicationCode = kAppId;
        NSString *applicationPassword = @"appSecret";
        NSNumber *contactFieldId = @3;
        NSString *contactFieldValue = @"valueOfContactField";

        EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
            [builder setMobileEngageApplicationCode:applicationCode
                                applicationPassword:applicationPassword];
            [builder setMerchantId:@"dummyMerchantId"];
            [builder setContactFieldId:@3];
        }];

        __block EMSNotificationCache *notificationCache;

        id (^inboxWithParameters)(EMSRESTClient *restClient, BOOL withApploginParameters) = ^id(EMSRESTClient *restClient, BOOL withApploginParameters) {
            notificationCache = [EMSNotificationCache new];
            MERequestContext *context = [[MERequestContext alloc] initWithConfig:config];
            if (withApploginParameters) {
                [context setAppLoginParameters:[MEAppLoginParameters parametersWithContactFieldId:contactFieldId
                                                                                contactFieldValue:contactFieldValue]];
            }

            MEInbox *inbox = [[MEInbox alloc] initWithConfig:config
                                              requestContext:context
                                           notificationCache:notificationCache
                                                  restClient:restClient
                                              requestManager:[EMSRequestManager mock]];
            return inbox;
        };

        __block MERequestContext *requestContext;
        __block EMSRESTClient *restClientMock;
        __block EMSRequestManager *requestManagerMock;

        MEInbox *(^createInbox)(void) = ^id() {
            restClientMock = [EMSRESTClient nullMock];
            requestManagerMock = [EMSRequestManager nullMock];
            requestContext = [[MERequestContext alloc] initWithConfig:config];
            notificationCache = [EMSNotificationCache new];

            MEInbox *inbox = [[MEInbox alloc] initWithConfig:config
                                              requestContext:requestContext
                                           notificationCache:notificationCache
                                                  restClient:restClientMock
                                              requestManager:requestManagerMock];
            return inbox;
        };

        id (^expectedHeaders)(void) = ^id() {
            NSDictionary *defaultHeaders = [MEDefaultHeaders additionalHeadersWithConfig:config];
            NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionaryWithDictionary:defaultHeaders];
            mutableHeaders[@"x-ems-me-hardware-id"] = [EMSDeviceInfo hardwareId];
            mutableHeaders[@"x-ems-me-application-code"] = config.applicationCode;
            mutableHeaders[@"x-ems-me-contact-field-id"] = [NSString stringWithFormat:@"%@", contactFieldId];
            mutableHeaders[@"x-ems-me-contact-field-value"] = contactFieldValue;
            mutableHeaders[@"Authorization"] = [EMSAuthentication createBasicAuthWithUsername:config.applicationCode
                                                                                     password:config.applicationPassword];
            return [NSDictionary dictionaryWithDictionary:mutableHeaders];
        };

        beforeEach(^{
            [MEExperimental reset];
        });

        describe(@"initWithConfig:requestContext:notificationCache:restClient:requestManager:", ^{

            it(@"should throw exception when config is nil", ^{
                @try {
                    [[MEInbox alloc] initWithConfig:nil
                                     requestContext:[MERequestContext mock]
                                  notificationCache:[EMSNotificationCache mock]
                                         restClient:[EMSRESTClient mock]
                                     requestManager:[EMSRequestManager mock]];
                    fail(@"Expected Exception when config is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: config"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when requestContext is nil", ^{
                @try {
                    [[MEInbox alloc] initWithConfig:[EMSConfig mock]
                                     requestContext:nil
                                  notificationCache:[EMSNotificationCache mock]
                                         restClient:[EMSRESTClient mock]
                                     requestManager:[EMSRequestManager mock]];
                    fail(@"Expected Exception when requestContext is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: requestContext"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when notificationCache is nil", ^{
                @try {
                    [[MEInbox alloc] initWithConfig:[EMSConfig mock]
                                     requestContext:[MERequestContext mock]
                                  notificationCache:nil
                                         restClient:[EMSRESTClient mock]
                                     requestManager:[EMSRequestManager mock]];
                    fail(@"Expected Exception when notificationCache is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: notificationCache"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when restClient is nil", ^{
                @try {
                    [[MEInbox alloc] initWithConfig:[EMSConfig mock]
                                     requestContext:[MERequestContext mock]
                                  notificationCache:[EMSNotificationCache mock]
                                         restClient:nil
                                     requestManager:[EMSRequestManager mock]];
                    fail(@"Expected Exception when restClient is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: restClient"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when requestManager is nil", ^{
                @try {
                    [[MEInbox alloc] initWithConfig:[EMSConfig mock]
                                     requestContext:[MERequestContext mock]
                                  notificationCache:[EMSNotificationCache mock]
                                         restClient:[EMSRESTClient mock]
                                     requestManager:nil];
                    fail(@"Expected Exception when requestManager is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: requestManager"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

        });

        describe(@"inbox.fetchNotificationsWithResultBlock", ^{

            it(@"should not return nil in resultBlock", ^{
                __block EMSNotificationInboxStatus *result;
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);

                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    result = inboxStatus;
                }];

                [[expectFutureValue(result) shouldNotEventually] beNil];
            });

            it(@"should run asyncronously", ^{
                __block EMSNotificationInboxStatus *result;
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);

                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    result = inboxStatus;
                }];


                [[result should] beNil];
                [[expectFutureValue(result) shouldNotEventually] beNil];
            });

            it(@"should call EMSRestClient's executeTaskWithRequestModel: and parse the notifications correctly", ^{
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
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

            it(@"should call EMSRestClient's executeTaskWithRequestModel: with correct RequestModel", ^{
                EMSRESTClient *client = [EMSRESTClient mock];
                MEInbox *inbox = inboxWithParameters(client, YES);

                KWCaptureSpy *requestModelSpy = [client captureArgument:@selector(executeTaskWithRequestModel:successBlock:errorBlock:)
                                                                atIndex:0];

                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                }];

                EMSRequestModel *capturedRequestModel = requestModelSpy.argument;

                [[capturedRequestModel.url should] equal:[NSURL URLWithString:@"https://me-inbox.eservice.emarsys.net/api/notifications"]];
                [[capturedRequestModel.method should] equal:@"GET"];
                [[capturedRequestModel.headers should] equal:expectedHeaders()];
            });

            it(@"should throw an exception, when resultBlock is nil", ^{
                MEInbox *inbox = inboxWithParameters([EMSRESTClient mock], NO);
                @try {
                    [inbox fetchNotificationsWithResultBlock:nil];
                    fail(@"Assertion doesn't called!");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should invoke resultBlock on main thread", ^{
                __block NSNumber *onMainThread = @NO;
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);

                [inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if ([NSThread isMainThread]) {
                        onMainThread = @YES;
                    }
                }];

                [[expectFutureValue(onMainThread) shouldEventually] equal:@YES];
            });

            it(@"should invoke errorBlock when applogin parameters are not available", ^{
                MEInbox *inbox = inboxWithParameters([EMSRESTClient mock], NO);
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

            it(@"should invoke restClient when appLoginParameters are set", ^{
                restClientMock = [EMSRESTClient mock];
                [[restClientMock should] receive:@selector(executeTaskWithRequestModel:successBlock:errorBlock:)];

                MEInbox *inbox = inboxWithParameters(restClientMock, YES);

                [inbox resetBadgeCountWithCompletionBlock:nil];
            });

            it(@"should not invoke restClient when appLoginParameters are not available", ^{
                restClientMock = [EMSRESTClient mock];
                [[restClientMock shouldNot] receive:@selector(executeTaskWithRequestModel:successBlock:errorBlock:)];

                MEInbox *inbox = inboxWithParameters(restClientMock, NO);

                [inbox resetBadgeCountWithCompletionBlock:nil];
            });

            it(@"should invoke restClient with the correct requestModel", ^{
                restClientMock = [EMSRESTClient mock];
                EMSRequestModel *expectedRequestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setMethod:HTTPMethodPOST];
                        [builder setUrl:@"https://me-inbox.eservice.emarsys.net/api/reset-badge-count"];
                        [builder setHeaders:expectedHeaders()];
                    }
                                                                       timestampProvider:[EMSTimestampProvider new]
                                                                            uuidProvider:[EMSUUIDProvider new]];

                [[restClientMock should] receive:@selector(executeTaskWithRequestModel:successBlock:errorBlock:)];
                KWCaptureSpy *requestModelSpy = [restClientMock captureArgument:@selector(executeTaskWithRequestModel:successBlock:errorBlock:)
                                                                        atIndex:0];
                MEInbox *inbox = inboxWithParameters(restClientMock, YES);

                [inbox resetBadgeCountWithCompletionBlock:nil];

                EMSRequestModel *capturedModel = requestModelSpy.argument;
                [[capturedModel should] beSimilarWithRequest:expectedRequestModel];
            });

            it(@"should invoke successBlock when success", ^{
                __block BOOL successBlockInvoked = NO;

                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
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

                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeFailure], YES);
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

                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeFailure], NO);
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
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
                [inbox resetBadgeCountWithCompletionBlock:nil];
            });

            it(@"should not invoke errorBlock when there is no errorBlock with apploginParameters", ^{
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeFailure], YES);
                [inbox resetBadgeCountWithCompletionBlock:nil];
            });

            it(@"should not invoke errorBlock when there is no errorBlock without apploginParameters", ^{
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeFailure], NO);
                [inbox resetBadgeCountWithCompletionBlock:nil];
            });

            it(@"should invoke successBlock on main thread", ^{
                __block BOOL onMainThread = NO;
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);

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
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeFailure], YES);

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
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeFailure], NO);

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
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
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
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
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
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
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
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
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
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);

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

            FakeStatusDelegate *(^createStatusDelegate)(void) = ^FakeStatusDelegate *() {
                FakeStatusDelegate *statusDelegate = [FakeStatusDelegate new];
                statusDelegate.printErrors = YES;
                return statusDelegate;
            };

            it(@"should return with eventId, and finish with success for trackNotificationOpenWithNotification:", ^{
                [Emarsys setupWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                    [builder setMobileEngageApplicationCode:@"14C19-A121F"
                                        applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
                    [builder setMerchantId:@"dummyMerchantId"];
                    [builder setContactFieldId:@3];
                }]];

                EMSNotification *notification = [EMSNotification new];
                notification.sid = @"161e_D/1UiO/jCmE4";

                __block NSError *returnedError = [NSError mock];

                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [Emarsys.inbox trackMessageOpenWith:notification
                                    completionBlock:^(NSError *error) {
                                        returnedError = error;
                                        [expectation fulfill];
                                    }];
                [EMSWaiter waitForExpectations:@[expectation]
                                       timeout:20];
                [[returnedError should] beNil];
            });
        });

        describe(@"trackMessageOpenWithInboxMessage:", ^{

            __block MEInbox *inbox;

            beforeEach(^{
                inbox = createInbox();
            });

            afterEach(^{
                [requestContext reset];
            });

            id (^requestModel)(NSString *url, NSDictionary *payload) = ^id(NSString *url, NSDictionary *payload) {
                return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:url];
                        [builder setMethod:HTTPMethodPOST];
                        [builder setPayload:payload];
                        [builder setHeaders:@{@"Authorization": [EMSAuthentication createBasicAuthWithUsername:applicationCode
                                                                                                      password:applicationPassword]}];
                    }
                                      timestampProvider:[EMSTimestampProvider new]
                                           uuidProvider:[EMSUUIDProvider new]];
            };

            it(@"should throw exception when parameter is nil", ^{
                @try {
                    [createInbox() trackNotificationOpenWithNotification:nil];
                    fail(@"Expected Exception when inboxMessage is nil!");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should submit a corresponding RequestModel when there is no contact_field_id and contact_field_value", ^{

                EMSRequestModel *model = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open", @{
                    @"application_id": kAppId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"sid": @"testID",
                    @"source": @"inbox"
                });

                [[requestManagerMock should] receive:@selector(submitRequestModel:withCompletionBlock:)
                                       withArguments:kw_any(), kw_any()];

                KWCaptureSpy *spy = [requestManagerMock captureArgument:@selector(submitRequestModel:withCompletionBlock:)
                                                                atIndex:0];
                EMSNotification *message = [EMSNotification new];
                message.sid = @"testID";
                [inbox trackNotificationOpenWithNotification:message];

                EMSRequestModel *actualModel = spy.argument;
                [[model should] beSimilarWithRequest:actualModel];
            });

            it(@"should submit a corresponding RequestModel when there are contact_field_id and contact_field_value", ^{
                EMSRequestModel *model = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open", @{
                    @"application_id": kAppId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"sid": @"valueOfSid",
                    @"contact_field_id": @3,
                    @"contact_field_value": @"contactFieldValue",
                    @"source": @"inbox"
                });

                [requestContext setAppLoginParameters:[[MEAppLoginParameters alloc] initWithContactFieldId:@3
                                                                                         contactFieldValue:@"contactFieldValue"]];
                [[requestManagerMock should] receive:@selector(submitRequestModel:withCompletionBlock:)
                                       withArguments:kw_any(), kw_any()];

                KWCaptureSpy *spy = [requestManagerMock captureArgument:@selector(submitRequestModel:withCompletionBlock:)
                                                                atIndex:0];
                EMSNotification *message = [EMSNotification new];
                message.sid = @"valueOfSid";
                [inbox trackNotificationOpenWithNotification:message];

                EMSRequestModel *actualModel = spy.argument;
                [[model should] beSimilarWithRequest:actualModel];
            });

            it(@"should submit a corresponding RequestModel", ^{
                EMSRequestModel *model = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open", @{
                    @"application_id": kAppId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"sid": @"valueOfSid",
                    @"source": @"inbox"
                });

                [[requestManagerMock should] receive:@selector(submitRequestModel:withCompletionBlock:)
                                       withArguments:kw_any(), kw_any()];

                KWCaptureSpy *spy = [requestManagerMock captureArgument:@selector(submitRequestModel:withCompletionBlock:)
                                                                atIndex:0];
                EMSNotification *message = [EMSNotification new];
                message.sid = @"valueOfSid";
                [inbox trackNotificationOpenWithNotification:message];

                EMSRequestModel *actualModel = spy.argument;
                [[model should] beSimilarWithRequest:actualModel];
            });

            it(@"should submit requestModel", ^{
                EMSNotification *message = [EMSNotification new];
                message.sid = @"testID";

                [[requestManagerMock should] receive:@selector(submitRequestModel:withCompletionBlock:)];

                [inbox trackNotificationOpenWithNotification:message];
            });
        });

SPEC_END