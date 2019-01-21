//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSDeviceInfo.h"
#import <sys/utsname.h>
#import <UIKit/UIKit.h>
#import <AdSupport/AdSupport.h>

@implementation EMSDeviceInfo

#define kEMSHardwareIdKey @"kHardwareIdKey"
#define kEMSSuiteName @"com.emarsys.core"

- (NSString *)timeZone {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone localTimeZone];
    formatter.dateFormat = @"xxxx";
    return [formatter stringFromDate:[NSDate date]];
}

- (NSString *)languageCode {
    NSString *language = [NSLocale preferredLanguages][0];
    NSDictionary *languageDic = [NSLocale componentsFromLocaleIdentifier:language];
    NSString *languageCode = languageDic[(NSString *) kCFLocaleLanguageCode];
    return languageCode;
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
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
    NSString *hardwareId = [userDefaults objectForKey:kEMSHardwareIdKey];

    if (!hardwareId) {
        hardwareId = [self getNewHardwareId];
        [userDefaults setObject:hardwareId forKey:kEMSHardwareIdKey];
        [userDefaults synchronize];
    }

    return hardwareId;
}

- (NSString *)getNewHardwareId {
    if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
        return [[[ASIdentifierManager sharedManager] advertisingIdentifier]
                UUIDString];
    }
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

@end