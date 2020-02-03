//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSAgenda.h"

@implementation EMSAgenda

- (instancetype)initWithTag:(NSString *)tag
                      delay:(NSTimeInterval)delay
                   interval:(NSNumber *)interval
              dispatchTimer:(dispatch_source_t)dispatchTimer
               triggerBlock:(EMSTriggerBlock)triggerBlock {
    if (self = [super init]) {
        _tag = tag;
        _delay = delay;
        _interval = interval;
        _dispatchTimer = dispatchTimer;
        _triggerBlock = triggerBlock;
    }
    return self;
}

@end