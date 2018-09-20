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

#define DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"MEDB.db"]

@interface EMSDependencyContainer ()

@property(nonatomic, strong) id <EMSRequestModelRepositoryProtocol> requestRepository;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) PRERequestContext *predictRequestContext;
@property(nonatomic, strong) NSArray<EMSAbstractResponseHandler *> *responseHandlers;

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
    _requestContext = [[MERequestContext alloc] initWithConfig:config];

    _iam = [MEInApp new];
    _dbHelper = [[EMSSQLiteHelper alloc] initWithDatabasePath:DB_PATH
                                               schemaDelegate:[EMSSqliteQueueSchemaHandler new]];
    [_dbHelper open];

    MELogRepository *logRepository = [MELogRepository new];
    EMSShardRepository *shardRepository = [[EMSShardRepository alloc] initWithDbHelper:self.dbHelper];
    MERequestModelRepositoryFactory *requestRepositoryFactory = [[MERequestModelRepositoryFactory alloc] initWithInApp:self.iam
                                                                                                        requestContext:self.requestContext];

    const BOOL shouldBatch = [MEExperimental isFeatureEnabled:INAPP_MESSAGING] || [MEExperimental isFeatureEnabled:USER_CENTRIC_INBOX];
    const id <EMSRequestModelRepositoryProtocol> requestRepository = [requestRepositoryFactory createWithBatchCustomEventProcessing:shouldBatch];


    __weak typeof(self) weakSelf = self;
    _requestManager = [EMSRequestManager managerWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
            [weakSelf handleResponse:response];
        }
                                                      errorBlock:^(NSString *requestId, NSError *error) {
                                                      }
                                               requestRepository:requestRepository
                                                 shardRepository:shardRepository
                                                   logRepository:logRepository];

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


}

- (void)initializeInstances {
    _predict = [[PredictInternal alloc] initWithRequestContext:self.predictRequestContext
                                                requestManager:self.requestManager];
    _mobileEngage = [[MobileEngageInternal alloc] initWithRequestManager:self.requestManager
                                                          requestContext:self.requestContext];
}

- (void)handleResponse:(EMSResponseModel *)responseModel {
    for (EMSAbstractResponseHandler *handler in self.responseHandlers) {
        [handler processResponse:responseModel];
    }
}

@end