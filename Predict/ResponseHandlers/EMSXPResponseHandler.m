//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSXPResponseHandler.h"
#import "PRERequestContext.h"
#import "EMSPredictInternal.h"
#import "EMSEndpoint.h"

#define COOKIE_KEY_XP @"xp"

@implementation EMSXPResponseHandler

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext
                              endpoint:(EMSEndpoint *)endpoint {
    NSParameterAssert(requestContext);
    NSParameterAssert(endpoint);
    if (self = [super init]) {
        _requestContext = requestContext;
        _endpoint = endpoint;
    }
    return self;
}

- (BOOL)shouldHandleResponse:(EMSResponseModel *)response {
    return [response.requestModel.url.absoluteString hasPrefix:[self.endpoint predictUrl]] && response.cookies[COOKIE_KEY_XP] != nil;
}

- (void)handleResponse:(EMSResponseModel *)response {
    [self.requestContext setXp:response.cookies[COOKIE_KEY_XP].value];
}

@end