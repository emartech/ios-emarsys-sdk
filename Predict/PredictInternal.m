//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "PredictInternal.h"
#import "PRERequestContext.h"
#import "EMSRequestManager.h"

@interface PredictInternal ()

@property(nonatomic, strong) PRERequestContext *requestContext;
@property(nonatomic, strong) EMSRequestManager *requestManager;

@end

@implementation PredictInternal

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext requestManager:(EMSRequestManager *)requestManager {
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
}

@end