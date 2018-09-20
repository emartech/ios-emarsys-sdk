//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "Emarsys.h"
#import "PredictInternal.h"
#import "MobileEngageInternal.h"
#import "MESchemaDelegate.h"
#import "EMSDependencyContainer.h"

@implementation Emarsys

static EMSConfig *_config;
static EMSDependencyContainer *_dependencyContainer;

+ (void)setupWithConfig:(EMSConfig *)config {
    NSParameterAssert(config);
    _config = config;
    _dependencyContainer = [[EMSDependencyContainer alloc] initWithConfig:config];
}

+ (void)setCustomerWithId:(NSString *)customerId
          completionBlock:(EMSCompletionBlock)completionBlock {
}

+ (void)setCustomerWithId:(NSString *)customerId {
    NSParameterAssert(customerId);
    [_dependencyContainer.predict setCustomerWithId:customerId];
    [_dependencyContainer.mobileEngage appLoginWithContactFieldValue:customerId];
}

+ (id <EMSPredictProtocol>)predict {
    return _dependencyContainer.predict;
}

+ (id <EMSPushNotificationProtocol>)push {
    return _dependencyContainer.mobileEngage;
}

+ (EMSSQLiteHelper *)sqliteHelper {
    return _dependencyContainer.dbHelper;
}

+ (void)setDependencyContainer:(EMSDependencyContainer *)dependencyContainer {
    _dependencyContainer = dependencyContainer;
}

@end