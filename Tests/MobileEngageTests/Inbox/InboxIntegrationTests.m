#import "Kiwi.h"
#import "MobileEngage.h"
#import "MEConfigBuilder.h"
#import "MEConfig.h"
#import "MENotificationInboxStatus.h"

#define DB_PATH [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"EMSSQLiteQueueDB.db"]

SPEC_BEGIN(InboxIntegrationTests)

    beforeEach(^{
        [[NSFileManager defaultManager] removeItemAtPath:DB_PATH
                                                   error:nil];

        MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
            [builder setCredentialsWithApplicationCode:@"14C19-A121F"
                                   applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
        }];
        [MobileEngage setupWithConfig:config
                        launchOptions:nil];

        [MobileEngage appLoginWithContactFieldId:@3
                               contactFieldValue:@"test@test.com"];
    });

    describe(@"Notification Inbox", ^{

        it(@"fetchNotificationsWithResultBlock", ^{
            __block MENotificationInboxStatus *_inboxStatus;
            __block NSError *_error;

            [MobileEngage.inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                _inboxStatus = inboxStatus;
            }                                          errorBlock:^(NSError *error) {
                _error = error;
            }];

            [[_error shouldEventually] beNil];
            [[_inboxStatus shouldNotEventually] beNil];
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
            [MobileEngage trackMessageOpenWithUserInfo:userInfo];

            __block MENotification *returnedNotification;
            XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
            [MobileEngage.inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                        for (MENotification *noti in inboxStatus.notifications) {
                            if ([noti.id isEqualToString:notificationId]) {
                                returnedNotification = noti;
                                break;
                            }
                        }
                        [exp fulfill];
                    }
                                                       errorBlock:^(NSError *error) {
                                                           fail(@"error block invoked");
                                                       }];

            [XCTWaiter waitForExpectations:@[exp] timeout:30];

            [[returnedNotification shouldNot] beNil];
            [[returnedNotification.id should] equal:notificationId];
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
            [MobileEngage trackMessageOpenWithUserInfo:userInfo];

            __block MENotification *returnedNotification;
            XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
            [MobileEngage.inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                        for (MENotification *noti in inboxStatus.notifications) {
                            if ([noti.id isEqualToString:notificationId]) {
                                returnedNotification = noti;
                                break;
                            }
                        }
                        [exp fulfill];
                    }
                                                       errorBlock:^(NSError *error) {
                                                           fail(@"error block invoked");
                                                       }];

            [XCTWaiter waitForExpectations:@[exp] timeout:30];

            [[returnedNotification shouldNot] beNil];
            [[returnedNotification.id should] equal:notificationId];
            [[returnedNotification.title should] equal:@"title"];
            [[returnedNotification.body should] equal:@"body"];
        });

        it(@"fetchNotificationsWithResultBlock result should not contain the gained notification", ^{
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
            [MobileEngage trackMessageOpenWithUserInfo:userInfo];

            __block MENotificationInboxStatus *resultInboxStatus;
            XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"wait"];
            [MobileEngage.inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                        resultInboxStatus = inboxStatus;
                        for (MENotification *noti in inboxStatus.notifications) {
                            if ([noti.id isEqualToString:notificationId]) {
                                fail(@"fail");
                            }
                        }
                        [exp fulfill];
                    }
                                                       errorBlock:^(NSError *error) {
                                                           fail(@"error block invoked");
                                                           [exp fulfill];
                                                       }];

            [XCTWaiter waitForExpectations:@[exp] timeout:30];

            [[resultInboxStatus shouldNot] beNil];
        });

        it(@"resetBadgeCount", ^{
            __block BOOL _success = NO;
            __block BOOL _error = YES;

            [MobileEngage.inbox resetBadgeCountWithSuccessBlock:^{
                _success = YES;
                _error = NO;
            }                                        errorBlock:^(NSError *error) {
            }];

            [[theValue(_success) shouldNotEventually] beYes];
            [[theValue(_error) shouldEventually] beNo];
        });

    });

SPEC_END
