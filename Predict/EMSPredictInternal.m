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

@interface EMSPredictInternal ()

@property(nonatomic, strong) PRERequestContext *requestContext;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSPredictRequestModelBuilderProvider *requestBuilderProvider;
@property(nonatomic, strong) EMSProductMapper *productMapper;

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

- (void)setContactWithContactFieldValue:(NSString *)contactFieldValue {
    NSParameterAssert(contactFieldValue);
    [self.requestContext setCustomerId:contactFieldValue];
}

- (void)clearContact {
    [self.requestContext setCustomerId:nil];
    [self.requestContext setVisitorId:nil];
}

- (void)trackCategoryViewWithCategoryPath:(NSString *)categoryPath {
    NSParameterAssert(categoryPath);
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
    EMSShard *shard = [EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                [builder setType:@"predict_item_view"];
                [builder addPayloadEntryWithKey:@"v" value:[NSString stringWithFormat:@"i:%@", itemId]];
            }
                              timestampProvider:[self.requestContext timestampProvider]
                                   uuidProvider:[self.requestContext uuidProvider]];

    [self.requestManager submitShard:shard];
}

- (void)trackCartWithCartItems:(NSArray<id <EMSCartItemProtocol>> *)cartItems {
    NSParameterAssert(cartItems);

    [self.requestManager submitShard:[EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                [builder setType:@"predict_cart"];
                [builder addPayloadEntryWithKey:@"cv" value:@"1"];
                [builder addPayloadEntryWithKey:@"ca" value:[EMSCartItemUtils queryParamFromCartItems:cartItems]];
            }
                                             timestampProvider:self.requestContext.timestampProvider
                                                  uuidProvider:self.requestContext.uuidProvider]];
}

- (void)trackSearchWithSearchTerm:(NSString *)searchTerm {
    NSParameterAssert(searchTerm);

    EMSShard *shard = [EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                [builder setType:@"predict_search_term"];
                [builder addPayloadEntryWithKey:@"q" value:searchTerm];
            }
                              timestampProvider:[self.requestContext timestampProvider]
                                   uuidProvider:[self.requestContext uuidProvider]];

    [self.requestManager submitShard:shard];
}

- (void)trackPurchaseWithOrderId:(NSString *)orderId
                           items:(NSArray<id <EMSCartItemProtocol>> *)items {
    NSParameterAssert(orderId);
    NSParameterAssert(items);

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
  withAttributes:(NSDictionary *)attributes {
    NSParameterAssert(tag);

    EMSShard *shard = [EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                [builder setType:@"predict_tag"];

                if (!attributes) {
                    [builder addPayloadEntryWithKey:@"t" value:tag];
                } else {
                    NSData *serializedData = [NSJSONSerialization dataWithJSONObject:@{@"name": tag, @"attributes": attributes} options:0 error:nil];
                    NSString *payload = [[NSString alloc] initWithData:serializedData encoding:NSUTF8StringEncoding];
                    [builder addPayloadEntryWithKey:@"ta" value:payload];
                }
            }
                              timestampProvider:[self.requestContext timestampProvider]
                                   uuidProvider:[self.requestContext uuidProvider]];

    [self.requestManager submitShard:shard];
}

- (void)recommendProducts:(EMSProductsBlock)productsBlock
                withLogic:(EMSLogic *)logic {
    NSParameterAssert(productsBlock);
    NSParameterAssert(logic);

    EMSRequestModel *requestModel = [[[self.requestBuilderProvider provideBuilder] addLogic:logic] build];

    __weak typeof(self) weakSelf = self;
    [_requestManager submitRequestModelNow:requestModel
                              successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                  NSArray *products = [weakSelf.productMapper mapFromResponse:response];
                                  if (productsBlock) {
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

@end