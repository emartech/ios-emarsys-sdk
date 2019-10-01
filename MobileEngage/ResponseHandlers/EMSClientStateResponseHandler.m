//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSClientStateResponseHandler.h"
#import "MEEndpoints.h"
#import "NSDictionary+EMSCore.h"

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
    if ([response.requestModel.url.absoluteString hasPrefix:CLIENT_SERVICE_URL] && [response.headers valueForInsensitiveKey:CLIENT_STATE]) {
        result = YES;
    }
    return result;
}

- (void)handleResponse:(EMSResponseModel *)response {
    NSString *clientState = [response.headers valueForInsensitiveKey:CLIENT_STATE];
    [self.requestContext setClientState:clientState];
}

@end