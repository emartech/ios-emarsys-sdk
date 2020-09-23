//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSDeviceInfo.h"
#import "EMSStorage.h"
#import "EMSUUIDProvider.h"
#import <sys/utsname.h>
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@interface EMSDeviceInfo ()

@end

@implementation EMSDeviceInfo

#define kEMSHardwareIdKey @"kHardwareIdKey"
#define kEMSSuiteName @"com.emarsys.core"

- (instancetype)initWithSDKVersion:(NSString *)sdkVersion
                notificationCenter:(UNUserNotificationCenter *)notificationCenter
                           storage:(EMSStorage *)storage
                      uuidProvider:(EMSUUIDProvider *)uuidProvider {
    NSParameterAssert(sdkVersion);
    NSParameterAssert(notificationCenter);
    NSParameterAssert(storage);
    NSParameterAssert(uuidProvider);
    if (self = [super init]) {
        _sdkVersion = sdkVersion;
        _notificationCenter = notificationCenter;
        _storage = storage;
        _uuidProvider = uuidProvider;
    }
    return self;
}

- (NSString *)platform {
    return @"ios";
}

- (NSString *)timeZone {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone localTimeZone];
    formatter.dateFormat = @"xxxx";
    return [formatter stringFromDate:[NSDate date]];
}

- (NSString *)languageCode {
    return [NSLocale preferredLanguages][0];
}

- (NSString *)applicationVersion {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
}

- (NSString *)deviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    return @(systemInfo.machine);
}

- (NSString *)deviceType {
    NSDictionary *idiomDict = @{
        @(UIUserInterfaceIdiomUnspecified): @"UnspecifiediOS",
        @(UIUserInterfaceIdiomPhone): @"iPhone",
        @(UIUserInterfaceIdiomPad): @"iPad",
        @(UIUserInterfaceIdiomTV): @"AppleTV",
        @(UIUserInterfaceIdiomCarPlay): @"iPhone"
    };

    return idiomDict[@([UIDevice.currentDevice userInterfaceIdiom])];
}

- (NSString *)osVersion {
    return [UIDevice currentDevice].systemVersion;
}

- (NSString *)systemName {
    return [UIDevice currentDevice].systemName;
}

- (NSString *)hardwareId {
    if (!_hardwareId) {
        NSData *hardwareIdData = [self.storage sharedDataForKey:kEMSHardwareIdKey];
        if (hardwareIdData) {
            _hardwareId = [[NSString alloc] initWithData:hardwareIdData
                                                encoding:NSUTF8StringEncoding];
        }
        if (!_hardwareId) {
            _hardwareId = [self.uuidProvider provideUUIDString];
            [self.storage setSharedData:[_hardwareId dataUsingEncoding:NSUTF8StringEncoding]
                                 forKey:kEMSHardwareIdKey];
        }
    }
    return _hardwareId;
}

- (NSDictionary *)pushSettings {
    NSMutableDictionary *pushSettings = [NSMutableDictionary dictionary];
    __weak typeof(self) weakSelf = self;
    dispatch_group_t dispatchGroup = dispatch_group_create();
    dispatch_group_enter(dispatchGroup);
    [self.notificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
        pushSettings[@"authorizationStatus"] = [weakSelf authorizationStatusStringRepresentation:settings.authorizationStatus];
        pushSettings[@"soundSetting"] = [weakSelf notificationSettingStringRepresentation:settings.soundSetting];
        pushSettings[@"badgeSetting"] = [weakSelf notificationSettingStringRepresentation:settings.badgeSetting];
        pushSettings[@"alertSetting"] = [weakSelf notificationSettingStringRepresentation:settings.alertSetting];
        pushSettings[@"notificationCenterSetting"] = [weakSelf notificationSettingStringRepresentation:settings.notificationCenterSetting];
        pushSettings[@"lockScreenSetting"] = [weakSelf notificationSettingStringRepresentation:settings.lockScreenSetting];
        pushSettings[@"carPlaySetting"] = [weakSelf notificationSettingStringRepresentation:settings.carPlaySetting];
        pushSettings[@"alertStyle"] = [weakSelf alertStyleStringRepresentation:settings.alertStyle];
        pushSettings[@"showPreviewsSetting"] = [weakSelf showPreviewsSettingStringRepresentation:settings.showPreviewsSetting];
        if (@available(iOS 12.0, *)) {
            pushSettings[@"criticalAlertSetting"] = [weakSelf notificationSettingStringRepresentation:settings.criticalAlertSetting];
            pushSettings[@"providesAppNotificationSettings"] = @(settings.providesAppNotificationSettings);
        }
        dispatch_group_leave(dispatchGroup);
    }];
    dispatch_group_wait(dispatchGroup, dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC));
    return pushSettings;
}

- (NSString *)showPreviewsSettingStringRepresentation:(UNShowPreviewsSetting)setting {
    NSString *result = @"never";
    switch (setting) {
        case UNShowPreviewsSettingNever:
            result = @"never";
            break;
        case UNShowPreviewsSettingWhenAuthenticated:
            result = @"whenAuthenticated";
            break;
        case UNShowPreviewsSettingAlways:
            result = @"always";
            break;
    }
    return result;
}

- (NSString *)alertStyleStringRepresentation:(UNAlertStyle)setting {
    NSString *alertStyle = @"none";
    switch (setting) {
        case UNAlertStyleAlert:
            alertStyle = @"alert";
            break;
        case UNAlertStyleBanner:
            alertStyle = @"banner";
            break;
        case UNAlertStyleNone:
            alertStyle = @"none";
            break;
    }
    return alertStyle;
}

- (NSString *)notificationSettingStringRepresentation:(UNNotificationSetting)setting {
    NSString *notificationSetting = @"notSupported";
    switch (setting) {
        case UNNotificationSettingEnabled:
            notificationSetting = @"enabled";
            break;
        case UNNotificationSettingDisabled:
            notificationSetting = @"disabled";
            break;
        case UNNotificationSettingNotSupported:
            notificationSetting = @"notSupported";
            break;
    }
    return notificationSetting;
}

- (NSString *)authorizationStatusStringRepresentation:(UNAuthorizationStatus)status {
    NSString *authorizationStatus = @"notDetermined";
    if (status == UNAuthorizationStatusAuthorized) {
        authorizationStatus = @"authorized";
    } else if (status == UNAuthorizationStatusDenied) {
        authorizationStatus = @"denied";
    } else if (@available(iOS 12.0, *)) {
        if (status == UNAuthorizationStatusProvisional) {
            authorizationStatus = @"provisional";
        }
    } else if (status == UNAuthorizationStatusNotDetermined) {
        authorizationStatus = @"notDetermined";
    } else if (@available(iOS 14.0, *)) {
        if (status == UNAuthorizationStatusEphemeral) {
            authorizationStatus = @"ephemeral";
        }
    }
    return authorizationStatus;
}

@end