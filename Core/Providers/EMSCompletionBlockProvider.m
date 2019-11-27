//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSCompletionBlockProvider.h"

@interface EMSCompletionBlockProvider ()

@property(nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation EMSCompletionBlockProvider

- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue {
    NSParameterAssert(operationQueue);

    if (self = [super init]) {
        _operationQueue = operationQueue;
    }
    return self;
}

- (EMSCompletion)provideCompletion:(EMSCompletion)completionBlock {
    __weak typeof(self) weakSelf = self;
    return ^{
        [weakSelf.operationQueue addOperationWithBlock:completionBlock];
    };
}

@end