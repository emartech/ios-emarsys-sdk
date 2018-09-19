//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "Emarsys.h"
#import "PredictInternal.h"
#import "MobileEngageInternal.h"
#import "MERequestModelRepositoryFactory.h"
#import "MERequestContext.h"
#import "MEInApp.h"
#import "MELogRepository.h"
#import "EMSShardRepository.h"
#import "MESchemaDelegate.h"
#import "MEExperimental.h"
#import "EMSSchemaContract.h"
#import "EMSPredictAggregateShardsTrigger.h"
#import "EMSPredictMapper.h"
#import "PRERequestContext.h"
#import "EMSUUIDProvider.h"
#import "EMSSqliteQueueSchemaHandler.h"

@implementation Emarsys

static PredictInternal *_predict;
static MobileEngageInternal *_mobileEngage;
static EMSSQLiteHelper *_dbHelper;
static EMSConfig *_config;
#define DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"MEDB.db"]

+ (void)setupWithConfig:(EMSConfig *)config {
    NSParameterAssert(config);


    _mobileEngage = [MobileEngageInternal new];
    _config = config;

    _dbHelper = [[EMSSQLiteHelper alloc] initWithDatabasePath:DB_PATH
                                               schemaDelegate:[EMSSqliteQueueSchemaHandler new]];
    [_dbHelper open];

    MERequestContext *requestContext = [[MERequestContext alloc] initWithConfig:config];

    MEInApp *_iam = [MEInApp new];
    MERequestModelRepositoryFactory *requestRepositoryFactory = [[MERequestModelRepositoryFactory alloc] initWithInApp:_iam
                                                                                                        requestContext:requestContext];

    const BOOL shouldBatch = [MEExperimental isFeatureEnabled:INAPP_MESSAGING] || [MEExperimental isFeatureEnabled:USER_CENTRIC_INBOX];
    const id <EMSRequestModelRepositoryProtocol> requestRepository = [requestRepositoryFactory createWithBatchCustomEventProcessing:shouldBatch];
    MELogRepository *logRepository = [MELogRepository new];
    EMSShardRepository *shardRepository = [[EMSShardRepository alloc] initWithDbHelper:_dbHelper];


    EMSPredictAggregateShardsTrigger *trigger = [EMSPredictAggregateShardsTrigger new];

    EMSRequestManager *manager = [EMSRequestManager managerWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
        }
                                                                 errorBlock:^(NSString *requestId, NSError *error) {
                                                                 }
                                                          requestRepository:requestRepository
                                                            shardRepository:shardRepository
                                                              logRepository:logRepository];

    PRERequestContext *predictRequestContext = [[PRERequestContext alloc] initWithTimestampProvider:[EMSTimestampProvider new]
                                                                                       uuidProvider:[EMSUUIDProvider new]
                                                                                         merchantId:config.merchantId];
    _predict = [[PredictInternal alloc] initWithRequestContext:predictRequestContext
                                                requestManager:manager];
    [_dbHelper registerTriggerWithTableName:SHARD_TABLE_NAME
                                triggerType:EMSDBTriggerType.afterType
                               triggerEvent:EMSDBTriggerEvent.insertEvent
                               triggerBlock:[trigger createTriggerBlockWithRequestManager:manager
                                                                                   mapper:[[EMSPredictMapper alloc] initWithRequestContext:predictRequestContext]
                                                                               repository:shardRepository]];
    [_mobileEngage setupWithRequestManager:manager
                            requestContext:requestContext];
}


+ (void)setCustomerWithId:(NSString *)customerId
          completionBlock:(EMSCompletionBlock)completionBlock {

}

+ (void)setCustomerWithId:(NSString *)customerId {
    NSParameterAssert(customerId);
    [_predict setCustomerWithId:customerId];
    [_mobileEngage appLoginWithContactFieldId:_config.contactFieldId
                            contactFieldValue:customerId];
}

+ (void)setPredict:(PredictInternal *)predictInternal {
    _predict = predictInternal;
}

+ (id <EMSPredictProtocol>)predict {
    return _predict;
}

+ (id <EMSPushNotificationProtocol>)push {
    return _mobileEngage;
}

+ (void)setMobileEngage:(MobileEngageInternal *)mobileEngage {
    _mobileEngage = mobileEngage;
}

+ (EMSSQLiteHelper *)sqliteHelper {
    return _dbHelper;
}

@end