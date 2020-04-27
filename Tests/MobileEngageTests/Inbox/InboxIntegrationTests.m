#import "Kiwi.h"
#import "EMSNotificationInboxStatus.h"
#import "EMSWaiter.h"
#import "Emarsys.h"
#import "EmarsysTestUtils.h"
#import "NSError+EMSCore.h"

#define DB_PATH [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"EMSSQLiteQueueDB.db"]

SPEC_BEGIN(InboxIntegrationTests)

        beforeEach(^{
            [EmarsysTestUtils tearDownEmarsys];
            [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                               withDependencyContainer:nil];
            [EmarsysTestUtils waitForSetPushToken];
            [EmarsysTestUtils waitForSetCustomer];
        });

        afterEach(^{
            [EmarsysTestUtils tearDownEmarsys];
        });

        describe(@"Notification Inbox", ^{

            it(@"fetchNotificationsWithResultBlock", ^{
                __block EMSNotificationInboxStatus *returnedStatus = nil;
                __block NSError *returnedError = [NSError errorWithCode:-1400
                                            localizedDescription:@"testError"];
                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];

                [Emarsys.inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    returnedError = error;
                    returnedStatus = inboxStatus;
                    [expectation fulfill];
                }];

                XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                                      timeout:5.0];
                XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
                XCTAssertNil(returnedError);
                XCTAssertNotNil(returnedStatus);
            });

            it(@"fetchNotificationsWithResultBlock result should contain the gained notification", ^{
                NSString *notificationId = @"210268110.1502804498499608577561.BF04349F-87B6-4CB9-859D-6CDE607F7251";
                NSNumber *inbox = @YES;
                NSDictionary *userInfo = @{
                        @"inbox": inbox,
                        @"u": @{
                                @"deep_link": @"lifestylelabels.com/mobile/product/3245678",
                                @"ems_default_title_unused": @"This is a default title",
                                @"image": @"https://media.giphy.com/media/ktvFa67wmjDEI/giphy.gif",
                                @"sid": @"1d0a_wqdXUl9Vf9NC",
                                @"test_field": @""
                        },
                        @"rootKey": @"rootValue",
                        @"id": notificationId,
                        @"aps": @{
                                @"alert": @"MESS",
                                @"sound": @"default"
                        }
                };

                [Emarsys.push trackMessageOpenWithUserInfo:userInfo];

                __block EMSNotification *returnedNotification;
                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [Emarsys.inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (error) {
                        fail(@"error block invoked");
                    } else {
                        for (EMSNotification *noti in inboxStatus.notifications) {
                            if ([noti.id isEqualToString:notificationId]) {
                                returnedNotification = noti;
                                break;
                            }
                        }
                        [exp fulfill];
                    }
                }];

                [EMSWaiter waitForExpectations:@[exp]
                                       timeout:30];

                XCTAssertNotNil(returnedNotification);
                XCTAssertEqualObjects(returnedNotification.id, notificationId);
            });

            it(@"fetchNotificationsWithResultBlock result should contain the gained notification with title and body", ^{
                NSString *notificationId = @"210268110.1502804498499608577561.BF04349F-87B6-4CB9-859D-6CDE607F7251";
                NSNumber *inbox = @YES;
                NSDictionary *userInfo = @{
                        @"inbox": inbox,
                        @"u": @{
                                @"deep_link": @"lifestylelabels.com/mobile/product/3245678",
                                @"ems_default_title_unused": @"This is a default title",
                                @"image": @"https://media.giphy.com/media/ktvFa67wmjDEI/giphy.gif",
                                @"sid": @"1d0a_wqdXUl9Vf9NC",
                                @"test_field": @""
                        },
                        @"rootKey": @"rootValue",
                        @"id": notificationId,
                        @"aps": @{
                                @"alert": @{
                                        @"title": @"title",
                                        @"body": @"body"
                                },
                                @"sound": @"default"
                        }
                };

                [Emarsys.push trackMessageOpenWithUserInfo:userInfo];

                __block EMSNotification *returnedNotification;
                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [Emarsys.inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (error) {
                        fail(@"error block invoked");
                    } else {
                        for (EMSNotification *noti in inboxStatus.notifications) {
                            if ([noti.id isEqualToString:notificationId]) {
                                returnedNotification = noti;
                                break;
                            }
                        }
                        [exp fulfill];
                    }
                }];

                [EMSWaiter waitForExpectations:@[exp]
                                       timeout:5];

                XCTAssertNotNil(returnedNotification);
                XCTAssertEqualObjects(returnedNotification.id, notificationId);
                XCTAssertEqualObjects(returnedNotification.title, @"title");
                XCTAssertEqualObjects(returnedNotification.body, @"body");
            });

            it(@"fetchNotificationsWithResultBlock result should not contain the gained notification if it's not inbox message", ^{
                NSString *notificationId = @"210268110.1502804498499608577561.BF04349F-87B6-4CB9-859D-6CDE607F7251";
                NSNumber *inbox = @NO;
                NSDictionary *userInfo = @{
                        @"inbox": inbox,
                        @"u": @{
                                @"deep_link": @"lifestylelabels.com/mobile/product/3245678",
                                @"ems_default_title_unused": @"This is a default title",
                                @"image": @"https://media.giphy.com/media/ktvFa67wmjDEI/giphy.gif",
                                @"sid": @"1d0a_wqdXUl9Vf9NC",
                                @"test_field": @""
                        },
                        @"rootKey": @"rootValue",
                        @"id": notificationId,
                        @"aps": @{
                                @"alert": @"MESS",
                                @"sound": @"default"
                        }
                };
                [Emarsys.push trackMessageOpenWithUserInfo:userInfo];

                __block EMSNotificationInboxStatus *resultInboxStatus;
                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"wait"];
                [Emarsys.inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (error) {
                        fail(@"error block invoked");
                    } else {
                        resultInboxStatus = inboxStatus;
                        for (EMSNotification *noti in inboxStatus.notifications) {
                            if ([noti.id isEqualToString:notificationId]) {
                                fail(@"fail");
                            }
                        }
                        [exp fulfill];
                    }
                }];

                [EMSWaiter waitForExpectations:@[exp]
                                       timeout:30];

                XCTAssertNotNil(resultInboxStatus);
            });

            it(@"resetBadgeCount", ^{
                __block NSError *returnedError = [NSError errorWithCode:-1400
                                                   localizedDescription:@"testError"];
                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];

                [Emarsys.inbox resetBadgeCountWithCompletionBlock:^(NSError *error) {
                    returnedError = error;
                    [expectation fulfill];
                }];

                XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                                      timeout:5.0];

                XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
                XCTAssertNil(returnedError);
            });

        });

SPEC_END
