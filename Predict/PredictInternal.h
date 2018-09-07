//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@class PRERequestContext;

@interface PredictInternal : NSObject

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext;

- (void)setCustomerWithId:(NSString *)customerId;

- (void)trackCategoryViewWithCategoryPath:(NSString *)categoryPath;


@end