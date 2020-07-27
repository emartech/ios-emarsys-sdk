//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <UserNotifications/UNUserNotificationCenter.h>
#import "EMSEventHandler.h"
#import "EMSNotificationInformationDelegate.h"

@protocol EMSUserNotificationCenterDelegate <UNUserNotificationCenterDelegate>

@property(nonatomic, weak) id <UNUserNotificationCenterDelegate> delegate NS_AVAILABLE_IOS(10.0);
@property(nonatomic, weak) id <EMSEventHandler> eventHandler;
@property(nonatomic, weak) id <EMSNotificationInformationDelegate> notificationInformationDelegate;

@end
