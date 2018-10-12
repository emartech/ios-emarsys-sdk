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
                __block EMSNotificationInboxStatus *_inboxStatus;
                __block NSError *_error;

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];

                [Emarsys.inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
                    if (error) {
                        _error = error;
                        fail(@"Unexpected error");
                    } else {
                        _inboxStatus = inboxStatus;
                        [exp fulfill];
                    }
                }];

                [EMSWaiter waitForExpectations:@[exp]
                                       timeout:30];

                [[theValue([_inboxStatus.notifications count]) should] beGreaterThan:theValue(0)];

                __block NSError *returnedError = [NSError mock];

                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [Emarsys.inbox trackMessageOpenWith:_inboxStatus.notifications.firstObject
                                    completionBlock:^(NSError *error) {
                                        returnedError = error;
                                        [expectation fulfill];
                                    }];
                [EMSWaiter waitForExpectations:@[expectation]
                                       timeout:30];

                [[_error should] beNil];
                [[returnedError should] beNil];
            });

        });

SPEC_END
