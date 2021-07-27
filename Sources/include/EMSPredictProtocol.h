//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSCartItemProtocol.h"

@class EMSProduct;
@class EMSLogic;
@protocol EMSRecommendationFilterProtocol;

NS_ASSUME_NONNULL_BEGIN

typedef void (^EMSProductsBlock)(NSArray<EMSProduct *> *_Nullable products, NSError *_Nullable error);

@protocol EMSPredictProtocol <NSObject>

- (void)trackCartWithCartItems:(NSArray<id <EMSCartItemProtocol>> *)items
    NS_SWIFT_NAME(trackCart(items:));

- (void)trackPurchaseWithOrderId:(NSString *)orderId
                           items:(NSArray<id <EMSCartItemProtocol>> *)items
    NS_SWIFT_NAME(trackPurchase(orderId:items:));

- (void)trackCategoryViewWithCategoryPath:(NSString *)categoryPath
    NS_SWIFT_NAME(trackCategory(categoryPath:));

- (void)trackItemViewWithItemId:(NSString *)itemId
    NS_SWIFT_NAME(trackItem(itemId:));

- (void)trackSearchWithSearchTerm:(NSString *)searchTerm
    NS_SWIFT_NAME(trackSearch(searchTerm:));

- (void)trackTag:(NSString *)tag
  withAttributes:(nullable NSDictionary<NSString *, NSString *> *)attributes
    NS_SWIFT_NAME(trackTag(tag:attributes:));

- (void)recommendProductsWithLogic:(EMSLogic *)logic
                     productsBlock:(EMSProductsBlock)productsBlock
    NS_SWIFT_NAME(recommendProducts(logic:productsBlock:));

- (void)recommendProductsWithLogic:(EMSLogic *)logic
                             limit:(nullable NSNumber *)limit
                     productsBlock:(EMSProductsBlock)productsBlock
    NS_SWIFT_NAME(recommendProducts(logic:limit:productsBlock:));

- (void)recommendProductsWithLogic:(EMSLogic *)logic
                           filters:(nullable NSArray<id <EMSRecommendationFilterProtocol>> *)filters
                     productsBlock:(EMSProductsBlock)productsBlock
    NS_SWIFT_NAME(recommendProducts(logic:filters:productsBlock:));

- (void)recommendProductsWithLogic:(EMSLogic *)logic
                           filters:(nullable NSArray<id <EMSRecommendationFilterProtocol>> *)filters
                             limit:(nullable NSNumber *)limit
                     productsBlock:(EMSProductsBlock)productsBlock
    NS_SWIFT_NAME(recommendProducts(logic:filters:limit:productsBlock:));

- (void)recommendProductsWithLogic:(EMSLogic *)logic
                  availabilityZone:(nullable NSString *)availabilityZone
                     productsBlock:(EMSProductsBlock)productsBlock
    NS_SWIFT_NAME(recommendProducts(logic:availabilityZone:productsBlock:));

- (void)recommendProductsWithLogic:(EMSLogic *)logic
                             limit:(nullable NSNumber *)limit
                  availabilityZone:(nullable NSString *)availabilityZone
                     productsBlock:(EMSProductsBlock)productsBlock
    NS_SWIFT_NAME(recommendProducts(logic:limit:availabilityZone:productsBlock:));

- (void)recommendProductsWithLogic:(EMSLogic *)logic
                           filters:(nullable NSArray<id <EMSRecommendationFilterProtocol>> *)filters
                  availabilityZone:(nullable NSString *)availabilityZone
                     productsBlock:(EMSProductsBlock)productsBlock
    NS_SWIFT_NAME(recommendProducts(logic:filters:availabilityZone:productsBlock:));

- (void)recommendProductsWithLogic:(EMSLogic *)logic
                           filters:(nullable NSArray<id <EMSRecommendationFilterProtocol>> *)filters
                             limit:(nullable NSNumber *)limit
                  availabilityZone:(nullable NSString *)availabilityZone
                     productsBlock:(EMSProductsBlock)productsBlock
    NS_SWIFT_NAME(recommendProducts(logic:filters:limit:availabilityZone:productsBlock:));

- (void)trackRecommendationClick:(EMSProduct *)product
    NS_SWIFT_NAME(trackRecommendationClick(product:));

@end

NS_ASSUME_NONNULL_END
