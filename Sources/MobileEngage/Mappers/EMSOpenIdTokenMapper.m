//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import "EMSOpenIdTokenMapper.h"
#import "EMSEndpoint.h"
#import "MERequestContext.h"
#import "EMSRequestModel.h"

@implementation EMSOpenIdTokenMapper

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
    return [self.endpoint isMobileEngageUrl:url] && [url containsString:@"/client/contact"] && self.requestContext.openIdToken;
}

- (EMSRequestModel *)modelFromModel:(EMSRequestModel *)requestModel {
    return [[EMSRequestModel alloc] initWithRequestId:requestModel.requestId
                                            timestamp:requestModel.timestamp
                                               expiry:requestModel.ttl
                                                  url:requestModel.url
                                               method:requestModel.method
                                              payload:[self extendPayload:requestModel.payload]
                                              headers:requestModel.headers
                                               extras:requestModel.extras];
}

- (NSDictionary *)extendPayload:(NSDictionary *)payload {
    NSMutableDictionary *mergedPayload = [NSMutableDictionary dictionaryWithDictionary:payload];
    mergedPayload[@"openIdToken"] = self.requestContext.openIdToken;
    NSDictionary *result = [NSDictionary dictionaryWithDictionary:mergedPayload];
    return result;
}

@end
