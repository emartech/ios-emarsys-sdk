#import "Kiwi.h"
#import "MEInboxParser.h"
#import "EMSNotification.h"
#import "EMSNotificationInboxStatus.h"

SPEC_BEGIN(MEInboxParserTests)

        describe(@"InboxParser.parseNotificationInboxStatus:", ^{
            it(@"should not return nil", ^{
                MEInboxParser *parser = [MEInboxParser new];
                EMSNotificationInboxStatus *result = [parser parseNotificationInboxStatus:@{}];
                [[theValue(result) shouldNot] beNil];
            });

            it(@"should return with correct notificationStatus", ^{
                MEInboxParser *parser = [MEInboxParser new];
                NSDictionary *notificationInboxStatus = @{
                        @"notifications": @[
                                @{@"id": @"id1", @"sid": @"sid1", @"title": @"title1", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678.123)},
                                @{@"id": @"id7", @"sid": @"sid2", @"title": @"title7", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678.123)}
                        ],
                        @"badge_count": @3
                };
                NSMutableArray<EMSNotification *> *expectedNotifications = [NSMutableArray array];
                for (NSDictionary *notificationDict in notificationInboxStatus[@"notifications"]) {
                    [expectedNotifications addObject:[[EMSNotification alloc] initWithNotificationDictionary:notificationDict]];
                }
                EMSNotificationInboxStatus *result = [parser parseNotificationInboxStatus:notificationInboxStatus];

                [[result.notifications should] equal:expectedNotifications];
                [[theValue(result.badgeCount) should] equal:theValue(3)];
            });
        });

        describe(@"InboxParser.parseArrayOfNotifications:", ^{
            it(@"should not return nil", ^{
                MEInboxParser *parser = [MEInboxParser new];
                NSArray<EMSNotification *> *result = [parser parseArrayOfNotifications:@[]];
                [[theValue(result) shouldNot] beNil];
            });

            it(@"should create the correct array", ^{
                MEInboxParser *parser = [MEInboxParser new];
                NSDictionary *notificationInboxStatus = @{
                        @"notifications": @[
                                @{@"id": @"id1", @"sid": @"sid1", @"title": @"title1", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678.123)},
                                @{@"id": @"id7", @"sid": @"sid2", @"title": @"title7", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678.123)}
                        ],
                        @"badge_count": @3
                };
                NSMutableArray<EMSNotification *> *expectedNotifications = [NSMutableArray array];
                for (NSDictionary *notificationDict in notificationInboxStatus[@"notifications"]) {
                    [expectedNotifications addObject:[[EMSNotification alloc] initWithNotificationDictionary:notificationDict]];
                }
                NSArray<EMSNotification *> *result = [parser parseArrayOfNotifications:notificationInboxStatus[@"notifications"]];

                [[result should] equal:expectedNotifications];
            });
        });

        describe(@"InboxParser.parseNotification:", ^{
                it(@"should not return nil", ^{
                    MEInboxParser *parser = [MEInboxParser new];
                    EMSNotification *result = [parser parseNotification:@{}];
                    [[theValue(result) shouldNot] beNil];
                });

                it(@"should create the correct notification", ^{
                    MEInboxParser *parser = [MEInboxParser new];
                    NSDictionary *notificationDict = @{@"id": @"id7", @"sid": @"sid1", @"title": @"title7", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678123)};
                    EMSNotification *notification = [parser parseNotification:notificationDict];
                    [[notification.id should] equal:@"id7"];
                    [[notification.sid should] equal:@"sid1"];
                    [[notification.title should] equal:@"title7"];
                    [[notification.customData should] equal:@{}];
                    [[notification.rootParams should] equal:@{}];
                    [[notification.expirationTime should] equal:@7200];
                    [[notification.receivedAtTimestamp should] equal:@12345678123];
                });

                it(@"should create the correct notification with body as well", ^{
                    MEInboxParser *parser = [MEInboxParser new];
                    NSDictionary *notificationDict = @{@"id": @"id7", @"sid": @"sid1", @"title": @"title7", @"body": @"body7", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678123)};
                    EMSNotification *notification = [parser parseNotification:notificationDict];
                    [[notification.id should] equal:@"id7"];
                    [[notification.sid should] equal:@"sid1"];
                    [[notification.title should] equal:@"title7"];
                    [[notification.body should] equal:@"body7"];
                    [[notification.customData should] equal:@{}];
                    [[notification.rootParams should] equal:@{}];
                    [[notification.expirationTime should] equal:@7200];
                    [[notification.receivedAtTimestamp should] equal:@12345678123];
                });

        });

SPEC_END