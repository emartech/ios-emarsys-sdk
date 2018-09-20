//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSAbstractResponseHandler.h"

@implementation EMSAbstractResponseHandler

- (void)processResponse:(EMSResponseModel *)response {
    if([self shouldHandleResponse:response]){
        [self handleResponse:response];
    }
}

- (BOOL)shouldHandleResponse:(EMSResponseModel *)response {
    NSAssert(NO, @"implement me please");
    return NO;
}

- (void)handleResponse:(EMSResponseModel *)response {
    NSAssert(NO, @"implement me please");
}

@end