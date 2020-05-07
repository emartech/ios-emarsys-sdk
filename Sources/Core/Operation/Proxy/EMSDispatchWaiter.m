//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSDispatchWaiter.h"

@interface EMSDispatchWaiter()

@property(nonatomic, strong) dispatch_group_t dispatchGroup;

@end

@implementation EMSDispatchWaiter

- (instancetype)init {
    if (self = [super init]) {
        _dispatchGroup = dispatch_group_create();
    }
    return self;
}

- (void)enter {
    dispatch_group_enter(self.dispatchGroup);
}

- (void)exit {
    dispatch_group_leave(self.dispatchGroup);
}

- (void)waitWithInterval:(int)interval {
    dispatch_time_t dispatchTime = interval == 0 ? DISPATCH_TIME_FOREVER : dispatch_time(DISPATCH_TIME_NOW, (interval * NSEC_PER_SEC));
    dispatch_group_wait(self.dispatchGroup, dispatchTime);
}

@end