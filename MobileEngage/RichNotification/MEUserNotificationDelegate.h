//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "EMSUserNotificationCenterDelegate.h"

@class MobileEngageInternal;
@class EMSTimestampProvider;
@class EMSUUIDProvider;
@class EMSRequestManager;
@class EMSRequestFactory;
@class MEInApp;
@protocol EMSPushNotificationProtocol;
@protocol EMSMobileEngageProtocol;

@interface MEUserNotificationDelegate : NSObject <EMSUserNotificationCenterDelegate>

- (instancetype)initWithApplication:(UIApplication *)application
               mobileEngageInternal:(id <EMSMobileEngageProtocol>)mobileEngage
                              inApp:(MEInApp *)inApp
                  timestampProvider:(EMSTimestampProvider *)timestampProvider
                       uuidProvider:(EMSUUIDProvider *)uuidProvider
                       pushInternal:(id <EMSPushNotificationProtocol>)pushInternal
                     requestManager:(EMSRequestManager *)requestManager
                     requestFactory:(EMSRequestFactory *)requestFactory;

@end
