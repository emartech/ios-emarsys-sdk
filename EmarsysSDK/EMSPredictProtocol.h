//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSCartItemProtocol.h"

@class EMSProduct;

NS_ASSUME_NONNULL_BEGIN

typedef void (^EMSProductsBlock)(NSArray<EMSProduct *> *_Nullable products, NSError *_Nullable error);

@protocol EMSPredictProtocol <NSObject>

- (void)trackCartWithCartItems:(NSArray<id <EMSCartItemProtocol>> *)cartItems;

- (void)trackPurchaseWithOrderId:(NSString *)orderId
                           items:(NSArray<id <EMSCartItemProtocol>> *)items;

- (void)trackCategoryViewWithCategoryPath:(NSString *)categoryPath;

- (void)trackItemViewWithItemId:(NSString *)itemId;

- (void)trackSearchWithSearchTerm:(NSString *)searchTerm;

- (void)recommendProducts:(EMSProductsBlock)productsBlock;

@end

NS_ASSUME_NONNULL_END
