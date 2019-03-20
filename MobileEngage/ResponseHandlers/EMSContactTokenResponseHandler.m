//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSContactTokenResponseHandler.h"
#import "MERequestContext.h"
#import "MEEndpoints.h"

@implementation EMSContactTokenResponseHandler

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext {
    NSParameterAssert(requestContext);
    if (self = [super init]) {
        _requestContext = requestContext;
    }
    return self;
}

- (BOOL)shouldHandleResponse:(EMSResponseModel *)response {
    BOOL result = NO;
    if ([response.requestModel.url.absoluteString hasPrefix:CLIENT_SERVICE_URL] && response.parsedBody && response.parsedBody[@"contactToken"]) {
        result = YES;
    }
    return result;
}

- (void)handleResponse:(EMSResponseModel *)response {
    [self.requestContext setContactToken:response.parsedBody[@"contactToken"]];
}

@end