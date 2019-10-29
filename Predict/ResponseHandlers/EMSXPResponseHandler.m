//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSXPResponseHandler.h"
#import "PRERequestContext.h"
#import "EMSPredictInternal.h"

#define COOKIE_KEY_XP @"xp"

@implementation EMSXPResponseHandler

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext {
    NSParameterAssert(requestContext);
    if (self = [super init]) {
        _requestContext = requestContext;
    }
    return self;
}

- (BOOL)shouldHandleResponse:(EMSResponseModel *)response {
    return [response.requestModel.url.absoluteString hasPrefix:PREDICT_BASE_URL] && response.cookies[COOKIE_KEY_XP] != nil;
}

- (void)handleResponse:(EMSResponseModel *)response {
    [self.requestContext setXp:response.cookies[COOKIE_KEY_XP].value];
}

@end