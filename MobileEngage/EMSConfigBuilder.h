//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEFlipperFeatures.h"

@class EMSConfig;

NS_ASSUME_NONNULL_BEGIN

@interface EMSConfigBuilder : NSObject

@property(nonatomic, readonly) NSString *applicationCode;
@property(nonatomic, readonly) NSString *applicationPassword;
@property(nonatomic, readonly) NSArray<MEFlipperFeature> *experimentalFeatures;
@property(nonatomic, readonly) NSString *merchantId;
@property(nonatomic, readonly) NSNumber *contactFieldId;

- (EMSConfigBuilder *)setMobileEngageApplicationCode:(NSString *)applicationCode
                                 applicationPassword:(NSString *)applicationPassword;

- (EMSConfigBuilder *)setExperimentalFeatures:(NSArray<MEFlipperFeature> *)features;

- (EMSConfigBuilder *)setMerchantId:(NSString *)merchantId;

- (EMSConfigBuilder *)setContactFieldId:(NSNumber *)contactFieldId;

@end

NS_ASSUME_NONNULL_END