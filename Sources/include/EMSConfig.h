//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSConfigBuilder.h"

@protocol EMSFlipperFeature;
@protocol EMSLogLevelProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface EMSConfig : NSObject

@property(nonatomic, readonly) NSString *applicationCode;
@property(nonatomic, readonly) NSArray<id <EMSFlipperFeature>> *experimentalFeatures;
@property(nonatomic, readonly) NSArray<id <EMSLogLevelProtocol>> *enabledConsoleLogLevels;
@property(nonatomic, readonly) NSString *merchantId;
@property(nonatomic, readonly) NSNumber *contactFieldId;
@property(nonatomic, readonly) NSString *sharedKeychainAccessGroup;

typedef void(^MEConfigBuilderBlock)(EMSConfigBuilder *builder);

+ (EMSConfig *)makeWithBuilder:(MEConfigBuilderBlock)builderBlock;

@end

NS_ASSUME_NONNULL_END