//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "MENotificationCenterManager.h"


@implementation MENotificationCenterManager

- (void)addHandlerBlock:(MEHandlerBlock)handlerBlock forNotification:(NSString *)notificationName {
    [[NSNotificationCenter defaultCenter] addObserverForName:notificationName object:nil queue:nil usingBlock:^(NSNotification *note) {
        if (handlerBlock) {
            handlerBlock();
        }
    }];
}

@end