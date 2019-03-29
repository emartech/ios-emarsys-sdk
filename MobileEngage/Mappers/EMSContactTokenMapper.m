//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSContactTokenMapper.h"
#import "MERequestContext.h"
#import "EMSRequestModel.h"
#import "MEEndpoints.h"

@implementation EMSContactTokenMapper

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext {
    NSParameterAssert(requestContext);
    if (self = [super init]) {
        _requestContext = requestContext;
    }
    return self;
}

- (BOOL)shouldHandleWithRequestModel:(EMSRequestModel *)requestModel {
    NSString *url = requestModel.url.absoluteString;
    return ![url hasSuffix:@"/client/contact-token"] &&
        ([requestModel.url.absoluteString hasPrefix:CLIENT_SERVICE_URL] || [requestModel.url.absoluteString hasPrefix:EVENT_SERVICE_URL]);
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
    mergedHeaders[@"X-Contact-Token"] = self.requestContext.contactToken;
    NSDictionary *headers = [NSDictionary dictionaryWithDictionary:mergedHeaders];
    return headers;
}


@end