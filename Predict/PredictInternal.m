//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "PredictInternal.h"
#import "PRERequestContext.h"
#import "EMSRequestManager.h"
#import "EMSShard.h"

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

- (void)trackCategoryViewWithCategoryPath:(NSString *)categoryPath {
    NSParameterAssert(categoryPath);
}

- (void)trackItemViewWithItemId:(NSString *)itemId {
    NSParameterAssert(itemId);
    EMSShard * shard = [EMSShard makeWithBuilder:^(EMSShardBuilder *builder){
        [builder setType:@"predict_item_view"];
        [builder payloadEntryWithKey:@"v" value:[NSString stringWithFormat:@"i:%@", itemId]];
    }
                               timestampProvider:[self.requestContext timestampProvider]
                                    uuidProvider:[self.requestContext uuidProvider]];

    [self.requestManager submitShard:shard];
}

@end