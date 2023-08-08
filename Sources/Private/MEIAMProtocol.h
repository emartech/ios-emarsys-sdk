//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEInAppTrackingProtocol.h"
#import "EMSIAMCloseProtocol.h"
#import "EMSIAMAppEventProtocol.h"

@class MEIAMViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol MEIAMProtocol <NSObject, EMSIAMCloseProtocol, EMSIAMAppEventProtocol>

@property(nonatomic, strong, nullable) id <MEInAppTrackingProtocol> inAppTracker;

- (MEInAppMessage *)currentInAppMessage;

@end

NS_ASSUME_NONNULL_END