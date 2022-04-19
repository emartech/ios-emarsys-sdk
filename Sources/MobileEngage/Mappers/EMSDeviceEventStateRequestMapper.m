//
// Copyright (c) 2022 Emarsys. All rights reserved.
//

#import "EMSDeviceEventStateRequestMapper.h"
#import "EMSEndpoint.h"
#import "EMSStorageProtocol.h"
#import "EMSRequestModel.h"
#import "MEExperimental.h"
#import "EMSInnerFeature.h"

@implementation EMSDeviceEventStateRequestMapper
- (instancetype)initWithEndpoint:(EMSEndpoint *)endpoint storage:(id <EMSStorageProtocol>)storage {
    if (self = [super init]) {
        _endpoint = endpoint;
        _storage = storage;
    }
    return self;
}

- (BOOL)shouldHandleWithRequestModel:(EMSRequestModel *)requestModel {
    NSString *url = requestModel.url.absoluteString;
    NSDictionary *des = [self.storage dictionaryForKey:kDeviceEventStateKey];
    return [MEExperimental isFeatureEnabled:EMSInnerFeature.eventServiceV4] &&
            ([self.endpoint isCustomEventUrl:url] || [self.endpoint isInlineInAppUrl:url]) &&
            des;
}

- (EMSRequestModel *)modelFromModel:(EMSRequestModel *)requestModel {
    NSMutableDictionary *mergedPayload = [NSMutableDictionary dictionaryWithDictionary:requestModel.payload];
    mergedPayload[@"deviceEventState"] = [self.storage dictionaryForKey:kDeviceEventStateKey];
    NSDictionary *payload = [NSDictionary dictionaryWithDictionary:mergedPayload];
    return [[EMSRequestModel alloc] initWithRequestId:requestModel.requestId
                                            timestamp:requestModel.timestamp
                                               expiry:requestModel.ttl
                                                  url:requestModel.url
                                               method:requestModel.method
                                              payload:payload
                                              headers:requestModel.headers
                                               extras:requestModel.extras];
}

@end