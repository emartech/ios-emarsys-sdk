//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PRERequestContext;
@class EMSRequestModel;
@class EMSLogic;

NS_ASSUME_NONNULL_BEGIN

@interface EMSPredictRequestModelBuilder : NSObject

- (instancetype)initWithContext:(PRERequestContext *)requestContext;

- (instancetype)addLogic:(EMSLogic *)logic;

- (EMSRequestModel *)build;

@end

NS_ASSUME_NONNULL_END