//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSCartItemProtocol.h"

@protocol EMSPredictProtocol <NSObject>

+ (void)trackCartWithCartItems:(NSArray<id <EMSCartItemProtocol>> *)cartItems;

+ (void)trackPurchaseWithOrderId:(NSString *)orderId
                           items:(NSArray<id <EMSCartItemProtocol>> *)cartItems;

+ (void)trackCategoryViewWithCategoryPath:(NSString *)categoryPath;

+ (void)trackItemWithItemId:(NSString *)itemId;

+ (void)trackSearchWithSearchterm:(NSString *)searchterm;

@end