//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UNUserNotificationCenter;

NS_ASSUME_NONNULL_BEGIN
@interface EMSDeviceInfo: NSObject

@property(nonatomic, readonly) NSString *sdkVersion;
@property(nonatomic, readonly) UNUserNotificationCenter *notificationCenter;

- (instancetype)initWithSDKVersion:(NSString *)sdkVersion
                notificationCenter:(UNUserNotificationCenter *)notificationCenter;

- (NSString *)platform;

- (NSString *)timeZone;

- (NSString *)languageCode;

- (nullable NSString *)applicationVersion;

- (NSString *)deviceModel;

- (NSString *)deviceType;

- (NSString *)osVersion;

- (NSString *)systemName;

- (NSString *)hardwareId;

- (NSDictionary *)pushSettings;

@end
NS_ASSUME_NONNULL_END