//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEInApp.h"
#import "MobileEngage.h"
#import <UIKit/UIKit.h>
#import "MEInAppMessage.h"
#import "MEInAppTrackingProtocol.h"
#import "MELogRepository.h"
#import "MEIAMProtocol.h"

typedef void (^MECompletionHandler)(void);

@interface MEInApp (Private) <MEIAMProtocol>

@property(nonatomic, weak, nullable) id <MEInAppTrackingProtocol> inAppTracker;
@property(nonatomic, strong) MELogRepository *logRepository;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;

- (UIWindow *)iamWindow;

- (void)setIamWindow:(UIWindow *)window;

- (void)showMessage:(MEInAppMessage *)message
  completionHandler:(MECompletionHandler)completionHandler;

@end
