//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSPredictProtocol.h"

@class PRERequestContext;
@class EMSRequestManager;

@interface PredictInternal : NSObject <EMSPredictProtocol>

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext requestManager:(EMSRequestManager *)requestManager;

- (void)setCustomerWithId:(NSString *)customerId;

- (void)trackCategoryViewWithCategoryPath:(NSString *)categoryPath;

- (void)trackItemViewWithItemId:(NSString *)itemId;

@end