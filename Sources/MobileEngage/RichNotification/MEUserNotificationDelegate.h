//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "EMSUserNotificationCenterDelegate.h"

@class EMSTimestampProvider;
@class EMSUUIDProvider;
@class EMSRequestManager;
@class EMSRequestFactory;
@class MEInApp;
@protocol EMSPushNotificationProtocol;
@class EMSActionFactory;

@interface MEUserNotificationDelegate : NSObject <EMSUserNotificationCenterDelegate>

@property(nonatomic, strong) EMSSilentNotificationInformationBlock notificationInformationDelegate;

- (instancetype)initWithActionFactory:(EMSActionFactory *)actionFactory
                                inApp:(MEInApp *)inApp
                    timestampProvider:(EMSTimestampProvider *)timestampProvider
                         uuidProvider:(EMSUUIDProvider *)uuidProvider
                         pushInternal:(id <EMSPushNotificationProtocol>)pushInternal
                       requestManager:(EMSRequestManager *)requestManager
                       requestFactory:(EMSRequestFactory *)requestFactory
                       operationQueue:(NSOperationQueue *)operationQueue;

@end
