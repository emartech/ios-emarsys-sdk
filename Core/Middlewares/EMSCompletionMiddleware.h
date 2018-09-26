//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSCoreCompletion.h"
#import "EMSBlocks.h"
#import "EMSRequestModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSCompletionMiddleware : NSObject

@property(nonatomic, readonly) CoreSuccessBlock successBlock;
@property(nonatomic, readonly) CoreErrorBlock errorBlock;

- (instancetype)initWithSuccessBlock:(CoreSuccessBlock)successBlock
                          errorBlock:(CoreErrorBlock)errorBlock;

- (void)registerCompletionBlock:(EMSCompletionBlock)completionBlock
                forRequestModel:(EMSRequestModel *)requestModel;

@end

NS_ASSUME_NONNULL_END