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
#import "MEUserNotificationDelegate.h"

@implementation Emarsys

+ (void)setupWithConfig:(EMSConfig *)config {
    NSParameterAssert(config);

    [MEExperimental enableFeatures:config.experimentalFeatures];
    [EMSDependencyInjection setupWithDependencyContainer:[[EMSDependencyContainer alloc] initWithConfig:config]];

    [Emarsys registerAppStartBlock];
}

+ (void)setContactWithContactFieldValue:(NSString *)contactFieldValue
                        completionBlock:(EMSCompletionBlock)completionBlock {
    NSParameterAssert(contactFieldValue);
    [EMSDependencyInjection.dependencyContainer.predict setCustomerWithId:contactFieldValue];
    [EMSDependencyInjection.dependencyContainer.mobileEngage setContactWithContactFieldValue:contactFieldValue
                                                                             completionBlock:completionBlock];
}

+ (void)setContactWithContactFieldValue:(NSString *)contactFieldValue {
    [Emarsys setContactWithContactFieldValue:contactFieldValue
                             completionBlock:nil];
}

+ (void)clearContact {
    [Emarsys clearContactWithCompletionBlock:nil];
}

+ (void)clearContactWithCompletionBlock:(EMSCompletionBlock)completionBlock {
    [EMSDependencyInjection.dependencyContainer.predict clearCustomer];
    [EMSDependencyInjection.dependencyContainer.mobileEngage clearContactWithCompletionBlock:completionBlock];
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
    [EMSDependencyInjection.dependencyContainer.mobileEngage trackCustomEventWithName:eventName
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
    EMSRequestFactory *requestFactory = EMSDependencyInjection.dependencyContainer.requestFactory;

    [notificationCenterManager addHandlerBlock:[appStartBlockProvider createAppStartBlockWithRequestManager:requestManager
                                                                                             requestContext:requestContext]
                               forNotification:UIApplicationDidBecomeActiveNotification];
    [notificationCenterManager addHandlerBlock:[appStartBlockProvider createAppStartBlockWithRequestManager:requestManager
                                                                                             requestFactory:requestFactory
                                                                                                 deviceInfo:requestContext.deviceInfo]
                               forNotification:UIApplicationDidBecomeActiveNotification];
}

+ (id <EMSPushNotificationProtocol>)push {
    return EMSDependencyInjection.dependencyContainer.push;
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

+ (id <EMSUserNotificationCenterDelegate>)notificationCenterDelegate {
    return EMSDependencyInjection.dependencyContainer.notificationCenterDelegate;
}


+ (EMSSQLiteHelper *)sqliteHelper {
    return EMSDependencyInjection.dependencyContainer.dbHelper;
}

@end