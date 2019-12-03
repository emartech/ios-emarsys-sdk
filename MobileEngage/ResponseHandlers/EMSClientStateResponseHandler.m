//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSClientStateResponseHandler.h"
#import "EMSEndpoint.h"
#import "NSDictionary+EMSCore.h"

@implementation EMSClientStateResponseHandler

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

- (BOOL)shouldHandleResponse:(EMSResponseModel *)response {
    BOOL result = NO;
    if ([response.requestModel.url.absoluteString hasPrefix:[self.endpoint clientServiceUrl]] && [response.headers valueForInsensitiveKey:CLIENT_STATE]) {
        result = YES;
    }
    return result;
}

- (void)handleResponse:(EMSResponseModel *)response {
    NSString *clientState = [response.headers valueForInsensitiveKey:CLIENT_STATE];
    [self.requestContext setClientState:clientState];
}

@end