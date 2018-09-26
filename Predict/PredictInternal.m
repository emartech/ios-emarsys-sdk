//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "PredictInternal.h"
#import "PRERequestContext.h"
#import "EMSRequestManager.h"
#import "EMSShard.h"
#import "EMSCartItemUtils.h"

@interface PredictInternal ()

@property(nonatomic, strong) PRERequestContext *requestContext;
@property(nonatomic, strong) EMSRequestManager *requestManager;

@end

@implementation PredictInternal

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext
                        requestManager:(EMSRequestManager *)requestManager {
    self = [super init];
    if (self) {
        _requestContext = requestContext;
        _requestManager = requestManager;
    }
    return self;
}

- (void)setCustomerWithId:(NSString *)customerId {
    NSParameterAssert(customerId);
    [self.requestContext setCustomerId:customerId];
}

- (void)clearCustomer {
    [self.requestContext setCustomerId:nil];
    [self.requestContext setVisitorId:nil];
}

- (void)trackCategoryViewWithCategoryPath:(NSString *)categoryPath {
    NSParameterAssert(categoryPath);
    EMSShard *shard = [EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                [builder setType:@"predict_item_category_view"];
                [builder payloadEntryWithKey:@"vc"
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
                [builder payloadEntryWithKey:@"v" value:[NSString stringWithFormat:@"i:%@", itemId]];
            }
                              timestampProvider:[self.requestContext timestampProvider]
                                   uuidProvider:[self.requestContext uuidProvider]];

    [self.requestManager submitShard:shard];
}

- (void)trackCartWithCartItems:(NSArray<id <EMSCartItemProtocol>> *)cartItems {
    NSParameterAssert(cartItems);

    [self.requestManager submitShard:[EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                [builder setType:@"predict_cart"];
                [builder payloadEntryWithKey:@"cv" value:@"1"];
                [builder payloadEntryWithKey:@"ca" value:[EMSCartItemUtils queryParamFromCartItems:cartItems]];
            }
                                             timestampProvider:self.requestContext.timestampProvider
                                                  uuidProvider:self.requestContext.uuidProvider]];

}

- (void)trackSearchWithSearchTerm:(NSString *)searchTerm {
    NSParameterAssert(searchTerm);

    EMSShard *shard = [EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                [builder setType:@"predict_search_term"];
                [builder payloadEntryWithKey:@"q" value:searchTerm];
            }
                              timestampProvider:[self.requestContext timestampProvider]
                                   uuidProvider:[self.requestContext uuidProvider]];

    [self.requestManager submitShard:shard];
}

@end