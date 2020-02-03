//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSVisitorIdResponseHandler.h"
#import "EMSPredictInternal.h"
#import "EMSEndpoint.h"

#define COOKIE_KEY_CDV @"cdv"

@implementation EMSVisitorIdResponseHandler

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext endpoint:(EMSEndpoint *)endpoint {
    NSParameterAssert(requestContext);
    NSParameterAssert(endpoint);
    if (self = [super init]) {
        _requestContext = requestContext;
        _endpoint = endpoint;
    }
    return self;
}

- (BOOL)shouldHandleResponse:(EMSResponseModel *)response {
    return [response.requestModel.url.absoluteString hasPrefix:[self.endpoint predictUrl]] && response.cookies[COOKIE_KEY_CDV] != nil;
}

- (void)handleResponse:(EMSResponseModel *)response {
    [self.requestContext setVisitorId:response.cookies[COOKIE_KEY_CDV].value];
}

@end