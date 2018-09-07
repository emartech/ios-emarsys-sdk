//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "PredictInternal.h"
#import "PRERequestContext.h"

@interface PredictInternal ()

@property(nonatomic, strong) PRERequestContext *requestContext;

@end

@implementation PredictInternal

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext {
    self = [super init];
    if (self) {
        _requestContext = requestContext;
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

@end