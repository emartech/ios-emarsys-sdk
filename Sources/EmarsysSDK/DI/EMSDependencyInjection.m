//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSDependencyInjection.h"
#import "MEExperimental.h"
#import "EMSInnerFeature.h"


@implementation EMSDependencyInjection

static EMSDependencyContainer *_dependencyContainer;

+ (void)setupWithDependencyContainer:(id <EMSDependencyContainerProtocol>)dependencyContainer {
    if (!_dependencyContainer) {
        [EMSDependencyInjection setDependencyContainer:dependencyContainer];
    }
}

+ (void)tearDown {
    [EMSDependencyInjection setDependencyContainer:nil];
}

+ (EMSDependencyContainer *)dependencyContainer {
    return _dependencyContainer;
}

+ (void)setDependencyContainer:(EMSDependencyContainer *)dependencyContainer {
    _dependencyContainer = dependencyContainer;
}

+ (id <EMSMobileEngageProtocol>)mobileEngage {
    id <EMSMobileEngageProtocol> result;
    if ([MEExperimental isFeatureEnabled:[EMSInnerFeature mobileEngage]]) {
        result = self.dependencyContainer.mobileEngage;
    } else {
        result = self.dependencyContainer.loggingMobileEngage;
    }
    return result;
}

+ (id <EMSPushNotificationProtocol>)push {
    id <EMSPushNotificationProtocol> result;
    if ([MEExperimental isFeatureEnabled:[EMSInnerFeature mobileEngage]]) {
        result = self.dependencyContainer.push;
    } else {
        result = self.dependencyContainer.loggingPush;
    }
    return result;
}

+ (id <EMSDeepLinkProtocol>)deepLink {
    id <EMSDeepLinkProtocol> result;
    if ([MEExperimental isFeatureEnabled:[EMSInnerFeature mobileEngage]]) {
        result = self.dependencyContainer.deepLink;
    } else {
        result = self.dependencyContainer.loggingDeepLink;
    }
    return result;
}

+ (id <EMSInboxProtocol>)inbox {
    id <EMSInboxProtocol> result;
    if ([MEExperimental isFeatureEnabled:[EMSInnerFeature mobileEngage]]) {
        result = self.dependencyContainer.inbox;
    } else {
        result = self.dependencyContainer.loggingInbox;
    }
    return result;
}

+ (id <EMSUserNotificationCenterDelegate>)notificationCenterDelegate {
    id <EMSUserNotificationCenterDelegate> result;
    if ([MEExperimental isFeatureEnabled:[EMSInnerFeature mobileEngage]]) {
        result = self.dependencyContainer.notificationCenterDelegate;
    } else {
        result = self.dependencyContainer.loggingNotificationCenterDelegate;
    }
    return result;
}

+ (id <EMSInAppProtocol, MEIAMProtocol>)iam {
    id <EMSInAppProtocol, MEIAMProtocol> result;
    if ([MEExperimental isFeatureEnabled:[EMSInnerFeature mobileEngage]]) {
        result = self.dependencyContainer.iam;
    } else {
        result = self.dependencyContainer.loggingIam;
    }
    return result;
}

+ (id <EMSPredictProtocol, EMSPredictInternalProtocol>)predict {
    id <EMSPredictProtocol, EMSPredictInternalProtocol> result;
    if ([MEExperimental isFeatureEnabled:[EMSInnerFeature predict]]) {
        result = self.dependencyContainer.predict;
    } else {
        result = self.dependencyContainer.loggingPredict;
    }
    return result;
}


@end