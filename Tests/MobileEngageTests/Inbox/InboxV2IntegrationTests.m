//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSNotificationInboxStatus.h"
#import "MEExperimental+Test.h"
#import "EMSWaiter.h"
#import "Emarsys.h"
#import "EmarsysTestUtils.h"

SPEC_BEGIN(InboxV2IntegrationTests)


        beforeEach(^{
            [EmarsysTestUtils setupEmarsysWithFeatures:@[USER_CENTRIC_INBOX] withDependencyContainer:nil];
            [EmarsysTestUtils waitForSetCustomer];
        });

        afterEach(^{
            [EmarsysTestUtils tearDownEmarsys];
        });

        describe(@"Notification Inbox", ^{

            it(@"fetchNotificationsWithResultBlock", ^{
                __block EMSNotificationInboxStatus *_inboxStatus;

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];

                [Emarsys.inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (error) {
                        fail(@"Unexpected error");
                    } else {
                        _inboxStatus = inboxStatus;
                        [exp fulfill];
                    }
                }];

                [EMSWaiter waitForExpectations:@[exp]
                                       timeout:30];

                [[_inboxStatus shouldNot] beNil];
            });


            it(@"resetBadgeCount", ^{
                __block BOOL _success = NO;

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];

                [Emarsys.inbox resetBadgeCountWithCompletionBlock:^(NSError *error) {
                    if (error) {
                        fail(@"Unexpected error");
                    } else {
                        _success = YES;
                        [exp fulfill];
                    }
                }];

                [EMSWaiter waitForExpectations:@[exp]
                                       timeout:30];

                [[theValue(_success) should] beYes];
            });

            it(@"trackMessageOpenWithInboxMessage", ^{
                NSArray<NSDictionary *> *notificationResponses = @[
                    @{@"sid": @"sid1", @"id": @"id1", @"title": @"title1", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678129)},
                    @{@"sid": @"sid2", @"id": @"id2", @"title": @"title2", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678128)},
                    @{@"sid": @"sid3", @"id": @"id3", @"title": @"title3", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678127)},
                ];
                NSMutableArray<EMSNotification *> *notifications = [NSMutableArray array];
                for (NSDictionary *notificationDict in notificationResponses) {
                    [notifications addObject:[[EMSNotification alloc] initWithNotificationDictionary:notificationDict]];
                }
                EMSNotificationInboxStatus *inboxStatus = [[EMSNotificationInboxStatus alloc] init];
                inboxStatus.notifications = notifications;

                __block NSError *returnedError = [NSError mock];

                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [Emarsys.inbox trackMessageOpenWith:inboxStatus.notifications.firstObject
                                    completionBlock:^(NSError *error) {
                                        returnedError = error;
                                        [expectation fulfill];
                                    }];
                [EMSWaiter waitForExpectations:@[expectation]
                                       timeout:30];

                [[returnedError should] beNil];
            });

        });

SPEC_END
