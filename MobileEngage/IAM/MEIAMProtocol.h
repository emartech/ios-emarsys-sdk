//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEInAppTrackingProtocol.h"

typedef void (^MECompletionHandler)(void);

@class MEIAMViewController;
@protocol MEEventHandler;

@protocol MEIAMProtocol <NSObject>

- (id <MEEventHandler>)eventHandler;
- (id <MEInAppTrackingProtocol>)inAppTracker;
- (NSString *)currentCampaignId;
- (void)closeInAppMessageWithCompletionBlock:(MECompletionHandler)completionHandler;

@end