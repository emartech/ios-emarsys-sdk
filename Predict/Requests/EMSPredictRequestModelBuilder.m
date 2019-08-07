//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSPredictRequestModelBuilder.h"
#import "PRERequestContext.h"
#import "EMSRequestModel.h"
#import "EMSDeviceInfo.h"
#import "EMSLogic.h"
#import "EMSCartItemProtocol.h"

@interface EMSPredictRequestModelBuilder ()

@property(nonatomic, strong) PRERequestContext *requestContext;
@property(nonatomic, strong) EMSLogic *logic;
@property(nonatomic, strong) NSString *lastSearchTerm;
@property(nonatomic, strong) NSArray<id <EMSCartItemProtocol>> *lastCartItems;
@property(nonatomic, strong) NSString *lastViewItemId;
@property(nonatomic, strong) NSString *lastCategoryPath;

@end

@implementation EMSPredictRequestModelBuilder

- (instancetype)initWithContext:(PRERequestContext *)requestContext {
    NSParameterAssert(requestContext);
    if (self = [super init]) {
        _requestContext = requestContext;
    }
    return self;
}

- (instancetype)withLogic:(EMSLogic *)logic {
    _logic = logic;
    return self;
}

- (instancetype)withLastSearchTerm:(NSString *)searchTerm {
    _lastSearchTerm = searchTerm;
    return self;
}

- (instancetype)withLastCartItems:(NSArray<id <EMSCartItemProtocol>> *)cartItems {
    _lastCartItems = cartItems;
    return self;
}

- (instancetype)withLastViewItemId:(NSString *)viewItemId {
    _lastViewItemId = viewItemId;
    return self;
}

- (instancetype)withLastCategoryPath:(NSString *)categoryPath {
    _lastCategoryPath = categoryPath;
    return self;
}

- (EMSRequestModel *)build {
    EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            if (self.logic) {
                NSMutableDictionary *logicData = [self.logic.data mutableCopy];
                logicData[@"f"] = [NSString stringWithFormat:@"f:%@,l:2,o:0", self.logic.logic];
                if (!self.logic.data || [self.logic.data count] == 0) {
                    if ([self.logic.logic isEqualToString:@"SEARCH"]) {
                        [logicData addEntriesFromDictionary:[EMSLogic searchWithSearchTerm:self.lastSearchTerm].data];
                    } else if ([self.logic.logic isEqualToString:@"CART"]) {
                        [logicData addEntriesFromDictionary:[EMSLogic cartWithCartItems:self.lastCartItems].data];
                    } else if ([self.logic.logic isEqualToString:@"RELATED"] || [self.logic.logic isEqualToString:@"ALSO_BOUGHT"]) {
                        [logicData addEntriesFromDictionary:[EMSLogic relatedWithViewItemId:self.lastViewItemId].data];
                    } else if ([self.logic.logic isEqualToString:@"CATEGORY"] || [self.logic.logic isEqualToString:@"POPULAR"]) {
                        [logicData addEntriesFromDictionary:[EMSLogic categoryWithCategoryPath:self.lastCategoryPath].data];
                    }
                }
                [builder setUrl:PREDICT_URL(self.requestContext.merchantId)
                queryParameters:[NSDictionary dictionaryWithDictionary:logicData]];
            } else {
                [builder setUrl:PREDICT_URL(self.requestContext.merchantId)];
            }

            [builder setMethod:HTTPMethodGET];
            [builder setHeaders:@{@"User-Agent": [NSString stringWithFormat:@"EmarsysSDK|osversion:%@|platform:%@",
                                                                            self.requestContext.deviceInfo.osVersion,
                                                                            self.requestContext.deviceInfo.systemName]}];
        }                                          timestampProvider:self.requestContext.timestampProvider
                                                        uuidProvider:self.requestContext.uuidProvider];
    return requestModel;
}

@end