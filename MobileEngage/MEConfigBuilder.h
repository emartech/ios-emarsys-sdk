//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEFlipperFeatures.h"

@class MEConfig;

NS_ASSUME_NONNULL_BEGIN
@interface MEConfigBuilder : NSObject

@property(nonatomic, readonly) NSString *applicationCode;
@property(nonatomic, readonly) NSString *applicationPassword;
@property(nonatomic, readonly) NSArray<MEFlipperFeature> *experimentalFeatures;

- (MEConfigBuilder *)setCredentialsWithApplicationCode:(NSString *)applicationCode
                                   applicationPassword:(NSString *)applicationPassword;

- (MEConfigBuilder *)setExperimentalFeatures:(NSArray<MEFlipperFeature> *)features;

@end

NS_ASSUME_NONNULL_END