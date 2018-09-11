//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "Emarsys.h"
#import "PredictInternal.h"
#import "MobileEngageInternal.h"

@implementation Emarsys

static PredictInternal *_predictInternal;
static MobileEngageInternal *_mobileEngageInternal;

+ (void)setupWithConfig:(EMSConfig *)config {
    _predictInternal = [[PredictInternal alloc] initWithRequestContext:nil];
    _mobileEngageInternal = [MobileEngageInternal new];
    [_mobileEngageInternal setupWithConfig:config launchOptions:nil requestRepositoryFactory:nil shardRepository:nil logRepository:nil requestContext:nil];
}


+ (void)setCustomerWithId:(NSString *)customerId
          completionBlock:(EMSCompletionBlock)completionBlock {

}

+ (void)setCustomerWithId:(NSString *)customerId {
    NSParameterAssert(customerId);
    [_predictInternal setCustomerWithId:customerId];
}


+ (void)setPredictInternal:(PredictInternal *)predictInternal {
    _predictInternal = predictInternal;
}

@end