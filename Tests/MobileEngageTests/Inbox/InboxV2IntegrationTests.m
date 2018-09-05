//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "MobileEngage.h"
#import "EMSConfigBuilder.h"
#import "EMSConfig.h"
#import "MENotificationInboxStatus.h"
#import "MEExperimental+Test.h"
#import "FakeStatusDelegate.h"
#import "MERequestContext.h"
#import "EMSWaiter.h"

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
            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
            [userDefaults removeObjectForKey:kMEID];
            [userDefaults removeObjectForKey:kMEID_SIGNATURE];
            [userDefaults removeObjectForKey:kLastAppLoginPayload];
            [userDefaults synchronize];

            EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                [builder setCredentialsWithApplicationCode:@"14C19-A121F"
                                       applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
                [builder setExperimentalFeatures:@[USER_CENTRIC_INBOX]];
                [builder setMerchantId:@"dummyMerchantId"];
                [builder setContactFieldId:@3];
            }];
            [MobileEngage setupWithConfig:config
                            launchOptions:[NSDictionary new]];

            FakeStatusDelegate *statusDelegate = [FakeStatusDelegate new];

            [MobileEngage setStatusDelegate:statusDelegate];

            [MobileEngage appLoginWithContactFieldId:@3
                                   contactFieldValue:@"test@test.com"];

            [statusDelegate waitForNextSuccess];
        });

        afterEach(^{
            [MEExperimental reset];
        });

        describe(@"Notification Inbox", ^{

            it(@"fetchNotificationsWithResultBlock", ^{
                __block MENotificationInboxStatus *_inboxStatus;

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];

                [MobileEngage.inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                            _inboxStatus = inboxStatus;
                            [exp fulfill];
                        }
                                                           errorBlock:^(NSError *error) {
                                                               fail(@"Unexpected error");
                                                           }];

                [EMSWaiter waitForExpectations:@[exp] timeout:30];

                [[_inboxStatus shouldNot] beNil];
            });


            it(@"resetBadgeCount", ^{
                __block BOOL _success = NO;

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];

                [MobileEngage.inbox resetBadgeCountWithSuccessBlock:^{
                            _success = YES;
                            [exp fulfill];
                        }
                                                         errorBlock:^(NSError *error) {
                                                             fail(@"Unexpected error");
                                                         }];

                [EMSWaiter waitForExpectations:@[exp] timeout:30];

                [[theValue(_success) should] beYes];
            });

            it(@"trackMessageOpenWithInboxMessage", ^{
                __block MENotificationInboxStatus *_inboxStatus;
                __block NSError *_error;

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];

                [MobileEngage.inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                            _inboxStatus = inboxStatus;
                            [exp fulfill];
                        }
                                                           errorBlock:^(NSError *error) {
                                                               _error = error;
                                                               fail(@"Unexpected error");
                                                           }];

                [EMSWaiter waitForExpectations:@[exp] timeout:30];

                [[theValue([_inboxStatus.notifications count]) should] beGreaterThan:theValue(0)];

                FakeStatusDelegate *statusDelegate = [FakeStatusDelegate new];
                [MobileEngage setStatusDelegate:statusDelegate];

                [MobileEngage.inbox trackMessageOpenWithInboxMessage:_inboxStatus.notifications.firstObject];

                [statusDelegate waitForNextSuccess];

                [[_error should] beNil];
                [[theValue(statusDelegate.successCount) should] equal:@1];
                [[theValue(statusDelegate.errorCount) should] equal:@0];
            });

        });

SPEC_END
