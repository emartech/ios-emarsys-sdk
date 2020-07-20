//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSIAMAppEventProtocol.h"
#import "EMSEventHandlerProtocolImplementation.h"

@interface EMSEventHandlerProtocolBlockConverter: NSObject <EMSIAMAppEventProtocol>

@property(nonatomic, strong) EMSEventHandlerProtocolImplementation *eventHandler;

@end
