//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEInAppTrackingProtocol.h"

typedef void (^MECompletionHandler)(void);

@class MEIAMViewController;
@protocol EMSEventHandler;

NS_ASSUME_NONNULL_BEGIN

@protocol MEIAMProtocol <NSObject>

@property(nonatomic, strong, nullable) id <MEInAppTrackingProtocol> inAppTracker;

- (_Nullable id <EMSEventHandler>)eventHandler;

- (MEInAppMessage *)currentInAppMessage;

- (void)closeInAppMessageWithCompletionBlock:(_Nullable MECompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END