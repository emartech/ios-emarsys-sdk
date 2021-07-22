//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

@protocol EMSIAMAppEventProtocol <NSObject>
- (_Nullable EMSEventHandlerBlock)eventHandler;
@end