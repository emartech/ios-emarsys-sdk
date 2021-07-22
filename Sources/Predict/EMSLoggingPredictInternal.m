//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSLoggingPredictInternal.h"
#import "EMSMacros.h"
#import "EMSMethodNotAllowed.h"
#import "EMSProduct.h"

#define proto @protocol(EMSPredictProtocol)

@implementation EMSLoggingPredictInternal

- (void)trackCartWithCartItems:(NSArray<id <EMSCartItemProtocol>> *)cartItems {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"cartItems"] = [cartItems description];
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (void)trackPurchaseWithOrderId:(NSString *)orderId
                           items:(NSArray<id <EMSCartItemProtocol>> *)items {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"orderId"] = orderId;
    parameters[@"cartItems"] = [items description];
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (void)trackCategoryViewWithCategoryPath:(NSString *)categoryPath {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"categoryPath"] = categoryPath;
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (void)trackItemViewWithItemId:(NSString *)itemId {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"itemId"] = itemId;
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (void)trackSearchWithSearchTerm:(NSString *)searchTerm {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"searchTerm"] = searchTerm;
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (void)setContactWithContactFieldId:(NSNumber *)contactFieldId
                   contactFieldValue:(NSString *)contactFieldValue {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"contactFieldId"] = contactFieldId;
    parameters[@"contactFieldValue"] = contactFieldValue;
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (void)clearContact {
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:nil], LogLevelDebug);
}

- (void)trackTag:(NSString *)tag
  withAttributes:(nullable NSDictionary<NSString *, NSString *> *)attributes {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"tag"] = tag;
    parameters[@"attributes"] = attributes;
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (void)recommendProductsWithLogic:(EMSLogic *)logic productsBlock:(EMSProductsBlock)productsBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"productsBlock"] = @(productsBlock != nil);
    parameters[@"logic"] = logic;
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (void)recommendProductsWithLogic:(EMSLogic *)logic
                             limit:(nullable NSNumber *)limit
                     productsBlock:(EMSProductsBlock)productsBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"productsBlock"] = @(productsBlock != nil);
    parameters[@"logic"] = logic;
    parameters[@"limit"] = limit;
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (void)recommendProductsWithLogic:(EMSLogic *)logic
                           filters:(nullable NSArray<id <EMSRecommendationFilterProtocol>> *)filters
                     productsBlock:(EMSProductsBlock)productsBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"productsBlock"] = @(productsBlock != nil);
    parameters[@"logic"] = logic;
    parameters[@"filter"] = [filters description];
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (void)recommendProductsWithLogic:(EMSLogic *)logic
                           filters:(nullable NSArray<id <EMSRecommendationFilterProtocol>> *)filters
                             limit:(nullable NSNumber *)limit
                     productsBlock:(EMSProductsBlock)productsBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"productsBlock"] = @(productsBlock != nil);
    parameters[@"logic"] = logic;
    parameters[@"limit"] = limit;
    parameters[@"filter"] = [filters description];
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (void)recommendProductsWithLogic:(EMSLogic *)logic
                  availabilityZone:(NSString *)availabilityZone
                     productsBlock:(EMSProductsBlock)productsBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"productsBlock"] = @(productsBlock != nil);
    parameters[@"logic"] = logic;
    parameters[@"availabilityZone"] = availabilityZone;
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (void)recommendProductsWithLogic:(EMSLogic *)logic
                             limit:(NSNumber *)limit
                  availabilityZone:(NSString *)availabilityZone
                     productsBlock:(EMSProductsBlock)productsBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"productsBlock"] = @(productsBlock != nil);
    parameters[@"logic"] = logic;
    parameters[@"limit"] = limit;
    parameters[@"availabilityZone"] = availabilityZone;
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (void)recommendProductsWithLogic:(EMSLogic *)logic
                           filters:(NSArray *)filters
                  availabilityZone:(NSString *)availabilityZone
                     productsBlock:(EMSProductsBlock)productsBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"productsBlock"] = @(productsBlock != nil);
    parameters[@"logic"] = logic;
    parameters[@"filter"] = [filters description];
    parameters[@"availabilityZone"] = availabilityZone;
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (void)recommendProductsWithLogic:(EMSLogic *)logic
                           filters:(NSArray *)filters
                             limit:(NSNumber *)limit
                  availabilityZone:(NSString *)availabilityZone
                     productsBlock:(EMSProductsBlock)productsBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"productsBlock"] = @(productsBlock != nil);
    parameters[@"logic"] = logic;
    parameters[@"limit"] = limit;
    parameters[@"filter"] = [filters description];
    parameters[@"availabilityZone"] = availabilityZone;
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}


- (void)trackRecommendationClick:(EMSProduct *)product {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"product"] = product.description;
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

@end
