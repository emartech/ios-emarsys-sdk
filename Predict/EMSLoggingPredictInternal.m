//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSLoggingPredictInternal.h"
#import "EMSMacros.h"
#import "EMSMethodNotAllowed.h"

#define klass [EMSLoggingPredictInternal class]

@implementation EMSLoggingPredictInternal

- (void)trackCartWithCartItems:(NSArray<id <EMSCartItemProtocol>> *)cartItems {
    NSDictionary *const parameters = @{
        @"cartItems": cartItems
    };
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters]);
}

- (void)trackPurchaseWithOrderId:(NSString *)orderId
                           items:(NSArray<id <EMSCartItemProtocol>> *)items {
    NSDictionary *const parameters = @{
        @"orderId": orderId,
        @"cartItems": items
    };
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters]);
}

- (void)trackCategoryViewWithCategoryPath:(NSString *)categoryPath {
    NSDictionary *const parameters = @{
        @"categoryPath": categoryPath
    };
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters]);
}

- (void)trackItemViewWithItemId:(NSString *)itemId {
    NSDictionary *const parameters = @{
        @"itemId": itemId
    };
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters]);
}

- (void)trackSearchWithSearchTerm:(NSString *)searchTerm {
    NSDictionary *const parameters = @{
        @"searchTerm": searchTerm
    };
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters]);
}

@end