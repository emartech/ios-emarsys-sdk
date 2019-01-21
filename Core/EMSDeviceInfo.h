//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface EMSDeviceInfo: NSObject

@property(nonatomic, readonly) NSString *sdkVersion;

- (instancetype)initWithSDKVersion:(NSString *)sdkVersion;

- (NSString *)platform;

- (NSString *)timeZone;

- (NSString *)languageCode;

- (nullable NSString *)applicationVersion;

- (NSString *)deviceModel;

- (NSString *)deviceType;

- (NSString *)osVersion;

- (NSString *)systemName;

- (NSString *)hardwareId;

@end
NS_ASSUME_NONNULL_END