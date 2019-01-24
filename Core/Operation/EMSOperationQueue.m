//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSOperationQueue.h"
#import "EMSMacros.h"
#import "EMSLogCrash.h"

@implementation EMSOperationQueue

- (void)addOperationWithBlock:(void (^)(void))block {
    [super addOperationWithBlock:^{
        @try {
            block();
        } @catch (NSException *exception) {
            EMSLog([[EMSLogCrash alloc] initWithException:exception]);
            @throw exception;
        }
    }];
}


@end