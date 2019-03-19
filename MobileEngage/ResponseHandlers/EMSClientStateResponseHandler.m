//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSClientStateResponseHandler.h"
#import "MEEndpoints.h"

@implementation EMSClientStateResponseHandler

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext {
    NSParameterAssert(requestContext);
    if (self = [super init]) {
        _requestContext = requestContext;
    }
    return self;
}

- (BOOL)shouldHandleResponse:(EMSResponseModel *)response {
    BOOL result = NO;
    if ([response.requestModel.url.absoluteString hasPrefix:CLIENT_SERVICE_URL] && [response.headers.allKeys containsObject:CLIENT_STATE]) {
        result = YES;
    }
    return result;
}

- (void)handleResponse:(EMSResponseModel *)response {
    NSString *clientState = response.headers[CLIENT_STATE];
    [self.requestContext setClientState:clientState];
}


@end