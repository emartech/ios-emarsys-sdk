//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSContactTokenResponseHandler.h"
#import "MERequestContext.h"
#import "EMSEndpoint.h"

@implementation EMSContactTokenResponseHandler

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
    if ([response.requestModel.url.absoluteString hasPrefix:[self.endpoint clientServiceUrl]] && response.parsedBody && response.parsedBody[@"contactToken"]) {
        result = YES;
    }
    return result;
}

- (void)handleResponse:(EMSResponseModel *)response {
    [self.requestContext setContactToken:response.parsedBody[@"contactToken"]];
}

@end