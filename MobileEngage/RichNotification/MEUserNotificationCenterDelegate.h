//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <UserNotifications/UNUserNotificationCenter.h>
#import "MEEventHandler.h"

@protocol MEUserNotificationCenterDelegate <UNUserNotificationCenterDelegate>

@property(nonatomic, weak) id <UNUserNotificationCenterDelegate> delegate NS_AVAILABLE_IOS(10.0);
@property(nonatomic, weak) id <MEEventHandler> eventHandler;

@end