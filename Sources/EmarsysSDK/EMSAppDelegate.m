//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSAppDelegate.h"
#import "EMSConfig.h"
#import "Emarsys.h"

@implementation EMSAppDelegate

- (BOOL)          application:(UIApplication *)application
didFinishLaunchingWithOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions {
    [Emarsys setupWithConfig:self.provideEMSConfig];
    if (self.eventHandler) {
        Emarsys.inApp.eventHandler = self.eventHandler;
        Emarsys.notificationCenterDelegate.eventHandler = self.eventHandler;
        Emarsys.push.silentMessageEventHandler = self.eventHandler;
        Emarsys.geofence.eventHandler = self.eventHandler;
        Emarsys.onEventAction.eventHandler = self.eventHandler;
    }

    UNUserNotificationCenter.currentNotificationCenter.delegate = Emarsys.notificationCenterDelegate;

    [application registerForRemoteNotifications];

    UNAuthorizationOptions authorizationOptions = UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge;
    if (@available(iOS 12.0, *)) {
        authorizationOptions = authorizationOptions | UNAuthorizationOptionProvisional;
    }

    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authorizationOptions
                                                                        completionHandler:^(BOOL granted, NSError *error) {
                                                                        }];
    return YES;
}

- (BOOL) application:(UIApplication *)application
continueUserActivity:(NSUserActivity *)userActivity
  restorationHandler:(void (^)(NSArray<id <UIUserActivityRestoring>> *__nullable restorableObjects))restorationHandler {
    return [Emarsys trackDeepLinkWithUserActivity:userActivity
                                    sourceHandler:^(NSString *source) {
                                    }];
}

- (void)handleEvent:(NSString *)eventName
            payload:(nullable NSDictionary<NSString *, NSObject *> *)payload {

}

- (void)                             application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [Emarsys.push setPushToken:deviceToken];
}

- (void)         application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
      fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    [Emarsys.push handleMessageWithUserInfo:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (EMSConfig *)provideEMSConfig {
    NSAssert(NO, @"Abstract method must be implemented");
    return nil;
}

@end
