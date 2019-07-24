//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <EMSResponseModel.h>
#import "EMSPredictInternal.h"
#import "PRERequestContext.h"
#import "EMSRequestManager.h"
#import "EMSShard.h"
#import "EMSCartItemUtils.h"
#import "EMSProduct.h"
#import "NSMutableDictionary+EMSCore.h"

@interface EMSPredictInternal ()

@property(nonatomic, strong) PRERequestContext *requestContext;
@property(nonatomic, strong) EMSRequestManager *requestManager;

@end

@implementation EMSPredictInternal

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext
                        requestManager:(EMSRequestManager *)requestManager {
    if (self = [super init]) {
        _requestContext = requestContext;
        _requestManager = requestManager;
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

- (void)recommendProducts:(EMSProductsBlock)productsBlock {
    NSParameterAssert(productsBlock);
    EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:[NSString stringWithFormat:@"https://recommender.scarabresearch.com/merchants/%@/",
                                                           self.requestContext.merchantId]
                queryParameters:@{
                        @"f": @"f:SEARCH,l:2,o:0",
                        @"q": @"polo shirt"
                }];
                [builder setMethod:HTTPMethodGET];
            }
                                                   timestampProvider:self.requestContext.timestampProvider
                                                        uuidProvider:self.requestContext.uuidProvider];

    [_requestManager submitRequestModelNow:requestModel
                              successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                  NSDictionary *responseData = [response parsedBody];
                                  NSMutableArray *products = [NSMutableArray new];
                                  NSArray *items = responseData[@"features"][@"SEARCH"][@"items"];
                                  for (NSDictionary *item in items) {
                                      NSString *key = item[@"id"];
                                      NSMutableDictionary *productData = [responseData[@"products"][key] mutableCopy];
                                      EMSProduct *product = [EMSProduct makeWithBuilder:^(EMSProductBuilder *builder) {
                                          [builder setRequiredFieldsWithProductId:[productData takeValueForKey:@"item"]
                                                                            title:[productData takeValueForKey:@"title"]
                                                                          linkUrl:[[NSURL alloc] initWithString:[productData takeValueForKey:@"link"]]];

                                          [builder setCategoryPath:[productData takeValueForKey:@"category"]];
                                          [builder setAvailable:[productData takeValueForKey:@"available"]];
                                          [builder setMsrp:[productData takeValueForKey:@"msrp"]];
                                          [builder setPrice:[productData takeValueForKey:@"price"]];

                                          NSString *imageUrl = [productData takeValueForKey:@"image"];
                                          [builder setImageUrl:imageUrl ? [[NSURL alloc] initWithString:imageUrl] : nil];

                                          NSString *zoomImageUrl = [productData takeValueForKey:@"zoom_image"];
                                          [builder setZoomImageUrl:zoomImageUrl ? [[NSURL alloc] initWithString:zoomImageUrl] : nil];

                                          [builder setProductDescription:[productData takeValueForKey:@"description"]];
                                          [builder setAlbum:[productData takeValueForKey:@"album"]];
                                          [builder setActor:[productData takeValueForKey:@"actor"]];
                                          [builder setArtist:[productData takeValueForKey:@"artist"]];
                                          [builder setAuthor:[productData takeValueForKey:@"author"]];
                                          [builder setBrand:[productData takeValueForKey:@"brand"]];
                                          [builder setYear:[productData takeValueForKey:@"year"]];
                                          [builder setCustomFields:[NSDictionary dictionaryWithDictionary:productData]];
                                      }];
                                      [products addObject:product];
                                  }
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