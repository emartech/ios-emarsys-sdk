////
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

#import "EMSCompletionBlockProvider.h"
#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

@interface EMSCompletionBlockProvider()

@property(nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation EMSCompletionBlockProvider

- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue {
    if (self = [super init]) {
        _operationQueue = operationQueue;
    }
    return self;
}

- (EMSCompletionBlock)provideCompletionBlock:(EMSCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    return ^(NSError * _Nullable error) {
        [weakSelf.operationQueue addOperationWithBlock:^{
            completionBlock(error);
        }];
    };
}

@end
