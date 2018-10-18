//
//  Copyright © 2017 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MEIAMJSCommandProtocol.h"

@protocol EMSEventHandler;

@interface MEIAMTriggerAppEvent : NSObject <MEIAMJSCommandProtocol>

- (instancetype)initWithInAppMessageHandler:(id <EMSEventHandler>)inAppMessageHandler;

@end
