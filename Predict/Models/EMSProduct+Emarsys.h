//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSProduct.h"
#import "EMSProductBuilder.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^EMSProductBuilderBlock)(EMSProductBuilder *builder);

@interface EMSProduct (Emarsys)

+ (instancetype)makeWithBuilder:(EMSProductBuilderBlock)builderBlock;

@end

NS_ASSUME_NONNULL_END