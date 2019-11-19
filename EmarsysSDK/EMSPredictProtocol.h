//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <EmarsysSDK/EMSCartItemProtocol.h>

@class EMSProduct;
@class EMSLogic;
@protocol EMSRecommendationFilterProtocol;

NS_ASSUME_NONNULL_BEGIN

typedef void (^EMSProductsBlock)(NSArray<EMSProduct *> *_Nullable products, NSError *_Nullable error);

@protocol EMSPredictProtocol <NSObject>

- (void)trackCartWithCartItems:(NSArray<id <EMSCartItemProtocol>> *)cartItems;

- (void)trackPurchaseWithOrderId:(NSString *)orderId
                           items:(NSArray<id <EMSCartItemProtocol>> *)items;

- (void)trackCategoryViewWithCategoryPath:(NSString *)categoryPath;

- (void)trackItemViewWithItemId:(NSString *)itemId;

- (void)trackSearchWithSearchTerm:(NSString *)searchTerm;

- (void)trackTag:(NSString *)tag
  withAttributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

- (void)recommendProductsWithLogic:(EMSLogic *)logic
                     productsBlock:(EMSProductsBlock)productsBlock;

- (void)recommendProductsWithLogic:(EMSLogic *)logic
                             limit:(nullable NSNumber *)limit
                     productsBlock:(EMSProductsBlock)productsBlock;

- (void)recommendProductsWithLogic:(EMSLogic *)logic
                           filters:(nullable NSArray<id <EMSRecommendationFilterProtocol>> *)filters
                     productsBlock:(EMSProductsBlock)productsBlock;

- (void)recommendProductsWithLogic:(EMSLogic *)logic
                           filters:(nullable NSArray<id <EMSRecommendationFilterProtocol>> *)filters
                             limit:(nullable NSNumber *)limit
                     productsBlock:(EMSProductsBlock)productsBlock;

- (void)trackRecommendationClick:(EMSProduct *)product;

@end

NS_ASSUME_NONNULL_END
