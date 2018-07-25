//
//  Copyright © 2017 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MEIAMJSCommandProtocol.h"

@protocol MEEventHandler;

@interface MEIAMTriggerAppEvent : NSObject <MEIAMJSCommandProtocol>

- (instancetype)initWithInAppMessageHandler:(id<MEEventHandler>)inAppMessageHandler;

@end
