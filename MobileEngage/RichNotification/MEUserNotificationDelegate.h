//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "EMSUserNotificationCenterDelegate.h"
#import "MEIAMProtocol.h"

@class MobileEngageInternal;
@class EMSTimestampProvider;
@class EMSRequestManager;
@class EMSRequestFactory;
@protocol EMSPushNotificationProtocol;

@interface MEUserNotificationDelegate : NSObject <EMSUserNotificationCenterDelegate>

- (instancetype)initWithApplication:(UIApplication *)application
               mobileEngageInternal:(MobileEngageInternal *)mobileEngage
                              inApp:(id <MEIAMProtocol>)inApp
                  timestampProvider:(EMSTimestampProvider *)timestampProvider
                       pushInternal:(id <EMSPushNotificationProtocol>)pushInternal
                     requestManager:(EMSRequestManager *)requestManager
                     requestFactory:(EMSRequestFactory *)requestFactory;

@end
