//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import "EMSIdTokenMapper.h"
#import "EMSEndpoint.h"
#import "MERequestContext.h"
#import "EMSRequestModel.h"

@implementation EMSIdTokenMapper

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
    NSString *url = requestModel.url.absoluteString;
    return [self.endpoint isMobileEngageUrl:url] && [url hasSuffix:@"/client/contact"];
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
    mergedHeaders[@"X-Open-Id"] = self.requestContext.idToken;
    NSDictionary *headers = [NSDictionary dictionaryWithDictionary:mergedHeaders];
    return headers;
}

@end