////
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSCompletionBlockProvider: NSObject

- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue;

- (EMSCompletionBlock)provideCompletionBlock:(EMSCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
