//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSConfigBuilder.h"
#import "EMSConfig.h"
#import "EMSNotificationInboxStatus.h"
#import "MEExperimental+Test.h"
#import "MERequestContext.h"
#import "EMSWaiter.h"
#import "Emarsys.h"

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestMEDB.db"]
#define DB_PATH [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"EMSSQLiteQueueDB.db"]
#define ME_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"MEDB.db"]

SPEC_BEGIN(InboxV2IntegrationTests)


        beforeEach(^{
            [[NSFileManager defaultManager] removeItemAtPath:DB_PATH
                                                       error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                                       error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:ME_DB_PATH
                                                       error:nil];
            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
            [userDefaults removeObjectForKey:kMEID];
            [userDefaults removeObjectForKey:kMEID_SIGNATURE];
            [userDefaults removeObjectForKey:kEMSLastAppLoginPayload];
            [userDefaults synchronize];

            EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                [builder setMobileEngageApplicationCode:@"14C19-A121F"
                                    applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
                [builder setExperimentalFeatures:@[USER_CENTRIC_INBOX]];
                [builder setMerchantId:@"dummyMerchantId"];
                [builder setContactFieldId:@3];
            }];
            [Emarsys setupWithConfig:config];

            XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
            [Emarsys setCustomerWithId:@"test@test.com"
                       completionBlock:^(NSError *error) {
                           [expectation fulfill];
                       }];
            [EMSWaiter waitForExpectations:@[expectation]
                                   timeout:30];
        });

        afterEach(^{
            [Emarsys clearCustomer];
            [MEExperimental reset];
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
