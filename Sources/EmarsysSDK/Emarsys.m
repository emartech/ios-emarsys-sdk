//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "Emarsys.h"
#import "EMSPredictInternal.h"
#import "EMSDependencyContainer.h"
#import "EMSDependencyInjection.h"
#import "EMSNotificationCenterManager.h"
#import "EMSAppStartBlockProvider.h"
#import "EMSDeviceInfoClientProtocol.h"
#import "MERequestContext.h"
#import "EMSDeepLinkProtocol.h"
#import "EMSMobileEngageProtocol.h"
#import "EMSInnerFeature.h"
#import "MEExperimental.h"

#define kSDKAlreadyInstalled @"kSDKAlreadyInstalled"
@implementation Emarsys

+ (BOOL)alreadyInstalled {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
    return [userDefaults boolForKey:kSDKAlreadyInstalled];
}

+ (void)setupWithConfig:(EMSConfig *)config {
    NSParameterAssert(config);

    if (config.applicationCode) {
        [MEExperimental enableFeature:EMSInnerFeature.mobileEngage];
        [MEExperimental enableFeature:EMSInnerFeature.eventServiceV4];
    }
    if (config.merchantId) {
        [MEExperimental enableFeature:EMSInnerFeature.predict];
    }

    [self initializeDefaultCategory];

    [EMSDependencyInjection setupWithDependencyContainer:[[EMSDependencyContainer alloc] initWithConfig:config]];

    EMSDependencyContainer *dependencyContainer = EMSDependencyInjection.dependencyContainer;

    [dependencyContainer.publicApiOperationQueue addOperationWithBlock:^{
        [Emarsys resetRequestContextOnReinstall];
        [Emarsys registerAppStartBlock];
        if (!dependencyContainer.requestContext.contactToken && !dependencyContainer.requestContext.hasContactIdentification) {
            [dependencyContainer.deviceInfoClient trackDeviceInfoWithCompletionBlock:nil];
            [dependencyContainer.mobileEngage setContactWithContactFieldId:nil
                                                         contactFieldValue:nil];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EmarsysSDKDidFinishSetupNotification"
                                                            object:nil];
    }];
    [dependencyContainer.publicApiOperationQueue waitUntilAllOperationsAreFinished];
}

+ (void)resetRequestContextOnReinstall {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
    BOOL alreadyInstalled = [userDefaults boolForKey:kSDKAlreadyInstalled];
    if (!alreadyInstalled && !EMSDependencyInjection.dependencyContainer.requestContext.contactFieldValue) {
        [EMSDependencyInjection.dependencyContainer.requestContext reset];
        [userDefaults setBool:YES forKey:kSDKAlreadyInstalled];
    }
}

+ (void)initializeDefaultCategory {
    UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"EMSDefaultCategory"
                                                                              actions:@[]
                                                                    intentIdentifiers:@[]
                                                                              options:0];
    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithArray:@[category]]];
}

+ (void)setAuthenticatedContactWithContactFieldId:(NSNumber *)contactFieldId
                                      openIdToken:(NSString *)openIdToken {
    [Emarsys setAuthenticatedContactWithContactFieldId:contactFieldId
                                           openIdToken:openIdToken
                                       completionBlock:nil];
}

+ (void)setAuthenticatedContactWithContactFieldId:(NSNumber *)contactFieldId
                                      openIdToken:(NSString *)openIdToken
                                  completionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSParameterAssert(contactFieldId);
    NSParameterAssert(openIdToken);
    if ([MEExperimental isFeatureEnabled:EMSInnerFeature.mobileEngage] ||
            (![MEExperimental isFeatureEnabled:EMSInnerFeature.mobileEngage] && ![MEExperimental isFeatureEnabled:EMSInnerFeature.predict])) {
        [EMSDependencyInjection.dependencyContainer.mobileEngage setAuthenticatedContactWithContactFieldId:contactFieldId
                                                                                               openIdToken:openIdToken
                                                                                           completionBlock:completionBlock];
    }

    [MEExperimental disableFeature:EMSInnerFeature.predict];
}

+ (void)setContactWithContactFieldId:(NSNumber *)contactFieldId
                   contactFieldValue:(NSString *)contactFieldValue {
    [Emarsys setContactWithContactFieldId:contactFieldId
                        contactFieldValue:contactFieldValue
                          completionBlock:nil];
}

+ (void)setContactWithContactFieldId:(NSNumber *)contactFieldId
                   contactFieldValue:(NSString *)contactFieldValue
                     completionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSParameterAssert(contactFieldId);
    NSParameterAssert(contactFieldValue);

    if ([MEExperimental isFeatureEnabled:EMSInnerFeature.mobileEngage] ||
            (![MEExperimental isFeatureEnabled:EMSInnerFeature.mobileEngage] && ![MEExperimental isFeatureEnabled:EMSInnerFeature.predict])) {
        [EMSDependencyInjection.dependencyContainer.mobileEngage setContactWithContactFieldId:contactFieldId
                                                                            contactFieldValue:contactFieldValue
                                                                              completionBlock:completionBlock];
    }
    if ([MEExperimental isFeatureEnabled:EMSInnerFeature.predict]) {
        [EMSDependencyInjection.dependencyContainer.predict setContactWithContactFieldId:contactFieldId
                                                                       contactFieldValue:contactFieldValue];
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

+ (id <EMSInAppProtocol>)inApp {
    return EMSDependencyInjection.iam;
}

+ (id)geofence {
    return EMSDependencyInjection.geofence;
}

+ (id <EMSPredictProtocol>)predict {
    return EMSDependencyInjection.predict;
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

+ (id <EMSOnEventActionProtocol>)onEventAction {
    return EMSDependencyInjection.onEventAction;
}

@end
