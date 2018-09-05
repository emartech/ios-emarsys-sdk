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

- (EMSConfigBuilder *)setCredentialsWithApplicationCode:(NSString *)applicationCode
                                    applicationPassword:(NSString *)applicationPassword;

- (EMSConfigBuilder *)setExperimentalFeatures:(NSArray<MEFlipperFeature> *)features;

@end

NS_ASSUME_NONNULL_END