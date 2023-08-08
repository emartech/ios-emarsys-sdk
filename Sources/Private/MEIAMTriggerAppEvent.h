//
//  Copyright © 2017 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MEIAMJSCommandProtocol.h"
#import "EMSBlocks.h"

@interface MEIAMTriggerAppEvent : NSObject <MEIAMJSCommandProtocol>

- (instancetype)initWithEventHandler:(EMSEventHandlerBlock)eventHandler;

@end
