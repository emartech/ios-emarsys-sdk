//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>


@interface FakeNotificationDelegate : NSObject <UNUserNotificationCenterDelegate>

@property(nonatomic, strong) void (^willPresentBlock)(NSOperationQueue *operationQueue);
@property(nonatomic, strong) void (^didReceiveBlock)(NSOperationQueue *operationQueue);

@end