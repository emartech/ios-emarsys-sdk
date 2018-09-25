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

+ (void)clearCustomer {
    [Emarsys clearCustomerWithCompletionBlock:nil];
}

+ (void)clearCustomerWithCompletionBlock:(EMSCompletionBlock)completionBlock {
    [_dependencyContainer.mobileEngage appLogout];
    [_dependencyContainer.predict clearCustomer];
}

+ (id <EMSPushNotificationProtocol>)push {
    return _dependencyContainer.mobileEngage;
}

+ (id <EMSInboxProtocol>)inbox {
    return _dependencyContainer.inbox;
}

+ (id <EMSInAppProtocol>)inApp {
    return _dependencyContainer.iam;
}

+ (id <EMSPredictProtocol>)predict {
    return _dependencyContainer.predict;
}

+ (EMSSQLiteHelper *)sqliteHelper {
    return _dependencyContainer.dbHelper;
}

+ (void)setDependencyContainer:(EMSDependencyContainer *)dependencyContainer {
    _dependencyContainer = dependencyContainer;
}

@end