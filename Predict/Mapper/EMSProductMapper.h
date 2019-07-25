//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSProduct;
@class EMSResponseModel;

NS_ASSUME_NONNULL_BEGIN

@interface EMSProductMapper : NSObject

- (NSArray<EMSProduct *> *)mapFromResponse:(EMSResponseModel *)responseModel;

@end

NS_ASSUME_NONNULL_END