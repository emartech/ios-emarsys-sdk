//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "FakeRESTClientCompletionProxy.h"

@implementation FakeRESTClientCompletionProxy

- (instancetype)initWithCompletionBlock:(EMSRESTClientCompletionBlock)completionBlock {
    if (self = [super init]) {
        self.completionBlock = completionBlock;
    }
    return self;
}

@end