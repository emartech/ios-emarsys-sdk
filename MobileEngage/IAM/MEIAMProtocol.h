//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEInAppTrackingProtocol.h"

typedef void (^MECompletionHandler)(void);

@class MEIAMViewController;
@protocol EMSEventHandler;

@protocol MEIAMProtocol <NSObject>

- (id <EMSEventHandler>)eventHandler;
- (id <MEInAppTrackingProtocol>)inAppTracker;
- (NSString *)currentCampaignId;
- (void)closeInAppMessageWithCompletionBlock:(MECompletionHandler)completionHandler;

@end