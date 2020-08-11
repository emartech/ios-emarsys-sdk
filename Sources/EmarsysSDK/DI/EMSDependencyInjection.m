//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSDependencyInjection.h"
#import "MEExperimental.h"
#import "EMSGeofenceProtocol.h"
#import "EMSMessageInboxProtocol.h"


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
    return self.dependencyContainer.mobileEngage;
}

+ (id <EMSPushNotificationProtocol>)push {
    return self.dependencyContainer.push;
}

+ (id <EMSDeepLinkProtocol>)deepLink {
    return self.dependencyContainer.deepLink;
}

+ (id <EMSInboxProtocol>)inbox {
    return self.dependencyContainer.inbox;
}

+ (id <EMSUserNotificationCenterDelegate>)notificationCenterDelegate {
    return self.dependencyContainer.notificationCenterDelegate;
}

+ (id <EMSInAppProtocol, MEIAMProtocol>)iam {
    return self.dependencyContainer.iam;
}

+ (id <EMSPredictProtocol, EMSPredictInternalProtocol>)predict {
    return self.dependencyContainer.predict;
}

+ (id <EMSGeofenceProtocol>)geofence {
    return self.dependencyContainer.geofence;
}

+ (id <EMSMessageInboxProtocol>)messageInbox {
    return self.dependencyContainer.messageInbox;
}

@end