#import "Kiwi.h"
#import "EMSNotificationCache.h"

SPEC_BEGIN(EMSNotificationCacheTests)

        EMSNotification *(^createNotification)(NSString *id, NSString *sid, NSString *title) = ^EMSNotification *(NSString *id, NSString *sid, NSString *title) {
            return [[EMSNotification alloc] initWithNotificationDictionary:@{@"id": id,
                @"sid": sid,
                @"title": title,
                @"body": @"bodyOfTheNotifications",
                @"custom_data": @{@"custom": @"data"},
                @"root_params": @{},
                @"expiration_time": @123678,
                @"received_at": @145678}];
        };

        __block EMSNotification *notification1;
        __block EMSNotification *notification2;
        __block EMSNotification *notification3;
        __block EMSNotification *notification4;
        __block EMSNotification *notification5;

        beforeEach(^{
            notification1 = createNotification(@"id1", @"sid1", @"title1");
            notification2 = createNotification(@"id2", @"sid2", @"title2");
            notification3 = createNotification(@"id3", @"sid3", @"title3");
            notification4 = createNotification(@"id4", @"sid4", @"title4");
            notification5 = createNotification(@"id5", @"sid5", @"title5");
        });

        describe(@"init", ^{

            it(@"should create empty notifications array", ^{
                [[[[[EMSNotificationCache alloc] init] notifications] should] beEmpty];
            });
        });

        describe(@"cache:", ^{

            it(@"should store notification", ^{
                EMSNotificationCache *notificationCache = [[EMSNotificationCache alloc] init];
                NSDictionary *userInfo = @{
                    @"inbox": @YES,
                    @"u": @{
                        @"deep_link": @"lifestylelabels.com/mobile/product/3245678",
                        @"ems_default_title_unused": @"This is a default title",
                        @"image": @"https://media.giphy.com/media/ktvFa67wmjDEI/giphy.gif",
                        @"sid": @"1d0a_wqdXUl9Vf9NC",
                        @"test_field": @""
                    },
                    @"rootKey": @"rootValue",
                    @"id": @"210268110.1502804498499608577561.BF04349F-87B6-4CB9-859D-6CDE607F7251",
                    @"aps": @{
                        @"alert": @"MESS",
                        @"sound": @"default"
                    }
                };
                EMSNotification *notification = [[EMSNotification alloc] initWithUserInfo:userInfo timestampProvider:nil];

                [notificationCache cache:notification];

                [[notificationCache.notifications should] contain:notification];
            });

            it(@"should not cache notification when notification is nil", ^{
                EMSNotificationCache *notificationCache = [[EMSNotificationCache alloc] init];

                [notificationCache cache:notification1];

                [[[notificationCache notifications] should] equal:@[notification1]];

                [notificationCache cache:nil];

                [[[notificationCache notifications] should] equal:@[notification1]];
            });

            it(@"should cache notifications in correct order", ^{
                EMSNotificationCache *notificationCache = [[EMSNotificationCache alloc] init];
                [notificationCache cache:notification1];
                [notificationCache cache:notification2];

                [[[notificationCache notifications] should] equal:@[notification2, notification1]];
            });
        });

        describe(@"mergeWithNotifications:", ^{
            it(@"should return with cached notifications when the given notification array is nil", ^{
                EMSNotificationCache *notificationCache = [[EMSNotificationCache alloc] init];
                [notificationCache cache:notification1];

                NSArray *mergedNotifications = [notificationCache mergeWithNotifications:nil];
                [[mergedNotifications should] equal:@[notification1]];
            });

            it(@"should add the fetched notifications when merging", ^{
                EMSNotificationCache *notificationCache = [[EMSNotificationCache alloc] init];
                [notificationCache cache:notification3];
                [notificationCache cache:notification2];
                [notificationCache cache:notification1];
                NSArray *mergedNotifications = [notificationCache mergeWithNotifications:@[notification4, notification5]];

                [[mergedNotifications should] equal:@[notification1, notification2, notification3, notification4, notification5]];
            });

            it(@"should invalidate the cachedNotifications automatically", ^{
                EMSNotificationCache *notificationCache = [[EMSNotificationCache alloc] init];
                [notificationCache cache:notification3];
                [notificationCache cache:notification2];
                [notificationCache cache:notification1];

                NSArray *mergedNotifications = [notificationCache mergeWithNotifications:@[notification3, notification4, notification5]];

                [[mergedNotifications should] equal:@[notification1, notification2, notification3, notification4, notification5]];

            });
        });

        describe(@"internal cachedNotifications array", ^{
            it(@"should invalidate the cachedNotifications automatically", ^{
                EMSNotificationCache *notificationCache = [[EMSNotificationCache alloc] init];
                [notificationCache cache:notification3];
                [notificationCache cache:notification2];
                [notificationCache cache:notification1];

                [notificationCache mergeWithNotifications:@[notification3, notification4, notification5]];

                [[notificationCache.notifications should] equal:@[notification1, notification2]];

            });
        });

SPEC_END