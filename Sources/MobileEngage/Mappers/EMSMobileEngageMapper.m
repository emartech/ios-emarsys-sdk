//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSMobileEngageMapper.h"
#import "EMSRequestModel.h"
#import "NSDate+EMSCore.h"
#import "EMSDeviceInfo.h"
#import "EMSEndpoint.h"

@interface EMSMobileEngageMapper ()

@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) EMSEndpoint *endpoint;

@end

@implementation EMSMobileEngageMapper

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext
                              endpoint:(EMSEndpoint *)endpoint {
    NSParameterAssert(requestContext);
    NSParameterAssert(endpoint);
    if (self = [super init]) {
        _requestContext = requestContext;
        _endpoint = endpoint;
    }
    return self;
}

- (BOOL)shouldHandleWithRequestModel:(EMSRequestModel *)requestModel {
    return [self.endpoint isMobileEngageUrl:requestModel.url.absoluteString];
}

- (EMSRequestModel *)modelFromModel:(EMSRequestModel *)requestModel {
    return [[EMSRequestModel alloc] initWithRequestId:requestModel.requestId
                                            timestamp:requestModel.timestamp
                                               expiry:requestModel.ttl
                                                  url:requestModel.url
                                               method:requestModel.method
                                              payload:requestModel.payload
                                              headers:[self headers:requestModel]
                                               extras:requestModel.extras];
}

- (NSDictionary *)headers:(EMSRequestModel *)requestModel {
    NSMutableDictionary *mergedHeaders = [NSMutableDictionary dictionaryWithDictionary:requestModel.headers];
    mergedHeaders[@"X-Client-State"] = self.requestContext.clientState;
    mergedHeaders[@"X-Request-Order"] = [self requestOrder];
    mergedHeaders[@"X-Client-Id"] = [self.requestContext.deviceInfo hardwareId];
    NSDictionary *headers = [NSDictionary dictionaryWithDictionary:mergedHeaders];
    return headers;
}

- (NSString *)requestOrder {
    NSDate *timestamp = [self.requestContext.timestampProvider provideTimestamp];
    return [[timestamp numberValueInMillis] stringValue];
}

@end