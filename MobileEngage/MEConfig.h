//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEFlipperFeatures.h"

@class MEConfigBuilder;

NS_ASSUME_NONNULL_BEGIN
@interface MEConfig : NSObject

@property(nonatomic, readonly) NSString *applicationCode;
@property(nonatomic, readonly) NSString *applicationPassword;
@property(nonatomic, readonly) NSArray<MEFlipperFeature> *experimentalFeatures;

typedef void(^MEConfigBuilderBlock)(MEConfigBuilder *builder);

+ (MEConfig *)makeWithBuilder:(MEConfigBuilderBlock)builderBlock;

@end

NS_ASSUME_NONNULL_END