//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "EMSDependencyContainer.h"
#import "MobileEngageInternal.h"
#import "MEExperimental.h"
#import "MERequestContext.h"
#import "MEInApp.h"
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
#import "MEIdResponseHandler.h"
#import "MEIAMResponseHandler.h"
#import "MEIAMCleanupResponseHandler.h"
#import "MESchemaDelegate.h"
#import "MEDefaultHeaders.h"
#import "AppStartBlockProvider.h"
#import "EMSWindowProvider.h"
#import "EMSMainWindowProvider.h"
#import "EMSViewControllerProvider.h"

#define DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"MEDB.db"]

@interface EMSDependencyContainer ()

@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) PRERequestContext *predictRequestContext;
@property(nonatomic, strong) EMSRESTClient *restClient;
@property(nonatomic, strong) MENotificationCenterManager *notificationCenterManager;
@property(nonatomic, strong) EMSSQLiteHelper *dbHelper;
@property(nonatomic, strong) MobileEngageInternal *mobileEngage;
@property(nonatomic, strong) id <EMSInboxProtocol> inbox;
@property(nonatomic, strong) MEInApp *iam;
@property(nonatomic, strong) PredictInternal *predict;
@property(nonatomic, strong) id <EMSRequestModelRepositoryProtocol> requestRepository;
@property(nonatomic, strong) EMSNotificationCache *notificationCache;
@property(nonatomic, strong) NSArray<EMSAbstractResponseHandler *> *responseHandlers;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) NSOperationQueue *operationQueue;
@property(nonatomic, strong) AppStartBlockProvider *appStartBlockProvider;

- (void)initializeDependenciesWithConfig:(EMSConfig *)config;

- (void)initializeInstances;

- (void)handleResponse:(EMSResponseModel *)responseModel;

@end

@implementation EMSDependencyContainer

- (instancetype)initWithConfig:(EMSConfig *)config {
    if (self = [super init]) {
        [self initializeDependenciesWithConfig:config];
    }
    return self;
}

- (void)initializeDependenciesWithConfig:(EMSConfig *)config {
    EMSTimestampProvider *timestampProvider = [EMSTimestampProvider new];
    _requestContext = [[MERequestContext alloc] initWithConfig:config];
    _notificationCenterManager = [MENotificationCenterManager new];
    MELogRepository *logRepository = [MELogRepository new];
    EMSSQLiteHelper *meDbHelper = [[EMSSQLiteHelper alloc] initWithDatabasePath:DB_PATH
                                                                 schemaDelegate:[MESchemaDelegate new]];
    MEDisplayedIAMRepository *displayedIAMRepository = [[MEDisplayedIAMRepository alloc] initWithDbHelper:meDbHelper];
    MEButtonClickRepository *buttonClickRepository = [[MEButtonClickRepository alloc] initWithDbHelper:meDbHelper];
    _iam = [[MEInApp alloc] initWithWindowProvider:[[EMSWindowProvider alloc] initWithViewControllerProvider:[EMSViewControllerProvider new]]
                                mainWindowProvider:[[EMSMainWindowProvider alloc] initWithApplication:[UIApplication sharedApplication]]
                                 timestampProvider:timestampProvider
                                     logRepository:logRepository
                            displayedIamRepository:displayedIAMRepository
                             buttonClickRepository:buttonClickRepository];
    _dbHelper = [[EMSSQLiteHelper alloc] initWithDatabasePath:DB_PATH
                                               schemaDelegate:[EMSSqliteQueueSchemaHandler new]];
    [_dbHelper open];

    EMSShardRepository *shardRepository = [[EMSShardRepository alloc] initWithDbHelper:self.dbHelper];
    MERequestModelRepositoryFactory *requestRepositoryFactory = [[MERequestModelRepositoryFactory alloc] initWithInApp:self.iam
                                                                                                        requestContext:self.requestContext
                                                                                                 buttonClickRepository:buttonClickRepository
                                                                                                displayedIAMRepository:displayedIAMRepository];

    const BOOL shouldBatch = [MEExperimental isFeatureEnabled:INAPP_MESSAGING] || [MEExperimental isFeatureEnabled:USER_CENTRIC_INBOX];
    _requestRepository = [requestRepositoryFactory createWithBatchCustomEventProcessing:shouldBatch];

    _operationQueue = [NSOperationQueue new];
    _operationQueue.maxConcurrentOperationCount = 1;
    _operationQueue.qualityOfService = NSQualityOfServiceUtility;
    _operationQueue.name = [NSString stringWithFormat:@"core_sdk_queue_%@", [[NSUUID UUID] UUIDString]];

    EMSCompletionMiddleware *middleware = [self createMiddleware];


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
    [self.requestManager setAdditionalHeaders:[MEDefaultHeaders additionalHeadersWithConfig:self.requestContext.config]];

    _predictRequestContext = [[PRERequestContext alloc] initWithTimestampProvider:timestampProvider
                                                                     uuidProvider:[EMSUUIDProvider new]
                                                                       merchantId:config.merchantId];
    NSMutableArray<EMSAbstractResponseHandler *> *responseHandlers = [NSMutableArray array];
    if ([MEExperimental isFeatureEnabled:INAPP_MESSAGING] || [MEExperimental isFeatureEnabled:USER_CENTRIC_INBOX]) {
        [responseHandlers addObject:[[MEIdResponseHandler alloc] initWithRequestContext:self.requestContext]];
    }
    if ([MEExperimental isFeatureEnabled:INAPP_MESSAGING]) {
        [meDbHelper open];
        [responseHandlers addObjectsFromArray:@[
            [[MEIAMResponseHandler alloc] initWithInApp:self.iam],
            [[MEIAMCleanupResponseHandler alloc] initWithButtonClickRepository:buttonClickRepository
                                                          displayIamRepository:displayedIAMRepository]]
        ];
    }
    [responseHandlers addObject:[[EMSVisitorIdResponseHandler alloc] initWithRequestContext:self.predictRequestContext]];
    _responseHandlers = [NSArray arrayWithArray:responseHandlers];
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
                                 timestampProvider:timestampProvider
                                    requestManager:self.requestManager];
    } else {
        _inbox = [[MEInbox alloc] initWithConfig:config
                                  requestContext:self.requestContext
                               notificationCache:self.notificationCache
                                      restClient:self.restClient
                                  requestManager:self.requestManager];
    }

    _appStartBlockProvider = [AppStartBlockProvider new];


    _predict = [[PredictInternal alloc] initWithRequestContext:self.predictRequestContext
                                                requestManager:self.requestManager];
    _mobileEngage = [[MobileEngageInternal alloc] initWithRequestManager:self.requestManager
                                                          requestContext:self.requestContext
                                                       notificationCache:self.notificationCache];
    [self.iam setInAppTracker:self.mobileEngage];
}

- (EMSCompletionMiddleware *)createMiddleware {
    return [[EMSCompletionMiddleware alloc] initWithSuccessBlock:[self createSuccessBlock]
                                                      errorBlock:[self createErrorBlock]];
}

- (void (^)(NSString *, EMSResponseModel *))createSuccessBlock {
    __weak typeof(self) weakSelf = self;
    return ^(NSString *requestId, EMSResponseModel *response) {
        [weakSelf handleResponse:response];
    };
}

- (void (^)(NSString *, NSError *))createErrorBlock {
    return ^(NSString *requestId, NSError *error) {
    };
}

- (void)handleResponse:(EMSResponseModel *)responseModel {
    for (EMSAbstractResponseHandler *handler in self.responseHandlers) {
        [handler processResponse:responseModel];
    }
}

@end
