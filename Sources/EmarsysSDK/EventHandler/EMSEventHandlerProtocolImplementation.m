//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSEventHandlerProtocolImplementation.h"

@implementation EMSEventHandlerProtocolImplementation

- (void)handleEvent:(NSString *)eventName
            payload:(NSDictionary<NSString *, NSObject *> *)payload {
    if (self.handlerBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.handlerBlock(eventName, payload);
        });
    }
}

@end