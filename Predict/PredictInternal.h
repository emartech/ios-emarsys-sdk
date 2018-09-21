//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSPredictProtocol.h"

@class PRERequestContext;
@class EMSRequestManager;

#define PREDICT_BASE_URL @"https://recommender.scarabresearch.com"

@interface PredictInternal : NSObject <EMSPredictProtocol>

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext
                        requestManager:(EMSRequestManager *)requestManager;

- (void)setCustomerWithId:(NSString *)customerId;

- (void)clearCustomer;

- (void)trackCategoryViewWithCategoryPath:(NSString *)categoryPath;

- (void)trackItemViewWithItemId:(NSString *)itemId;

- (void)trackCartWithCartItems:(NSArray<id <EMSCartItemProtocol>> *)cartItems;

@end