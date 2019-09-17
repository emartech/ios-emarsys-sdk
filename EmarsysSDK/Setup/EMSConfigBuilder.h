//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSConfig;
@protocol EMSFlipperFeature;

NS_ASSUME_NONNULL_BEGIN

@interface EMSConfigBuilder : NSObject

@property(nonatomic, readonly) NSString *applicationCode;
@property(nonatomic, readonly) NSArray<id<EMSFlipperFeature>> *experimentalFeatures;
@property(nonatomic, readonly) NSString *merchantId;
@property(nonatomic, readonly) NSNumber *contactFieldId;

- (EMSConfigBuilder *)setMobileEngageApplicationCode:(NSString *)applicationCode;

- (EMSConfigBuilder *)setExperimentalFeatures:(NSArray<id<EMSFlipperFeature>> *)features;

- (EMSConfigBuilder *)setMerchantId:(NSString *)merchantId;

- (EMSConfigBuilder *)setContactFieldId:(NSNumber *)contactFieldId;

@end

NS_ASSUME_NONNULL_END