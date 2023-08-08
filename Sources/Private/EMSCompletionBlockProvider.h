//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

@interface EMSCompletionBlockProvider : NSObject

- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue;

- (EMSCompletion)provideCompletion:(EMSCompletion)completionBlock;

@end