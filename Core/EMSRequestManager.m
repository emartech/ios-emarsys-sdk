//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSRequestManager.h"
#import "EMSLogger.h"
#import "EMSCoreTopic.h"

typedef void (^RunnerBlock)(void);

@interface EMSRequestManager () <NSURLSessionDelegate>

@property(nonatomic, strong) id <EMSWorkerProtocol> worker;
@property(nonatomic, strong) NSOperationQueue *coreQueue;
@property(nonatomic, strong) EMSCompletionMiddleware *completionMiddleware;
@property(nonatomic, strong) EMSRESTClient *restClient;

- (void)runInCoreQueueWithBlock:(RunnerBlock)runnerBlock;

@end

@implementation EMSRequestManager

#pragma mark - Init

- (instancetype)initWithCoreQueue:(NSOperationQueue *)coreQueue
             completionMiddleware:(EMSCompletionMiddleware *)completionMiddleware
                       restClient:(EMSRESTClient *)restClient
                           worker:(id <EMSWorkerProtocol>)worker
                requestRepository:(id <EMSRequestModelRepositoryProtocol>)requestRepository
                  shardRepository:(id <EMSShardRepositoryProtocol>)shardRepository {
    NSParameterAssert(coreQueue);
    NSParameterAssert(completionMiddleware);
    NSParameterAssert(restClient);
    NSParameterAssert(worker);
    NSParameterAssert(requestRepository);
    NSParameterAssert(shardRepository);
    if (self = [super init]) {
        _coreQueue = coreQueue;
        _completionMiddleware = completionMiddleware;
        _restClient = restClient;
        _worker = worker;
        _requestModelRepository = requestRepository;
        _shardRepository = shardRepository;
    }
    return self;
}

#pragma mark - Public methods

- (void)submitRequestModel:(EMSRequestModel *)model
       withCompletionBlock:(EMSCompletionBlock)completionBlock {
    NSParameterAssert(model);
    [self.completionMiddleware registerCompletionBlock:completionBlock
                                       forRequestModel:model];
    [EMSLogger logWithTopic:EMSCoreTopic.networkingTopic
                    message:[NSString stringWithFormat:@"Argument: %@", model]];

    __weak typeof(self) weakSelf = self;
    [self runInCoreQueueWithBlock:^{
        EMSRequestModel *requestModel = model;
        if (weakSelf.additionalHeaders) {
            NSMutableDictionary *headers;
            if (model.headers) {
                headers = [NSMutableDictionary dictionaryWithDictionary:model.headers];
                [headers addEntriesFromDictionary:weakSelf.additionalHeaders];
            } else {
                headers = [NSMutableDictionary dictionaryWithDictionary:weakSelf.additionalHeaders];
            }
            requestModel = [[EMSRequestModel alloc] initWithRequestId:model.requestId
                                                            timestamp:model.timestamp
                                                               expiry:model.ttl
                                                                  url:model.url
                                                               method:model.method
                                                              payload:model.payload
                                                              headers:[NSDictionary dictionaryWithDictionary:headers]
                                                               extras:[NSDictionary dictionaryWithDictionary:model.extras]];
        }
        [weakSelf.requestModelRepository add:requestModel];
        [weakSelf.worker run];
    }];
}

- (void)submitShard:(EMSShard *)shard {
    NSParameterAssert(shard);
    [EMSLogger logWithTopic:EMSCoreTopic.networkingTopic
                    message:[NSString stringWithFormat:@"Argument: %@", shard]];

    [self runInCoreQueueWithBlock:^{
        [[self shardRepository] add:shard];
    }];
}

- (void)submitRequestModelNow:(EMSRequestModel *)model
                 successBlock:(CoreSuccessBlock)successBlock
                   errorBlock:(CoreErrorBlock)errorBlock {
    NSParameterAssert(model);
    NSParameterAssert(successBlock);
    NSParameterAssert(errorBlock);
    [self.restClient executeTaskWithRequestModel:model
                                    successBlock:successBlock
                                      errorBlock:errorBlock];
}

- (void)setAdditionalHeaders:(NSDictionary<NSString *, NSString *> *)additionalHeaders {
    [EMSLogger logWithTopic:EMSCoreTopic.networkingTopic
                    message:[NSString stringWithFormat:@"Argument: %@", additionalHeaders]];
    _additionalHeaders = additionalHeaders;
}


#pragma mark - Private methods

- (void)runInCoreQueueWithBlock:(RunnerBlock)runnerBlock {
    [self.coreQueue addOperationWithBlock:runnerBlock];
}

@end
