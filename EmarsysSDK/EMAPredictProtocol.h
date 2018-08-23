//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "PRECartItemProtocol.h"

@protocol EMAPredictProtocol <NSObject>

+ (void)trackCartWithItems:(NSArray<id<PRECartItemProtocol>> *)cartItems;
+ (void)trackCategoryViewWithCategoryPath:(NSString *)categoryPath;
+ (void)trackPurchaseWithOrderId:(NSString *)orderId
                           items:(NSArray<id<PRECartItemProtocol>> *)cartItems;
+ (void)trackSearchTermWithTerm:(NSString *)searchTerm;
+ (void)trackItemViewWithItemId:(NSString *)itemId;

@end