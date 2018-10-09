//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "Emarsys.h"
#import "PredictInternal.h"
#import "MobileEngageInternal.h"
#import "MESchemaDelegate.h"
#import "EMSDependencyContainer.h"
#import "MEInApp.h"

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
    NSParameterAssert(customerId);
    [_dependencyContainer.predict setCustomerWithId:customerId];
    [_dependencyContainer.mobileEngage appLoginWithContactFieldValue:customerId
                                                     completionBlock:completionBlock];
}

+ (void)setCustomerWithId:(NSString *)customerId {
    [Emarsys setCustomerWithId:customerId
               completionBlock:nil];
}

+ (void)clearCustomer {
    [Emarsys clearCustomerWithCompletionBlock:nil];
}

+ (void)clearCustomerWithCompletionBlock:(EMSCompletionBlock)completionBlock {
    [_dependencyContainer.predict clearCustomer];
    [_dependencyContainer.mobileEngage appLogoutWithCompletionBlock:completionBlock];
}

+ (void)trackCustomEventWithName:(NSString *)eventName
                 eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes {
    [Emarsys trackCustomEventWithName:eventName
                      eventAttributes:eventAttributes
                      completionBlock:nil];
}

+ (void)trackCustomEventWithName:(NSString *)eventName
                 eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes
                 completionBlock:(EMSCompletionBlock)completionBlock {
    [_dependencyContainer.mobileEngage trackCustomEvent:eventName
                                        eventAttributes:eventAttributes
                                        completionBlock:completionBlock];
}

+ (BOOL)trackDeepLinkWithUserActivity:(NSUserActivity *)userActivity
                        sourceHandler:(EMSSourceHandler)sourceHandler {
    return [_dependencyContainer.mobileEngage trackDeepLinkWith:userActivity
                                                  sourceHandler:sourceHandler];
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

+ (EMSDependencyContainer *)dependencyContainer {
    return _dependencyContainer;
}

@end