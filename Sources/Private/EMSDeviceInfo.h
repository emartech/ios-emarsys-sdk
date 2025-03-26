//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UNUserNotificationCenter;
@class EMSStorage;
@class EMSUUIDProvider;

NS_ASSUME_NONNULL_BEGIN

@interface EMSDeviceInfo : NSObject

@property(nonatomic, readonly) NSString *sdkVersion;
@property(nonatomic, readonly) UNUserNotificationCenter *notificationCenter;
@property(nonatomic, readonly) EMSStorage *storage;
@property(nonatomic, readonly) EMSUUIDProvider *uuidProvider;
@property(nonatomic, strong) NSString *clientId;

- (instancetype)initWithSDKVersion:(NSString *)sdkVersion
                notificationCenter:(UNUserNotificationCenter *)notificationCenter
                           storage:(EMSStorage *)storage
                      uuidProvider:(EMSUUIDProvider *)uuidProvider;

- (NSString *)platform;

- (NSString *)timeZone;

- (NSString *)languageCode;

- (nullable NSString *)applicationVersion;

- (NSString *)deviceModel;

- (NSString *)deviceType;

- (NSString *)osVersion;

- (NSString *)systemName;

- (NSDictionary *)pushSettings;

@end

NS_ASSUME_NONNULL_END
