//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <UserNotifications/UNUserNotificationCenter.h>
#import "EMSBlocks.h"
#import "EMSNotificationInformationDelegate.h"

@protocol EMSUserNotificationCenterDelegate <UNUserNotificationCenterDelegate>

@property(nonatomic, weak) id <UNUserNotificationCenterDelegate> delegate NS_AVAILABLE_IOS(10.0);
@property(nonatomic, weak) EMSEventHandlerBlock eventHandler;
@property(nonatomic, strong) EMSSilentNotificationInformationBlock notificationInformationDelegate;

@end
