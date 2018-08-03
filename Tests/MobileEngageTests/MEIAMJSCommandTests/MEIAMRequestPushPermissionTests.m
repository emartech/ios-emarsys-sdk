#import "Kiwi.h"
#import <UserNotifications/UserNotifications.h>
#import "MEIAMRequestPushPermission.h"
#import "MEOsVersionUtils.h"
#import "EMSWaiter.h"


SPEC_BEGIN(MEIAMRequestPushPermissionTests)

    __block UIApplication *_applicationMock;
    __block MEIAMRequestPushPermission *_command;

    describe(@"requestPushPermission", ^{

        beforeEach(^{
            _command = [MEIAMRequestPushPermission new];
            _applicationMock = [UIApplication mock];
            [[UIApplication should] receive:@selector(sharedApplication) andReturn:_applicationMock];
        });

        if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
            it(@"should call registration process on application under iOS 10", ^{
                [_applicationMock stub:@selector(isRegisteredForRemoteNotifications) andReturn:theValue(YES)];
                [[_applicationMock should] receive:@selector(registerForRemoteNotifications)];
                [[_applicationMock should] receive:@selector(registerUserNotificationSettings:) withArguments:kw_any()];
                KWCaptureSpy *spy = [_applicationMock captureArgument:@selector(registerUserNotificationSettings:)
                                                              atIndex:0];

                [_command handleMessage:@{@"id": @1}
                            resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                            }];
                UIUserNotificationSettings *notificationSettings = spy.argument;
                UIUserNotificationType type = notificationSettings.types;
                [[theValue(type) should] equal:theValue(UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge)];
            });

            it(@"should receive success in resultBlock", ^{
                [[_applicationMock should] receive:@selector(isRegisteredForRemoteNotifications) andReturn:theValue(YES)];
                [_applicationMock stub:@selector(registerForRemoteNotifications)];
                [_applicationMock stub:@selector(registerUserNotificationSettings:)];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                __block NSDictionary<NSString *, NSObject *> *returnedResult;
                [_command handleMessage:@{@"id": @1}
                            resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                                returnedResult = result;
                                [exp fulfill];
                            }];
                [EMSWaiter waitForExpectations:@[exp] timeout:30];

                [[returnedResult should] equal:@{@"success": @YES, @"id": @1}];
            });
        }

        if (!SYSTEM_VERSION_LESS_THAN(@"10.0")) {
            it(@"should call registration process on application when os version is greater or equal then iOS 10", ^{
                UNUserNotificationCenter *userNotificationCenterMock = [UNUserNotificationCenter mock];
                [[UNUserNotificationCenter should] receive:@selector(currentNotificationCenter) andReturn:userNotificationCenterMock];

                [[_applicationMock should] receive:@selector(registerForRemoteNotifications)];
                [[userNotificationCenterMock should] receive:@selector(requestAuthorizationWithOptions:completionHandler:) withArguments:kw_any(), kw_any()];

                KWCaptureSpy *spy = [userNotificationCenterMock captureArgument:@selector(requestAuthorizationWithOptions:completionHandler:)
                                                                        atIndex:0];
                [_command handleMessage:nil
                            resultBlock:nil];

                [[spy.argument should] equal:theValue(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound)];
            });

            it(@"should receive success in resultBlock", ^{
                UNUserNotificationCenter *userNotificationCenterMock = [UNUserNotificationCenter mock];
                [[UNUserNotificationCenter should] receive:@selector(currentNotificationCenter) andReturn:userNotificationCenterMock];

                [[_applicationMock should] receive:@selector(registerForRemoteNotifications)];
                [[userNotificationCenterMock should] receive:@selector(requestAuthorizationWithOptions:completionHandler:) withArguments:kw_any(), kw_any()];

                KWCaptureSpy *spy = [userNotificationCenterMock captureArgument:@selector(requestAuthorizationWithOptions:completionHandler:)
                                                                        atIndex:1];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                __block NSDictionary<NSString *, NSObject *> *returnedResult;
                [_command handleMessage:@{@"id": @1}
                            resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                                returnedResult = result;
                                [exp fulfill];
                            }];

                void (^handler)(BOOL granted, NSError *__nullable error) = spy.argument;
                handler(YES, nil);

                [EMSWaiter waitForExpectations:@[exp] timeout:30];

                [[returnedResult should] equal:@{@"success": @YES, @"id": @1}];
            });
        }

    });

SPEC_END



