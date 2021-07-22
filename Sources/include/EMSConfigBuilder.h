//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSConfig;
@protocol EMSFlipperFeature;
@protocol EMSLogLevelProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface EMSConfigBuilder : NSObject

@property(nonatomic, readonly) NSString *applicationCode;
@property(nonatomic, readonly) NSArray<id <EMSFlipperFeature>> *experimentalFeatures;
@property(nonatomic, readonly) NSArray<id <EMSLogLevelProtocol>> *enabledConsoleLogLevels;
@property(nonatomic, readonly) NSString *merchantId;
@property(nonatomic, readonly) NSString *sharedKeychainAccessGroup;

- (EMSConfigBuilder *)setMobileEngageApplicationCode:(NSString *)applicationCode;

- (EMSConfigBuilder *)setExperimentalFeatures:(NSArray<id <EMSFlipperFeature>> *)features;

- (EMSConfigBuilder *)enableConsoleLogLevels:(NSArray<id <EMSLogLevelProtocol>> *)consoleLogLevels;

- (EMSConfigBuilder *)setMerchantId:(NSString *)merchantId;

- (EMSConfigBuilder *)setSharedKeychainAccessGroup:(NSString *)sharedKeychainAccessGroup;

@end

NS_ASSUME_NONNULL_END