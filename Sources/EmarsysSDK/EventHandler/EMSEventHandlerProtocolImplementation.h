//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSEventHandler.h"
#import "EMSBlocks.h"

@interface EMSEventHandlerProtocolImplementation: NSObject <EMSEventHandler>

@property(nonatomic, strong) EMSEventHandlerBlock handlerBlock;

@end