//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSCoreCompletion.h"
#import "EMSRequestModelRepositoryProtocol.h"
#import "EMSShardRepositoryProtocol.h"
#import "EMSBlocks.h"
#import "EMSCompletionMiddleware.h"
#import "EMSWorkerProtocol.h"
#import "EMSRESTClient.h"

@class EMSRequestModel;
@class EMSRESTClientCompletionProxyFactory;

NS_ASSUME_NONNULL_BEGIN

@interface EMSRequestManager : NSObject

@property(nonatomic, readonly) id <EMSRequestModelRepositoryProtocol> requestModelRepository;
@property(nonatomic, readonly) id <EMSShardRepositoryProtocol> shardRepository;

- (instancetype)initWithCoreQueue:(NSOperationQueue *)coreQueue
             completionMiddleware:(EMSCompletionMiddleware *)completionMiddleware
                       restClient:(EMSRESTClient *)restClient
                           worker:(id <EMSWorkerProtocol>)worker
                requestRepository:(id <EMSRequestModelRepositoryProtocol>)requestRepository
                  shardRepository:(id <EMSShardRepositoryProtocol>)shardRepository
                     proxyFactory:(EMSRESTClientCompletionProxyFactory *)proxyFactory;

- (void)submitRequestModel:(EMSRequestModel *)model
       withCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock;

- (void)submitRequestModelNow:(EMSRequestModel *)model;

- (void)submitRequestModelNow:(EMSRequestModel *)model
                 successBlock:(CoreSuccessBlock)successBlock
                   errorBlock:(CoreErrorBlock)errorBlock;

- (void)submitShard:(EMSShard *)shard;

@end

NS_ASSUME_NONNULL_END
