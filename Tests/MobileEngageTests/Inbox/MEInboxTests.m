#import "Kiwi.h"
#import "MobileEngage.h"
#import "MEConfigBuilder.h"
#import "MEConfig.h"
#import "EMSDeviceInfo.h"
#import "MEDefaultHeaders.h"
#import "MEAppLoginParameters.h"
#import "FakeInboxNotificationRestClient.h"
#import "MEInbox+Private.h"
#import "EMSRequestModelBuilder.h"
#import "EMSRequestModelMatcher.h"
#import "MEInboxNotificationProtocol.h"
#import "FakeStatusDelegate.h"
#import "EMSAuthentication.h"
#import "MEExperimental+Test.h"
#import "MERequestContext.h"
#import "EMSUUIDProvider.h"

static NSString *const kAppId = @"kAppId";

SPEC_BEGIN(MEInboxTests)

        registerMatchers(@"EMS");

        NSString *applicationCode = kAppId;
        NSString *applicationPassword = @"appSecret";
        NSNumber *contactFieldId = @3;
        NSString *contactFieldValue = @"valueOfContactField";

        MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
            [builder setCredentialsWithApplicationCode:applicationCode
                                   applicationPassword:applicationPassword];
        }];

        id (^inboxWithParameters)(EMSRESTClient *restClient, BOOL withApploginParameters) = ^id(EMSRESTClient *restClient, BOOL withApploginParameters) {

            MERequestContext *context = [[MERequestContext alloc] initWithConfig:config];
            if (withApploginParameters) {
                [context setAppLoginParameters:[MEAppLoginParameters parametersWithContactFieldId:contactFieldId
                                                                                contactFieldValue:contactFieldValue]];
            }

            MEInbox *inbox = [[MEInbox alloc] initWithRestClient:restClient
                                                          config:config
                                                  requestContext:context];
            return inbox;
        };

        id (^inboxNotifications)() = ^id() {
            MEInbox *inbox = [[MEInbox alloc] initWithRestClient:[EMSRESTClient mock]
                                                          config:config
                                                  requestContext:nil];

            return inbox;
        };

        id (^expectedHeaders)() = ^id() {
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

        describe(@"inbox.fetchNotificationsWithResultBlock", ^{

            it(@"should not return nil in resultBlock", ^{
                __block MENotificationInboxStatus *result;
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);

                [inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                    result = inboxStatus;
                }                             errorBlock:^(NSError *error) {

                }];
                [[expectFutureValue(result) shouldNotEventually] beNil];
            });

            it(@"should run asyncronously", ^{
                __block MENotificationInboxStatus *result;
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);

                [inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                    result = inboxStatus;
                }                             errorBlock:^(NSError *error) {

                }];
                [[result should] beNil];
                [[expectFutureValue(result) shouldNotEventually] beNil];
            });

            it(@"should call EMSRestClient's executeTaskWithRequestModel: and parse the notifications correctly", ^{
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
                __block NSArray<MENotification *> *_notifications;
                [inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                    _notifications = inboxStatus.notifications;
                }                             errorBlock:^(NSError *error) {
                    fail(@"errorblock invoked");
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

                NSMutableArray<MENotification *> *notifications = [NSMutableArray array];
                for (NSDictionary *notificationDict in jsonResponse[@"notifications"]) {
                    [notifications addObject:[[MENotification alloc] initWithNotificationDictionary:notificationDict]];
                }

                [[expectFutureValue(_notifications) shouldEventually] equal:notifications];
            });

            it(@"should call EMSRestClient's executeTaskWithRequestModel: with correct RequestModel", ^{
                EMSRESTClient *client = [EMSRESTClient mock];
                MEInbox *inbox = inboxWithParameters(client, YES);

                KWCaptureSpy *requestModelSpy = [client captureArgument:@selector(executeTaskWithRequestModel:successBlock:errorBlock:)
                                                                atIndex:0];
                [inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                    }
                                              errorBlock:nil];

                EMSRequestModel *capturedRequestModel = requestModelSpy.argument;

                [[capturedRequestModel.url should] equal:[NSURL URLWithString:@"https://me-inbox.eservice.emarsys.net/api/notifications"]];
                [[capturedRequestModel.method should] equal:@"GET"];
                [[capturedRequestModel.headers should] equal:expectedHeaders()];
            });

            it(@"should throw an exception, when resultBlock is nil", ^{
                MEInbox *inbox = inboxWithParameters([EMSRESTClient mock], NO);
                @try {
                    [inbox fetchNotificationsWithResultBlock:nil
                                                  errorBlock:^(NSError *error) {
                                                  }];
                    fail(@"Assertion doesn't called!");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should invoke resultBlock on main thread", ^{
                __block NSNumber *onMainThread = @NO;
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);

                [inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                    if ([NSThread isMainThread]) {
                        onMainThread = @YES;
                    }
                }                             errorBlock:nil];
                [[expectFutureValue(onMainThread) shouldEventually] equal:@YES];
            });

            it(@"should invoke errorBlock on main thread", ^{
                __block NSNumber *onMainThread = @NO;

                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeFailure], YES);
                [inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                    fail(@"resultblock invoked");
                }                             errorBlock:^(NSError *error) {
                    if ([NSThread isMainThread]) {
                        onMainThread = @YES;
                    }
                }];
                [[expectFutureValue(onMainThread) shouldEventually] equal:@YES];
            });

            it(@"should invoke errorBlock when applogin parameters are not available", ^{
                MEInbox *inbox = inboxWithParameters([EMSRESTClient mock], NO);
                __block NSError *receivedError;
                [inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                        fail(@"resultblock invoked");
                    }
                                              errorBlock:^(NSError *error) {
                                                  receivedError = error;
                                              }];
                [[expectFutureValue(receivedError) shouldNotEventually] beNil];
            });

            it(@"should not invoke errorBlock when there is no errorBlock with appLoginParameters", ^{
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeFailure], YES);
                [inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                        fail(@"resultblock invoked");
                    }
                                              errorBlock:nil];
            });

            it(@"should not invoke errorBlock when there is no errorBlock without appLoginParameters", ^{
                MEInbox *inbox = inboxWithParameters([EMSRESTClient mock], NO);
                [inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                        fail(@"resultblock invoked");
                    }
                                              errorBlock:nil];
            });
        });

        describe(@"inbox.resetBadgeCountWithSuccessBlock:errorBlock:", ^{

            it(@"should invoke restClient when appLoginParameters are set", ^{
                EMSRESTClient *restClientMock = [EMSRESTClient mock];
                [[restClientMock should] receive:@selector(executeTaskWithRequestModel:successBlock:errorBlock:)];

                MEInbox *inbox = inboxWithParameters(restClientMock, YES);

                [inbox resetBadgeCountWithSuccessBlock:nil
                                            errorBlock:nil];
            });

            it(@"should not invoke restClient when appLoginParameters are not available", ^{
                EMSRESTClient *restClientMock = [EMSRESTClient mock];
                [[restClientMock shouldNot] receive:@selector(executeTaskWithRequestModel:successBlock:errorBlock:)];

                MEInbox *inbox = inboxWithParameters(restClientMock, NO);

                [inbox resetBadgeCountWithSuccessBlock:nil
                                            errorBlock:nil];
            });

            it(@"should invoke restClient with the correct requestModel", ^{
                EMSRequestModel *expectedRequestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setMethod:HTTPMethodPOST];
                        [builder setUrl:@"https://me-inbox.eservice.emarsys.net/api/reset-badge-count"];
                        [builder setHeaders:expectedHeaders()];
                    }
                                                                       timestampProvider:[EMSTimestampProvider new]
                                                                            uuidProvider:[EMSUUIDProvider new]];

                EMSRESTClient *restClientMock = [EMSRESTClient mock];
                [[restClientMock should] receive:@selector(executeTaskWithRequestModel:successBlock:errorBlock:)];
                KWCaptureSpy *requestModelSpy = [restClientMock captureArgument:@selector(executeTaskWithRequestModel:successBlock:errorBlock:)
                                                                        atIndex:0];
                MEInbox *inbox = inboxWithParameters(restClientMock, YES);

                [inbox resetBadgeCountWithSuccessBlock:nil
                                            errorBlock:nil];

                EMSRequestModel *capturedModel = requestModelSpy.argument;
                [[capturedModel should] beSimilarWithRequest:expectedRequestModel];
            });

            it(@"should invoke successBlock when success", ^{
                __block BOOL successBlockInvoked = NO;

                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
                [inbox resetBadgeCountWithSuccessBlock:^{
                        successBlockInvoked = YES;
                    }
                                            errorBlock:^(NSError *error) {
                                                fail(@"errorblock invoked");
                                            }];
                [[expectFutureValue(theValue(successBlockInvoked)) shouldEventually] beYes];
            });

            it(@"should invoke errorBlock when failure with apploginParameters", ^{
                __block NSError *_error;

                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeFailure], YES);
                [inbox resetBadgeCountWithSuccessBlock:^{
                        fail(@"successblock invoked");
                    }
                                            errorBlock:^(NSError *error) {
                                                _error = error;
                                            }];
                [[_error shouldNotEventually] beNil];
            });

            it(@"should invoke errorBlock when failure without apploginParameters", ^{
                __block NSError *_error;

                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeFailure], NO);
                [inbox resetBadgeCountWithSuccessBlock:^{
                        fail(@"successblock invoked");
                    }
                                            errorBlock:^(NSError *error) {
                                                _error = error;
                                            }];
                [[_error shouldNotEventually] beNil];
            });

            it(@"should not invoke successBlock when there is no successBlock", ^{
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
                [inbox resetBadgeCountWithSuccessBlock:nil
                                            errorBlock:nil];
            });

            it(@"should not invoke errorBlock when there is no errorBlock with apploginParameters", ^{
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeFailure], YES);
                [inbox resetBadgeCountWithSuccessBlock:nil
                                            errorBlock:nil];
            });

            it(@"should not invoke errorBlock when there is no errorBlock without apploginParameters", ^{
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeFailure], NO);
                [inbox resetBadgeCountWithSuccessBlock:nil
                                            errorBlock:nil];
            });

            it(@"should invoke successBlock on main thread", ^{
                __block BOOL onMainThread = NO;
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);

                [inbox resetBadgeCountWithSuccessBlock:^{
                        if ([NSThread isMainThread]) {
                            onMainThread = YES;
                        }
                    }
                                            errorBlock:^(NSError *error) {
                                                fail(@"errorblock invoked");
                                            }];
                [[expectFutureValue(theValue(onMainThread)) shouldEventually] beYes];
            });

            it(@"should invoke errorBlock on main thread", ^{
                __block BOOL onMainThread = NO;
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeFailure], YES);

                [inbox resetBadgeCountWithSuccessBlock:^{
                        fail(@"successblock invoked");
                    }
                                            errorBlock:^(NSError *error) {
                                                if ([NSThread isMainThread]) {
                                                    onMainThread = YES;
                                                }
                                            }];
                [[expectFutureValue(theValue(onMainThread)) shouldEventually] beYes];
            });

            it(@"should invoke errorBlock on main thread when apploginParameters are not set", ^{
                __block BOOL onMainThread = NO;
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeFailure], NO);

                [inbox resetBadgeCountWithSuccessBlock:^{
                        fail(@"successblock invoked");
                    }
                                            errorBlock:^(NSError *error) {
                                                if ([NSThread isMainThread]) {
                                                    onMainThread = YES;
                                                }
                                            }];
                [[expectFutureValue(theValue(onMainThread)) shouldEventually] beYes];
            });
        });

        describe(@"inbox.resetBadgeCount", ^{
            it(@"should call resetBadgeCountWithSuccessBlock:errorBlock:", ^{
                MEInbox *inbox = [MEInbox new];
                __block NSNumber *resetCalled;
                [inbox stub:@selector(resetBadgeCountWithSuccessBlock:errorBlock:) withBlock:^id(NSArray *params) {
                    resetCalled = @YES;
                    return nil;
                }];

                [inbox resetBadgeCount];

                [[expectFutureValue(resetCalled) shouldNotEventually] beNil];
            });
        });

        describe(@"inbox.addNotification:", ^{
            it(@"should increase the notifications with the notification", ^{
                MEInbox *inbox = inboxNotifications();
                MENotification *notification = [MENotification new];

                [[theValue([inbox.notifications count]) should] equal:theValue(0)];
                [inbox addNotification:notification];
                [[theValue([inbox.notifications count]) should] equal:theValue(1)];
            });
        });

        describe(@"inbox.fetchNotificationsWithResultBlock include cached notifications", ^{
            it(@"should return with the added notification", ^{
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
                MENotification *notification = [MENotification new];
                [inbox addNotification:notification];

                __block MENotificationInboxStatus *status;
                [inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                    status = inboxStatus;
                }                             errorBlock:^(NSError *error) {
                }];

                [[expectFutureValue(theValue([status.notifications containsObject:notification])) shouldEventually] beYes];
            });

            it(@"should be idempotent", ^{
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
                MENotification *notification = [MENotification new];
                [inbox addNotification:notification];

                __block MENotificationInboxStatus *status1;
                __block MENotificationInboxStatus *status2;
                [inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                    status1 = inboxStatus;
                }                             errorBlock:^(NSError *error) {
                }];

                [inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                    status2 = inboxStatus;
                }                             errorBlock:^(NSError *error) {
                }];

                [[expectFutureValue(@([status1.notifications count])) shouldEventually] equal:theValue(8)];
                [[expectFutureValue(@([status2.notifications count])) shouldEventually] equal:theValue(8)];
            });

            it(@"should return with the added notification in good order", ^{
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
                MENotification *notification = [MENotification new];
                notification.expirationTime = @12345678130;
                [inbox addNotification:notification];

                __block MENotificationInboxStatus *status;
                [inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                    status = inboxStatus;
                }                             errorBlock:^(NSError *error) {
                }];

                [[expectFutureValue([status.notifications firstObject]) shouldEventually] equal:notification];
            });

            it(@"should not add the notification if there is a notification already in with the same ID", ^{
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
                MENotification *notification = [MENotification new];
                notification.title = @"asdfghjk";
                notification.id = @"id1";
                [inbox addNotification:notification];

                __block MENotification *returnedNotification;
                [inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                    for (MENotification *noti in inboxStatus.notifications) {
                        if ([noti.id isEqualToString:notification.id]) {
                            returnedNotification = noti;
                            break;
                        }
                    }
                }                             errorBlock:^(NSError *error) {
                    fail(@"error block invoked");
                }];

                [[expectFutureValue(returnedNotification.id) shouldEventually] equal:@"id1"];
                [[expectFutureValue(returnedNotification.title) shouldNotEventually] equal:@"asdfghjk"];
                [[expectFutureValue(returnedNotification.title) shouldEventually] equal:@"title1"];
            });

            it(@"should remove notifications from cache when they are already present in the fetched list", ^{
                MEInbox *inbox = inboxWithParameters([[FakeInboxNotificationRestClient alloc] initWithResultType:ResultTypeSuccess], YES);

                MENotification *notification1 = [MENotification new];
                notification1.title = @"asdfghjk";
                notification1.id = @"id1";
                [inbox addNotification:notification1];

                MENotification *notification2 = [MENotification new];
                notification2.title = @"asdfghjk";
                notification2.id = @"id0";
                [inbox addNotification:notification2];

                __block MENotification *returnedNotification;
                [inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                    for (MENotification *noti in inboxStatus.notifications) {
                        if ([noti.id isEqualToString:notification1.id]) {
                            returnedNotification = noti;
                            break;
                        }
                    }
                }                             errorBlock:^(NSError *error) {
                    fail(@"error block invoked");
                }];

                [[expectFutureValue(returnedNotification.id) shouldEventually] equal:@"id1"];

                [[expectFutureValue(theValue([[inbox notifications] count])) shouldEventually] equal:@1];
                [[expectFutureValue([inbox notifications][0]) shouldEventually] equal:notification2];
            });

        });

        describe(@"inbox.trackMessageOpen", ^{

            FakeStatusDelegate *(^createStatusDelegate)() = ^FakeStatusDelegate *() {
                FakeStatusDelegate *statusDelegate = [FakeStatusDelegate new];
                statusDelegate.printErrors = YES;
                return statusDelegate;
            };

            it(@"should return with eventId, and finish with success for trackMessageOpenWithInboxMessage:", ^{
                MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:@"14C19-A121F"
                                           applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
                }];
                [MobileEngage setupWithConfig:config
                                launchOptions:nil];
                FakeStatusDelegate *statusDelegate = createStatusDelegate();
                [MobileEngage setStatusDelegate:statusDelegate];

                MENotification *notification = [MENotification new];
                notification.sid = @"161e_D/1UiO/jCmE4";
                NSString *eventId = [MobileEngage.inbox trackMessageOpenWithInboxMessage:notification];

                [[eventId shouldNot] beNil];
                [[expectFutureValue(@(statusDelegate.successCount)) shouldEventually] equal:@1];
                [[expectFutureValue(@(statusDelegate.errorCount)) shouldEventually] equal:@0];
            });
        });

SPEC_END