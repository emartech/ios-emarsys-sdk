//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSContactTokenMapper.h"
#import "MERequestContext.h"
#import "EMSRequestModel.h"
#import "EMSEndpoint.h"

@interface EMSContactTokenMapper()

- (BOOL)isNotSetContactAndNotRefreshContactTokenMobileEngageRequest:(EMSRequestModel *)requestModel;

@end

@implementation EMSContactTokenMapper

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext endpoint:(EMSEndpoint *)endpoint {
    NSParameterAssert(requestContext);
    NSParameterAssert(endpoint);
    if (self = [super init]) {
        _requestContext = requestContext;
        _endpoint = endpoint;
    }
    return self;
}

- (BOOL)shouldHandleWithRequestModel:(EMSRequestModel *)requestModel {
    return ([self isNotSetContactAndNotRefreshContactTokenMobileEngageRequest:requestModel] || [self isPredictRequest:requestModel]) && self.requestContext.contactToken;
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


- (BOOL)isNotSetContactAndNotRefreshContactTokenMobileEngageRequest:(EMSRequestModel *)requestModel {
    NSString *url = requestModel.url.absoluteString;
    return [self.endpoint isMobileEngageUrl:url] &&
    ![url hasSuffix:@"/contact-token"] &&
    ![url hasSuffix:@"/client/contact"];
}

- (BOOL)isPredictRequest:(EMSRequestModel *)requestModel {
    NSString *url = requestModel.url.absoluteString;
    return [url hasPrefix:[self.endpoint predictUrl]];
}

@end
