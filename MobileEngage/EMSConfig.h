//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEFlipperFeatures.h"
#import "EMSConfigBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSConfig : NSObject

@property(nonatomic, readonly) NSString *applicationCode;
@property(nonatomic, readonly) NSString *applicationPassword;
@property(nonatomic, readonly) NSArray<EMSFlipperFeature> *experimentalFeatures;
@property(nonatomic, readonly) NSString *merchantId;
@property(nonatomic, readonly) NSNumber *contactFieldId;

typedef void(^MEConfigBuilderBlock)(EMSConfigBuilder *builder);

+ (EMSConfig *)makeWithBuilder:(MEConfigBuilderBlock)builderBlock;

@end

NS_ASSUME_NONNULL_END