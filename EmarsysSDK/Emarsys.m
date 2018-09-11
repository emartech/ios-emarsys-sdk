//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "Emarsys.h"
#import "PredictInternal.h"
#import "MobileEngageInternal.h"
#import "MERequestModelRepositoryFactory.h"
#import "MERequestContext.h"
#import "MEInApp.h"

@implementation Emarsys

static PredictInternal *_predict;
static MobileEngageInternal *_mobileEngage;

+ (void)setupWithConfig:(EMSConfig *)config {
    NSParameterAssert(config);

    _predict = [[PredictInternal alloc] initWithRequestContext:nil];
    _mobileEngage = [MobileEngageInternal new];

    MERequestContext *requestContext = [[MERequestContext alloc] initWithConfig:config];
    MEInApp *_iam = [MEInApp new];


    [_mobileEngage setupWithConfig:config
                     launchOptions:nil
          requestRepositoryFactory:[[MERequestModelRepositoryFactory alloc] initWithInApp:_iam
                                                                           requestContext:requestContext]
                   shardRepository:nil
                     logRepository:nil
                    requestContext:nil];
}


+ (void)setCustomerWithId:(NSString *)customerId
          completionBlock:(EMSCompletionBlock)completionBlock {

}

+ (void)setCustomerWithId:(NSString *)customerId {
    NSParameterAssert(customerId);
    [_predict setCustomerWithId:customerId];
    [_mobileEngage appLoginWithContactFieldId:@3
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

@end