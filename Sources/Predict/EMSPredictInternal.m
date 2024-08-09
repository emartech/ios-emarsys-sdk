//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <EMSResponseModel.h>
#import "EMSPredictInternal.h"
#import "PRERequestContext.h"
#import "EMSRequestManager.h"
#import "EMSShard.h"
#import "EMSCartItemUtils.h"
#import "EMSPredictRequestModelBuilderProvider.h"
#import "EMSPredictRequestModelBuilder.h"
#import "EMSProductMapper.h"
#import "EMSLogic.h"
#import "EMSProduct.h"
#import "NSString+EMSCore.h"

@interface EMSPredictInternal ()

@property(nonatomic, strong) PRERequestContext *requestContext;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSPredictRequestModelBuilderProvider *requestBuilderProvider;
@property(nonatomic, strong) EMSProductMapper *productMapper;
@property(nonatomic, strong) NSString *lastSearchTerm;
@property(nonatomic, strong) NSArray<id <EMSCartItemProtocol>> *lastCartItems;
@property(nonatomic, strong) NSString *lastViewItemId;
@property(nonatomic, strong) NSString *lastCategoryPath;

@end

@implementation EMSPredictInternal

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext
                        requestManager:(EMSRequestManager *)requestManager
                requestBuilderProvider:(EMSPredictRequestModelBuilderProvider *)requestBuilderProvider
                         productMapper:(EMSProductMapper *)productMapper {
    NSParameterAssert(requestContext);
    NSParameterAssert(requestManager);
    NSParameterAssert(requestBuilderProvider);
    NSParameterAssert(productMapper);

    if (self = [super init]) {
        _requestContext = requestContext;
        _requestManager = requestManager;
        _requestBuilderProvider = requestBuilderProvider;
        _productMapper = productMapper;
    }
    return self;
}

- (void)setContactWithContactFieldId:(NSNumber *)contactFieldId
                   contactFieldValue:(NSString *)contactFieldValue {
    NSParameterAssert(contactFieldId);
    NSParameterAssert(contactFieldValue);
    [self.requestContext setContactFieldId:contactFieldId];
    [self.requestContext setContactFieldValue:contactFieldValue];
}

- (void)clearContact {
    [self.requestContext setContactFieldId:nil];
    [self.requestContext setContactFieldValue:nil];
    [self.requestContext setVisitorId:nil];
}

- (void)trackCategoryViewWithCategoryPath:(NSString *)categoryPath {
    NSParameterAssert(categoryPath);
    _lastCategoryPath = categoryPath;
    EMSShard *shard = [EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                [builder setType:@"predict_item_category_view"];
                [builder addPayloadEntryWithKey:@"vc"
                                          value:categoryPath];
            }
                              timestampProvider:[self.requestContext timestampProvider]
                                   uuidProvider:[self.requestContext uuidProvider]];

    [self.requestManager submitShard:shard];
}

- (void)trackItemViewWithItemId:(NSString *)itemId {
    NSParameterAssert(itemId);
    _lastViewItemId = itemId;
    EMSShard *shard = [EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                [builder setType:@"predict_item_view"];
                [builder addPayloadEntryWithKey:@"v"
                                          value:[NSString stringWithFormat:@"i:%@",
                                                                           [itemId percentEncode]]];
            }
                              timestampProvider:[self.requestContext timestampProvider]
                                   uuidProvider:[self.requestContext uuidProvider]];

    [self.requestManager submitShard:shard];
}

- (void)trackCartWithCartItems:(NSArray<id <EMSCartItemProtocol>> *)cartItems {
    NSParameterAssert(cartItems);
    _lastCartItems = cartItems;
    [self.requestManager submitShard:[EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                [builder setType:@"predict_cart"];
                [builder addPayloadEntryWithKey:@"cv"
                                          value:@"1"];
                [builder addPayloadEntryWithKey:@"ca"
                                          value:[EMSCartItemUtils queryParamFromCartItems:cartItems]];
            }
                                             timestampProvider:self.requestContext.timestampProvider
                                                  uuidProvider:self.requestContext.uuidProvider]];
}

- (void)trackSearchWithSearchTerm:(NSString *)searchTerm {
    NSParameterAssert(searchTerm);
    _lastSearchTerm = searchTerm;
    EMSShard *shard = [EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                [builder setType:@"predict_search_term"];
                [builder addPayloadEntryWithKey:@"q"
                                          value:searchTerm];
            }
                              timestampProvider:[self.requestContext timestampProvider]
                                   uuidProvider:[self.requestContext uuidProvider]];

    [self.requestManager submitShard:shard];
}

- (void)trackPurchaseWithOrderId:(NSString *)orderId
                           items:(NSArray<id <EMSCartItemProtocol>> *)items {
    NSParameterAssert(orderId);
    NSParameterAssert(items);
    NSParameterAssert(items.count > 0);

    [self.requestManager submitShard:[EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                [builder setType:@"predict_purchase"];
                [builder addPayloadEntryWithKey:@"co"
                                          value:[EMSCartItemUtils queryParamFromCartItems:items]];
                [builder addPayloadEntryWithKey:@"oi"
                                          value:orderId];
            }
                                             timestampProvider:self.requestContext.timestampProvider
                                                  uuidProvider:self.requestContext.uuidProvider]];
}

