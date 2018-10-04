//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSDependencyContainer.h"
#import "MobileEngageInternal.h"
#import "MEExperimental.h"
#import "MERequestContext.h"
#import "MEInApp.h"
#import "MELogRepository.h"
#import "EMSShardRepository.h"
#import "EMSSQLiteHelper.h"
#import "MERequestModelRepositoryFactory.h"
#import "EMSSqliteQueueSchemaHandler.h"
#import "PredictInternal.h"
#import "EMSPredictAggregateShardsTrigger.h"
#import "PRERequestContext.h"
#import "EMSUUIDProvider.h"
#import "EMSSchemaContract.h"
#import "EMSPredictMapper.h"
#import "EMSAbstractResponseHandler.h"
#import "EMSVisitorIdResponseHandler.h"
#import "MEInboxV2.h"
#import "MEInbox.h"
#import "MENotificationCenterManager.h"
#import "EMSDefaultWorker.h"

#define DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"MEDB.db"]

@interface EMSDependencyContainer ()

@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) PRERequestContext *predictRequestContext;
@property(nonatomic, strong) NSArray<EMSAbstractResponseHandler *> *responseHandlers;
@property(nonatomic, strong) EMSRESTClient *restClient;
@property(nonatomic, strong) MENotificationCenterManager *notificationCenterManager;
@property(nonatomic, strong) NSOperationQueue *operationQueue;

- (void)initializeDependenciesWithConfig:(EMSConfig *)config;

- (void)initializeInstances;

- (void)handleResponse:(EMSResponseModel *)responseModel;

@end

@implementation EMSDependencyContainer

- (instancetype)initWithConfig:(EMSConfig *)config {
    if (self = [super init]) {
        [self initializeDependenciesWithConfig:config];
        [self initializeInstances];
    }
    return self;
}

- (void)initializeDependenciesWithConfig:(EMSConfig *)config {
    [MEExperimental enableFeatures:config.experimentalFeatures];
    _requestContext = [[MERequestContext alloc] initWithConfig:config];
    _notificationCenterManager = [MENotificationCenterManager new];

    _iam = [MEInApp new];
    _dbHelper = [[EMSSQLiteHelper alloc] initWithDatabasePath:DB_PATH
                                               schemaDelegate:[EMSSqliteQueueSchemaHandler new]];
    [_dbHelper open];

    MELogRepository *logRepository = [MELogRepository new];
    EMSShardRepository *shardRepository = [[EMSShardRepository alloc] initWithDbHelper:self.dbHelper];
    MERequestModelRepositoryFactory *requestRepositoryFactory = [[MERequestModelRepositoryFactory alloc] initWithInApp:self.iam
                                                                                                        requestContext:self.requestContext];

    const BOOL shouldBatch = [MEExperimental isFeatureEnabled:INAPP_MESSAGING] || [MEExperimental isFeatureEnabled:USER_CENTRIC_INBOX];
    _requestRepository = [requestRepositoryFactory createWithBatchCustomEventProcessing:shouldBatch];

    _operationQueue = [NSOperationQueue new];
    _operationQueue.maxConcurrentOperationCount = 1;
    _operationQueue.qualityOfService = NSQualityOfServiceUtility;

    __weak typeof(self) weakSelf = self;
    EMSCompletionMiddleware *middleware = [[EMSCompletionMiddleware alloc] initWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
            [weakSelf handleResponse:response];
        }
                                                                                     errorBlock:^(NSString *requestId, NSError *error) {
                                                                                     }];
    EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:self.operationQueue
                                                              requestRepository:self.requestRepository
                                                                  logRepository:logRepository
                                                                   successBlock:middleware.successBlock
                                                                     errorBlock:middleware.errorBlock];
    _requestManager = [[EMSRequestManager alloc] initWithCoreQueue:self.operationQueue
                                              completionMiddleware:middleware
                                                            worker:worker
                                                 requestRepository:self.requestRepository
                                                   shardRepository:shardRepository];

    _predictRequestContext = [[PRERequestContext alloc] initWithTimestampProvider:[EMSTimestampProvider new]
                                                                     uuidProvider:[EMSUUIDProvider new]
                                                                       merchantId:config.merchantId];
    _responseHandlers = @[[[EMSVisitorIdResponseHandler alloc] initWithRequestContext:self.predictRequestContext]];
    EMSPredictAggregateShardsTrigger *trigger = [EMSPredictAggregateShardsTrigger new];

    [_dbHelper registerTriggerWithTableName:SHARD_TABLE_NAME
                                triggerType:EMSDBTriggerType.afterType
                               triggerEvent:EMSDBTriggerEvent.insertEvent
                               triggerBlock:[trigger createTriggerBlockWithRequestManager:self.requestManager
                                                                                   mapper:[[EMSPredictMapper alloc] initWithRequestContext:self.predictRequestContext]
                                                                               repository:shardRepository]];
    _restClient = [EMSRESTClient clientWithSession:[NSURLSession sharedSession]];
    _notificationCache = [[EMSNotificationCache alloc] init];
    if ([MEExperimental isFeatureEnabled:USER_CENTRIC_INBOX]) {
        _inbox = [[MEInboxV2 alloc] initWithConfig:config
                                    requestContext:self.requestContext
                                 notificationCache:self.notificationCache
                                        restClient:self.restClient
                                 timestampProvider:[EMSTimestampProvider new]
                                    requestManager:self.requestManager];
    } else {
        _inbox = [[MEInbox alloc] initWithConfig:config
                                  requestContext:self.requestContext
                                      restClient:self.restClient
                                  requestManager:self.requestManager];
    }
}

- (void)initializeInstances {
    _predict = [[PredictInternal alloc] initWithRequestContext:self.predictRequestContext
                                                requestManager:self.requestManager];
    _mobileEngage = [[MobileEngageInternal alloc] initWithRequestManager:self.requestManager
                                                          requestContext:self.requestContext
                                               notificationCenterManager:self.notificationCenterManager];
}

- (void)handleResponse:(EMSResponseModel *)responseModel {
    for (EMSAbstractResponseHandler *handler in self.responseHandlers) {
        [handler processResponse:responseModel];
    }
}

@end