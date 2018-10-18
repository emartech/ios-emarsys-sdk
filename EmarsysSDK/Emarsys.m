//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Emarsys.h"
#import "PredictInternal.h"
#import "MobileEngageInternal.h"
#import "EMSSqliteSchemaHandler.h"
#import "EMSDependencyContainer.h"
#import "MEInApp.h"
#import "EMSDependencyInjection.h"
#import "MEExperimental.h"
#import "MERequestContext.h"
#import "MENotificationCenterManager.h"
#import "AppStartBlockProvider.h"

@implementation Emarsys

+ (void)setupWithConfig:(EMSConfig *)config {
    NSParameterAssert(config);

    [MEExperimental enableFeatures:config.experimentalFeatures];
    [EMSDependencyInjection setupWithDependencyContainer:[[EMSDependencyContainer alloc] initWithConfig:config]];

    [Emarsys registerAppStartBlock];
}

+ (void)setCustomerWithId:(NSString *)customerId
          completionBlock:(EMSCompletionBlock)completionBlock {
    NSParameterAssert(customerId);
    [EMSDependencyInjection.dependencyContainer.predict setCustomerWithId:customerId];
    [EMSDependencyInjection.dependencyContainer.mobileEngage appLoginWithContactFieldValue:customerId
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
    [EMSDependencyInjection.dependencyContainer.predict clearCustomer];
    [EMSDependencyInjection.dependencyContainer.mobileEngage appLogoutWithCompletionBlock:completionBlock];
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
    [EMSDependencyInjection.dependencyContainer.mobileEngage trackCustomEvent:eventName
                                                              eventAttributes:eventAttributes
                                                              completionBlock:completionBlock];
}

+ (BOOL)trackDeepLinkWithUserActivity:(NSUserActivity *)userActivity
                        sourceHandler:(EMSSourceHandler)sourceHandler {
    return [EMSDependencyInjection.dependencyContainer.mobileEngage trackDeepLinkWith:userActivity
                                                                        sourceHandler:sourceHandler];
}

+ (void)registerAppStartBlock {
    MENotificationCenterManager *notificationCenterManager = EMSDependencyInjection.dependencyContainer.notificationCenterManager;
    AppStartBlockProvider *appStartBlockProvider = EMSDependencyInjection.dependencyContainer.appStartBlockProvider;
    EMSRequestManager *requestManager = EMSDependencyInjection.dependencyContainer.requestManager;
    MERequestContext *requestContext = EMSDependencyInjection.dependencyContainer.requestContext;

    [notificationCenterManager addHandlerBlock:[appStartBlockProvider createAppStartBlockWithRequestManager:requestManager
                                                                                             requestContext:requestContext]
                               forNotification:UIApplicationDidBecomeActiveNotification];
}

+ (id <EMSPushNotificationProtocol>)push {
    return EMSDependencyInjection.dependencyContainer.mobileEngage;
}

+ (id <EMSInboxProtocol>)inbox {
    return EMSDependencyInjection.dependencyContainer.inbox;
}

+ (id <EMSInAppProtocol>)inApp {
    return EMSDependencyInjection.dependencyContainer.iam;
}

+ (id <EMSPredictProtocol>)predict {
    return EMSDependencyInjection.dependencyContainer.predict;
}

+ (EMSSQLiteHelper *)sqliteHelper {
    return EMSDependencyInjection.dependencyContainer.dbHelper;
}

@end