//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

@protocol EMSOnEventActionProtocol <NSObject>

@property(nonatomic, weak, nullable) EMSEventHandlerBlock eventHandler;

@end
