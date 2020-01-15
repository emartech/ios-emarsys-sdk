//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UNUserNotificationCenter;
@class EMSStorage;
@class ASIdentifierManager;

NS_ASSUME_NONNULL_BEGIN

@interface EMSDeviceInfo : NSObject

@property(nonatomic, readonly) NSString *sdkVersion;
@property(nonatomic, readonly) UNUserNotificationCenter *notificationCenter;
@property(nonatomic, readonly) EMSStorage *storage;
@property(nonatomic, readonly) ASIdentifierManager *identifierManager;

- (instancetype)initWithSDKVersion:(NSString *)sdkVersion
                notificationCenter:(UNUserNotificationCenter *)notificationCenter
                           storage:(EMSStorage *)storage
                 identifierManager:(ASIdentifierManager *)identifierManager;

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