//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSMerchantIdMapper.h"
#import "PRERequestContext.h"
#import "EMSRequestModel.h"
#import "EMSEndpoint.h"

@interface EMSMerchantIdMapper()

- (BOOL)isNotSetContactAndNotRefreshContactTokenMobileEngageRequest:(EMSRequestModel *)requestModel;

@end

@implementation EMSMerchantIdMapper

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext endpoint:(EMSEndpoint *)endpoint {
    NSParameterAssert(requestContext);
    NSParameterAssert(endpoint);
    if (self = [super init]) {
        _requestContext = requestContext;
        _endpoint = endpoint;
    }
    return self;
}

- (BOOL)shouldHandleWithRequestModel:(EMSRequestModel *)requestModel {
    return ([self isSetContactOrRefreshContactTokenMobileEngageRequest:requestModel] || [self isPredictOnlySetContactRequest:requestModel]) && self.requestContext.merchantId;
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
    mergedHeaders[@"X-Merchant-Id"] = self.requestContext.merchantId;
    NSDictionary *headers = [NSDictionary dictionaryWithDictionary:mergedHeaders];
    return headers;
}


- (BOOL)isSetContactOrRefreshContactTokenMobileEngageRequest:(EMSRequestModel *)requestModel {
    NSString *url = requestModel.url.absoluteString;
    NSString *path = requestModel.url.path;
    return [self.endpoint isMobileEngageUrl:url] &&
    ([path hasSuffix:@"/client/contact-token"] || [path hasSuffix:@"/client/contact"]);
}

- (BOOL)isPredictOnlySetContactRequest:(EMSRequestModel *)requestModel {
    NSString *url = requestModel.url.absoluteString;
    NSString *path = requestModel.url.path;
    return [self.endpoint isMobileEngageUrl:url] && [path hasSuffix:@"/contact-token"] && ![path containsString:@"apps"];
}

@end
