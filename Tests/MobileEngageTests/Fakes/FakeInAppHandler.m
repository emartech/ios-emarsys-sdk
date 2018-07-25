//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "FakeInAppHandler.h"

@implementation FakeInAppHandler


- (instancetype)initWithMainThreadCheckerBlock:(MainThreadCheckerBlock)mainThreadCheckerBlock {
    if (self = [super init]) {
        _mainThreadCheckerBlock = mainThreadCheckerBlock;
    }
    return self;
}


- (void)handleEvent:(NSString *)eventName
            payload:(nullable NSDictionary<NSString *, NSObject *> *)payload {
    NSThread *currentThread = [NSThread currentThread];
    if (self.mainThreadCheckerBlock) {
        _mainThreadCheckerBlock([[NSThread mainThread] isEqual:currentThread]);
    }
}

@end