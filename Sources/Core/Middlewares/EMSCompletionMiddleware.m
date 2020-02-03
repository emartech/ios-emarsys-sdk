//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSCompletionMiddleware.h"

@interface EMSCompletionMiddleware ()
@property(nonatomic, strong) NSMutableDictionary *completionBlocks;
@end

@implementation EMSCompletionMiddleware

- (instancetype)initWithSuccessBlock:(CoreSuccessBlock)successBlock
                          errorBlock:(CoreErrorBlock)errorBlock {
    NSParameterAssert(successBlock);
    NSParameterAssert(errorBlock);
    if (self = [super init]) {
        _completionBlocks = [NSMutableDictionary new];
        __weak typeof(self) weakSelf = self;
        _successBlock = ^(NSString *requestId, EMSResponseModel *response) {
            successBlock(requestId, response);

            EMSCompletionBlock completionBlock = weakSelf.completionBlocks[requestId];
            weakSelf.completionBlocks[requestId] = nil;

            if (completionBlock) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionBlock(nil);
                }];
            }
        };

        _errorBlock = ^(NSString *requestId, NSError *error) {
            errorBlock(requestId, error);

            EMSCompletionBlock completionBlock = weakSelf.completionBlocks[requestId];
            weakSelf.completionBlocks[requestId] = nil;

            if (completionBlock) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionBlock(error);
                }];
            }
        };
    }
    return self;
}

- (void)registerCompletionBlock:(EMSCompletionBlock)completionBlock
                forRequestModel:(EMSRequestModel *)requestModel {
    self.completionBlocks[requestModel.requestId] = [completionBlock copy];
}

@end