- (void)trackTag:(NSString *)tag
  withAttributes:(nullable NSDictionary<NSString *, NSString *> *)attributes {
    NSParameterAssert(tag);

    EMSShard *shard = [EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                [builder setType:@"predict_tag"];

                if (!attributes) {
                    [builder addPayloadEntryWithKey:@"t"
                                              value:tag];
                } else {
                    NSData *serializedData = [NSJSONSerialization dataWithJSONObject:@{@"name": tag, @"attributes": attributes}
                                                                             options:0
                                                                               error:nil];
                    NSString *payload = [[NSString alloc] initWithData:serializedData
                                                              encoding:NSUTF8StringEncoding];
                    [builder addPayloadEntryWithKey:@"ta"
                                              value:payload];
                }
            }
                              timestampProvider:[self.requestContext timestampProvider]
                                   uuidProvider:[self.requestContext uuidProvider]];

    [self.requestManager submitShard:shard];
}

- (void)recommendProductsWithLogic:(id <EMSLogicProtocol>)logic
                     productsBlock:(EMSProductsBlock)productsBlock {
    [self recommendProductsWithLogic:logic
                             filters:nil
                               limit:nil
                    availabilityZone:nil
                       productsBlock:productsBlock];
}

- (void)recommendProductsWithLogic:(id <EMSLogicProtocol>)logic
                             limit:(nullable NSNumber *)limit
                     productsBlock:(EMSProductsBlock)productsBlock {
    [self recommendProductsWithLogic:logic
                             filters:nil
                               limit:limit
                    availabilityZone:nil
                       productsBlock:productsBlock];
}

- (void)recommendProductsWithLogic:(id <EMSLogicProtocol>)logic
                           filters:(nullable NSArray<id <EMSRecommendationFilterProtocol>> *)filters
                     productsBlock:(EMSProductsBlock)productsBlock {
    [self recommendProductsWithLogic:logic
                             filters:filters
                               limit:nil
                    availabilityZone:nil
                       productsBlock:productsBlock];
}

- (void)recommendProductsWithLogic:(id <EMSLogicProtocol>)logic
                           filters:(nullable NSArray<id <EMSRecommendationFilterProtocol>> *)filters
                             limit:(nullable NSNumber *)limit
                     productsBlock:(EMSProductsBlock)productsBlock {
    [self recommendProductsWithLogic:logic
                             filters:filters
                               limit:limit
                    availabilityZone:nil
                       productsBlock:productsBlock];
}

- (void)recommendProductsWithLogic:(id <EMSLogicProtocol>)logic
                  availabilityZone:(NSString *)availabilityZone
                     productsBlock:(EMSProductsBlock)productsBlock {
    [self recommendProductsWithLogic:logic
                             filters:nil
                               limit:nil
                    availabilityZone:availabilityZone
                       productsBlock:productsBlock];

}

- (void)recommendProductsWithLogic:(id <EMSLogicProtocol>)logic
                             limit:(NSNumber *)limit
                  availabilityZone:(NSString *)availabilityZone
                     productsBlock:(EMSProductsBlock)productsBlock {
    [self recommendProductsWithLogic:logic
                             filters:nil
                               limit:limit
                    availabilityZone:availabilityZone
                       productsBlock:productsBlock];

}

- (void)recommendProductsWithLogic:(id <EMSLogicProtocol>)logic
                           filters:(NSArray *)filters
                  availabilityZone:(NSString *)availabilityZone
                     productsBlock:(EMSProductsBlock)productsBlock {
    [self recommendProductsWithLogic:logic
                             filters:filters
                               limit:nil
                    availabilityZone:availabilityZone
                       productsBlock:productsBlock];

}

- (void)recommendProductsWithLogic:(id <EMSLogicProtocol>)logic
                           filters:(NSArray *)filters
                             limit:(NSNumber *)limit
                  availabilityZone:(NSString *)availabilityZone
                     productsBlock:(EMSProductsBlock)productsBlock {

    NSParameterAssert(productsBlock);
    NSParameterAssert(logic);

    EMSRequestModel *requestModel = [[[[[[[[[[self.requestBuilderProvider provideBuilder]
            withLogic:logic]
            withLimit:limit]
            withFilter:filters]
            withLastSearchTerm:self.lastSearchTerm]
            withLastCartItems:self.lastCartItems]
            withLastCategoryPath:self.lastCategoryPath]
            withLastViewItemId:self.lastViewItemId]
            withAvailabilityZone:availabilityZone]
            build];

    __weak typeof(self) weakSelf = self;
    [_requestManager submitRequestModelNow:requestModel
                              successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                  if (productsBlock) {
                                      NSArray *products = [weakSelf.productMapper mapFromResponse:response];
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          productsBlock(products, nil);
                                      });
                                  }
                              }
                                errorBlock:^(NSString *requestId, NSError *error) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        if (productsBlock) {
                                            productsBlock(nil, error);
                                        }
                                    });
                                }];
}

- (void)trackRecommendationClick:(id <EMSProductProtocol>)product {
    NSParameterAssert(product);
    _lastViewItemId = product.productId;
    EMSShard *shard = [EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                [builder setType:@"predict_item_view"];
                [builder addPayloadEntryWithKey:@"v"
                                          value:[NSString stringWithFormat:@"i:%@,t:%@,c:%@",
                                                                           [product.productId percentEncode],
                                                                           product.feature,
                                                                           product.cohort]];
            }
                              timestampProvider:[self.requestContext timestampProvider]
                                   uuidProvider:[self.requestContext uuidProvider]];

    [self.requestManager submitShard:shard];
}

@end
