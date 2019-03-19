//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSV3Mapper.h"
#import "EMSRequestModel.h"
#import "NSDate+EMSCore.h"
#import "EMSDeviceInfo.h"
#import "MEEndpoints.h"

@interface EMSV3Mapper ()

@property(nonatomic, strong) MERequestContext *requestContext;

@end

@implementation EMSV3Mapper

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext {
    NSParameterAssert(requestContext);
    if (self = [super init]) {
        _requestContext = requestContext;
    }
    return self;
}

- (BOOL)shouldHandleWithRequestModel:(EMSRequestModel *)requestModel {
    return [requestModel.url.absoluteString hasPrefix:CLIENT_SERVICE_URL];
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
    mergedHeaders[@"X-Contact-Token"] = self.requestContext.contactToken;
    NSDictionary *headers = [NSDictionary dictionaryWithDictionary:mergedHeaders];
    return headers;
}

- (NSString *)requestOrder {
    NSDate *timestamp = [self.requestContext.timestampProvider provideTimestamp];
    return [[timestamp numberValueInMillis] stringValue];
}

@end