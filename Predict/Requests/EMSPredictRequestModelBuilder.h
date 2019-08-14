//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PRERequestContext;
@class EMSRequestModel;
@class EMSLogic;
@protocol EMSCartItemProtocol;

#define PREDICT_URL(merchantId) [NSString stringWithFormat:@"https://recommender.scarabresearch.com/merchants/%@/", merchantId]

NS_ASSUME_NONNULL_BEGIN

@interface EMSPredictRequestModelBuilder : NSObject

- (instancetype)initWithContext:(PRERequestContext *)requestContext;

- (instancetype)withLogic:(EMSLogic *)logic;

- (instancetype)withLastSearchTerm:(NSString *)searchTerm;

- (instancetype)withLastCartItems:(NSArray<id <EMSCartItemProtocol>> *)cartItems;

- (instancetype)withLastViewItemId:(NSString *)viewItemId;

- (instancetype)withLastCategoryPath:(NSString *)categoryPath;

- (instancetype)withLimit:(NSNumber *)limit;

- (EMSRequestModel *)build;

@end

NS_ASSUME_NONNULL_END