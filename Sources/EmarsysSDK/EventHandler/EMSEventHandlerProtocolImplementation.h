//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

@interface EMSEventHandlerProtocolImplementation: NSObject

@property(nonatomic, strong) EMSEventHandlerBlock handlerBlock;

- (void)handleEvent:(NSString *)eventName
            payload:(NSDictionary<NSString *, NSObject *> *)payload;
@end