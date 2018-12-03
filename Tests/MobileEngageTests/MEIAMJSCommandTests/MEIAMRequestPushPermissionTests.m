#import <UserNotifications/UserNotifications.h>
#import "Kiwi.h"
#import "MEIAMRequestPushPermission.h"
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

        });


SPEC_END



