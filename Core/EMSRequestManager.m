//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSRequestManager.h"
#import "EMSResponseModel.h"
#import "EMSWorkerProtocol.h"
#import "EMSDefaultWorker.h"
#import "EMSLogger.h"
#import "EMSCoreTopic.h"

typedef void (^RunnerBlock)(void);

@interface EMSRequestManager () <NSURLSessionDelegate>

@property(nonatomic, strong) id <EMSWorkerProtocol> worker;
@property(nonatomic, strong) NSOperationQueue *coreQueue;

- (void)runInCoreQueueWithBlock:(RunnerBlock)runnerBlock;

@end

@implementation EMSRequestManager

#pragma mark - Init

+ (instancetype)managerWithSuccessBlock:(nullable CoreSuccessBlock)successBlock
                             errorBlock:(nullable CoreErrorBlock)errorBlock
                      requestRepository:(id <EMSRequestModelRepositoryProtocol>)requestRepository
                        shardRepository:(id <EMSShardRepositoryProtocol>)shardRepository
                          logRepository:(id <EMSLogRepositoryProtocol>)logRepository {
    return [[EMSRequestManager alloc] initWithSuccessBlock:successBlock
                                                errorBlock:errorBlock
                                         requestRepository:requestRepository
                                           shardRepository:shardRepository
                                             logRepository:logRepository];
}

- (instancetype)initWithSuccessBlock:(nullable CoreSuccessBlock)successBlock
                          errorBlock:(nullable CoreErrorBlock)errorBlock
                   requestRepository:(id <EMSRequestModelRepositoryProtocol>)requestRepository
                     shardRepository:(id <EMSShardRepositoryProtocol>)shardRepository
                       logRepository:(id <EMSLogRepositoryProtocol>)logRepository {
    if (self = [super init]) {
        _coreQueue = [NSOperationQueue new];
        _coreQueue.maxConcurrentOperationCount = 1;
        _coreQueue.qualityOfService = NSQualityOfServiceUtility;
        _worker = [[EMSDefaultWorker alloc] initWithOperationQueue:_coreQueue
                                                 requestRepository:requestRepository
                                                     logRepository:logRepository
                                                      successBlock:successBlock
                                                        errorBlock:errorBlock];
        _requestModelRepository = requestRepository;
        _shardRepository = shardRepository;
    }
    return self;
}

- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue
                                worker:(id <EMSWorkerProtocol>)worker
                     requestRepository:(id <EMSRequestModelRepositoryProtocol>)repository {
    if (self = [super init]) {
        _coreQueue = operationQueue;
        _requestModelRepository = repository;
        _worker = worker;
    }
    return self;
}

#pragma mark - Public methods

- (void)submitRequestModel:(EMSRequestModel *)model {
    NSParameterAssert(model);
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

- (void)submitShardModel:(EMSShard *)shardModel {
    NSParameterAssert(shardModel);
    [EMSLogger logWithTopic:EMSCoreTopic.networkingTopic
                    message:[NSString stringWithFormat:@"Argument: %@", shardModel]];

    [self runInCoreQueueWithBlock:^{
        [[self shardRepository] add:shardModel];
    }];
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
