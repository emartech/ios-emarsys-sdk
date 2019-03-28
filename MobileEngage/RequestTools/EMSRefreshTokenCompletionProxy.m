//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMSRefreshTokenCompletionProxy.h"
#import "EMSRESTClient.h"
#import "EMSRequestFactory.h"

@implementation EMSRefreshTokenCompletionProxy

- (instancetype)initWithCompletionProxy:(id <EMSRESTClientCompletionProxyProtocol>)completionProxy
                             restClient:(EMSRESTClient *)restClient
                         requestFactory:(EMSRequestFactory *)requestFactory {
    if (self = [super init]) {
        _completionProxy = completionProxy;
    }
    return self;
}

- (EMSRESTClientCompletionBlock)completionBlock {
    return ^(EMSRequestModel *requestModel, EMSResponseModel *responseModel, NSError *error) {
    };
}

@end