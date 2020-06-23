//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "Emarsys.h"
#import "EMSPredictInternal.h"
#import "EMSSqliteSchemaHandler.h"
#import "EMSDependencyContainer.h"
#import "EMSDependencyInjection.h"
#import "EMSNotificationCenterManager.h"
#import "EMSAppStartBlockProvider.h"
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

    [self initializeDefaultCategory];

    [EMSDependencyInjection setupWithDependencyContainer:[[EMSDependencyContainer alloc] initWithConfig:config]];

    EMSDependencyContainer *dependencyContainer = EMSDependencyInjection.dependencyContainer;

    [dependencyContainer.publicApiOperationQueue addOperationWithBlock:^{
        [Emarsys registerAppStartBlock];
        if (!dependencyContainer.requestContext.contactToken && !dependencyContainer.requestContext.contactFieldValue) {
            [dependencyContainer.deviceInfoClient sendDeviceInfoWithCompletionBlock:nil];
            [dependencyContainer.mobileEngage setContactWithContactFieldValue:nil];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EmarsysSDKDidFinishSetupNotification"
                                                            object:nil];
    }];
}

+ (void)initializeDefaultCategory {
    UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"EMSDefaultCategory"
                                                                              actions:@[]
                                                                    intentIdentifiers:@[]
                                                                              options:0];
    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithArray:@[category]]];
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
    EMSNotificationCenterManager *notificationCenterManager = EMSDependencyInjection.dependencyContainer.notificationCenterManager;
    EMSAppStartBlockProvider *appStartBlockProvider = EMSDependencyInjection.dependencyContainer.appStartBlockProvider;
    [notificationCenterManager addHandlerBlock:[appStartBlockProvider createDeviceInfoEventBlock]
                               forNotification:UIApplicationDidBecomeActiveNotification];
    [notificationCenterManager addHandlerBlock:[appStartBlockProvider createAppStartEventBlock]
                               forNotification:@"EmarsysSDKDidFinishSetupNotification"];
    [notificationCenterManager addHandlerBlock:[appStartBlockProvider createFetchGeofenceEventBlock]
                               forNotification:@"EmarsysSDKDidFinishSetupNotification"];
    [notificationCenterManager addHandlerBlock:[appStartBlockProvider createRemoteConfigEventBlock]
                               forNotification:@"EmarsysSDKDidFinishSetupNotification"];
}

+ (id <EMSPushNotificationProtocol>)push {
    return EMSDependencyInjection.push;
}

+ (id <EMSInboxProtocol>)inbox {
    return EMSDependencyInjection.inbox;
}

+ (id <EMSInAppProtocol>)inApp {
    return EMSDependencyInjection.iam;
}

+ (id)geofence {
    return EMSDependencyInjection.geofence;
}

+ (id <EMSPredictProtocol>)predict {
    return EMSDependencyInjection.predict;
}

+ (id <EMSUserNotificationCenterDelegate>)notificationCenterDelegate {
    return EMSDependencyInjection.notificationCenterDelegate;
}

+ (EMSSQLiteHelper *)sqliteHelper {
    return EMSDependencyInjection.dependencyContainer.dbHelper;
}

+ (id <EMSConfigProtocol>)config {
    return EMSDependencyInjection.dependencyContainer.config;
}

+ (id <EMSMessageInboxProtocol>)messageInbox {
    return EMSDependencyInjection.messageInbox;
}

@end
