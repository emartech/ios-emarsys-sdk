//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Emarsys.h"
#import "EMSPredictInternal.h"
#import "EMSSqliteSchemaHandler.h"
#import "EMSDependencyContainer.h"
#import "EMSDependencyInjection.h"
#import "MENotificationCenterManager.h"
#import "AppStartBlockProvider.h"
#import "EMSDeviceInfoClientProtocol.h"
#import "MERequestContext.h"
#import "EMSDeepLinkProtocol.h"
#import "EMSMobileEngageProtocol.h"
#import "MEExperimental.h"
#import "EMSInnerFeature.h"

@implementation Emarsys

+ (void)setupWithConfig:(EMSConfig *)config {
    NSParameterAssert(config);

    if (config.applicationCode) {
        [MEExperimental enableFeature:EMSInnerFeature.mobileEngage];
    }
    if (config.merchantId) {
        [MEExperimental enableFeature:EMSInnerFeature.predict];
    }

    [EMSDependencyInjection setupWithDependencyContainer:[[EMSDependencyContainer alloc] initWithConfig:config]];

    [Emarsys registerAppStartBlock];

    EMSDependencyContainer *container = EMSDependencyInjection.dependencyContainer;
    if (!container.requestContext.contactToken && !container.requestContext.contactFieldValue) {
        [container.deviceInfoClient sendDeviceInfoWithCompletionBlock:nil];
        [container.mobileEngage setContactWithContactFieldValue:nil];
    }
}

+ (void)setContactWithContactFieldValue:(NSString *)contactFieldValue {
    [Emarsys setContactWithContactFieldValue:contactFieldValue
                             completionBlock:nil];
}

+ (void)setContactWithContactFieldValue:(NSString *)contactFieldValue
                        completionBlock:(EMSCompletionBlock)completionBlock {
    NSParameterAssert(contactFieldValue);

    if ([MEExperimental isFeatureEnabled:EMSInnerFeature.mobileEngage] ||
            (![MEExperimental isFeatureEnabled:EMSInnerFeature.mobileEngage] && ![MEExperimental isFeatureEnabled:EMSInnerFeature.predict])) {
        [EMSDependencyInjection.dependencyContainer.mobileEngage setContactWithContactFieldValue:contactFieldValue
                                                                                 completionBlock:completionBlock];
    }
    if ([MEExperimental isFeatureEnabled:EMSInnerFeature.predict]) {
        [EMSDependencyInjection.dependencyContainer.predict setContactWithContactFieldValue:contactFieldValue];
    }
}

+ (void)clearContact {
    [Emarsys clearContactWithCompletionBlock:nil];
}

+ (void)clearContactWithCompletionBlock:(EMSCompletionBlock)completionBlock {

    if ([MEExperimental isFeatureEnabled:EMSInnerFeature.mobileEngage] ||
            (![MEExperimental isFeatureEnabled:EMSInnerFeature.mobileEngage] && ![MEExperimental isFeatureEnabled:EMSInnerFeature.predict])) {
        [EMSDependencyInjection.dependencyContainer.mobileEngage clearContactWithCompletionBlock:completionBlock];
    }
    if ([MEExperimental isFeatureEnabled:EMSInnerFeature.predict]) {
        [EMSDependencyInjection.dependencyContainer.predict clearContact];
    }
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
    return [EMSDependencyInjection.dependencyContainer.deepLink trackDeepLinkWith:userActivity
                                                                    sourceHandler:sourceHandler];
}

+ (void)registerAppStartBlock {
    MENotificationCenterManager *notificationCenterManager = EMSDependencyInjection.dependencyContainer.notificationCenterManager;
    AppStartBlockProvider *appStartBlockProvider = EMSDependencyInjection.dependencyContainer.appStartBlockProvider;
    [notificationCenterManager addHandlerBlock:[appStartBlockProvider createDeviceInfoEventBlock]
                               forNotification:UIApplicationDidBecomeActiveNotification];
    [notificationCenterManager addHandlerBlock:[appStartBlockProvider createAppStartEventBlock]
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