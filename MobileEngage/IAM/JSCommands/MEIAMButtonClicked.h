//
//  Copyright © 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MEIAMJSCommandProtocol.h"
#import "MEButtonClickRepository.h"
#import "MEInAppTrackingProtocol.h"

@interface MEIAMButtonClicked : NSObject <MEIAMJSCommandProtocol>

@property(nonatomic, readonly) MEInAppMessage *inAppMessage;
@property(nonatomic, readonly) MEButtonClickRepository *repository;
@property(nonatomic, readonly) id<MEInAppTrackingProtocol> inAppTracker;

- (instancetype)initWithInAppMessage:(MEInAppMessage *)inAppMessage
                          repository:(MEButtonClickRepository *)repository
                        inAppTracker:(id <MEInAppTrackingProtocol>)inAppTracker;

@end
