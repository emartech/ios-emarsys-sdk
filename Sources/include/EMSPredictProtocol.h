//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSCartItemProtocol.h"
#import "EMSProductProtocol.h"

@class EMSProduct;
@class EMSLogic;
@protocol EMSRecommendationFilterProtocol;
@protocol EMSLogicProtocol;

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

- (void)recommendProductsWithLogic:(id <EMSLogicProtocol>)logic
                     productsBlock:(EMSProductsBlock)productsBlock
    NS_SWIFT_NAME(recommendProducts(logic:productsBlock:));

- (void)recommendProductsWithLogic:(id <EMSLogicProtocol>)logic
                             limit:(nullable NSNumber *)limit
                     productsBlock:(EMSProductsBlock)productsBlock
    NS_SWIFT_NAME(recommendProducts(logic:limit:productsBlock:));

- (void)recommendProductsWithLogic:(id <EMSLogicProtocol>)logic
                           filters:(nullable NSArray<id <EMSRecommendationFilterProtocol>> *)filters
                     productsBlock:(EMSProductsBlock)productsBlock
    NS_SWIFT_NAME(recommendProducts(logic:filters:productsBlock:));

- (void)recommendProductsWithLogic:(id <EMSLogicProtocol>)logic
                           filters:(nullable NSArray<id <EMSRecommendationFilterProtocol>> *)filters
                             limit:(nullable NSNumber *)limit
                     productsBlock:(EMSProductsBlock)productsBlock
    NS_SWIFT_NAME(recommendProducts(logic:filters:limit:productsBlock:));

- (void)recommendProductsWithLogic:(id <EMSLogicProtocol>)logic
                  availabilityZone:(nullable NSString *)availabilityZone
                     productsBlock:(EMSProductsBlock)productsBlock
    NS_SWIFT_NAME(recommendProducts(logic:availabilityZone:productsBlock:));

- (void)recommendProductsWithLogic:(id <EMSLogicProtocol>)logic
                             limit:(nullable NSNumber *)limit
                  availabilityZone:(nullable NSString *)availabilityZone
                     productsBlock:(EMSProductsBlock)productsBlock
    NS_SWIFT_NAME(recommendProducts(logic:limit:availabilityZone:productsBlock:));

- (void)recommendProductsWithLogic:(id <EMSLogicProtocol>)logic
                           filters:(nullable NSArray<id <EMSRecommendationFilterProtocol>> *)filters
                  availabilityZone:(nullable NSString *)availabilityZone
                     productsBlock:(EMSProductsBlock)productsBlock
    NS_SWIFT_NAME(recommendProducts(logic:filters:availabilityZone:productsBlock:));

- (void)recommendProductsWithLogic:(id <EMSLogicProtocol>)logic
                           filters:(nullable NSArray<id <EMSRecommendationFilterProtocol>> *)filters
                             limit:(nullable NSNumber *)limit
                  availabilityZone:(nullable NSString *)availabilityZone
                     productsBlock:(EMSProductsBlock)productsBlock
    NS_SWIFT_NAME(recommendProducts(logic:filters:limit:availabilityZone:productsBlock:));

- (void)trackRecommendationClick:(id <EMSProductProtocol>)product
    NS_SWIFT_NAME(trackRecommendationClick(product:));

@end

NS_ASSUME_NONNULL_END
