//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSPredictRequestModelBuilder.h"
#import "PRERequestContext.h"
#import "EMSRequestModel.h"
#import "EMSDeviceInfo.h"
#import "EMSLogic.h"
#import "EMSCartItemProtocol.h"
#import "EMSRecommendationFilterProtocol.h"

@interface EMSPredictRequestModelBuilder ()

@property(nonatomic, strong) PRERequestContext *requestContext;
@property(nonatomic, strong) EMSLogic *logic;
@property(nonatomic, strong) NSString *lastSearchTerm;
@property(nonatomic, strong) NSArray<id <EMSCartItemProtocol>> *lastCartItems;
@property(nonatomic, strong) NSString *lastViewItemId;
@property(nonatomic, strong) NSString *lastCategoryPath;
@property(nonatomic, strong) NSNumber *limit;
@property(nonatomic, strong) NSArray<id <EMSRecommendationFilterProtocol>> *filter;

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

- (instancetype)withLimit:(nullable NSNumber *)limit {
    _limit = limit;
    return self;
}

- (instancetype)withFilter:(nullable NSArray<id <EMSRecommendationFilterProtocol>> *)filter {
    _filter = filter;
    return self;
}

- (EMSRequestModel *)build {
    EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            if (self.logic) {
                [self setupLimit];
                [builder setUrl:PREDICT_URL(self.requestContext.merchantId)
                queryParameters:[NSDictionary dictionaryWithDictionary:[self createQueryParameters]]];
            } else {
                [builder setUrl:PREDICT_URL(self.requestContext.merchantId)];
            }

            [builder setMethod:HTTPMethodGET];

            NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
            mutableHeaders[@"User-Agent"] = [self createUserAgent];
            if (self.requestContext.xp) {
                mutableHeaders[@"Cookie"] = [NSString stringWithFormat:@"xp=%@", self.requestContext.xp];
            }
            [builder setHeaders:[NSDictionary dictionaryWithDictionary:mutableHeaders]];
        }                                          timestampProvider:self.requestContext.timestampProvider
                                                        uuidProvider:self.requestContext.uuidProvider];
    return requestModel;
}

- (NSString *)createUserAgent {
    return [NSString stringWithFormat:@"EmarsysSDK|osversion:%@|platform:%@",
                                      self.requestContext.deviceInfo.osVersion,
                                      self.requestContext.deviceInfo.systemName];
}

- (void)setupLimit {
    self.limit = self.limit && self.limit.intValue >= 1 ? self.limit : DEFAULT_LIMIT;
}

- (NSMutableDictionary *)createQueryParameters {
    NSMutableDictionary *logicData = [self.logic.data mutableCopy];
    NSArray<NSString *> *const variants = self.logic.variants;

    if (variants) {
        NSMutableArray *logicNames = [NSMutableArray array];
        for (NSString *variant in variants) {
            [logicNames addObject:[NSString stringWithFormat:@"f:%@_%@,l:%@,o:0",
                                                             self.logic.logic,
                                                             variant,
                                                             self.limit]];
        }
        logicData[@"f"] = [logicNames componentsJoinedByString:@"|"];
    } else {
        logicData[@"f"] = [NSString stringWithFormat:@"f:%@,l:%@,o:0", self.logic.logic, self.limit];
    }
    if (self.filter) {
        logicData[@"ex"] = [self filterQueryValue];
    }
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
    return logicData;
}

- (NSString *)filterQueryValue {
    NSMutableArray *mutableFilterValues = [NSMutableArray array];
    for (id <EMSRecommendationFilterProtocol> recommendationFilter in self.filter) {
        NSMutableDictionary *mutableFilterValue = [NSMutableDictionary dictionary];
        mutableFilterValue[@"f"] = recommendationFilter.field;
        mutableFilterValue[@"r"] = recommendationFilter.comparison;
        mutableFilterValue[@"v"] = [recommendationFilter.expectations componentsJoinedByString:@"|"];
        mutableFilterValue[@"n"] = [recommendationFilter.type isEqualToString:@"EXCLUDE"] ? @NO : @YES;
        [mutableFilterValues addObject:[NSDictionary dictionaryWithDictionary:mutableFilterValue]];
    }
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[NSArray arrayWithArray:mutableFilterValues]
                                                                          options:NSJSONWritingPrettyPrinted
                                                                            error:nil]
                                 encoding:NSUTF8StringEncoding];
}

@end