//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PRERequestContext;
@class EMSRequestModel;

NS_ASSUME_NONNULL_BEGIN

@interface EMSPredictRequestModelBuilder : NSObject

- (instancetype)initWithContext:(PRERequestContext *)requestContext;

- (instancetype)addSearchTerm:(NSString *)searchTerm;

- (EMSRequestModel *)build;

@end

NS_ASSUME_NONNULL_END