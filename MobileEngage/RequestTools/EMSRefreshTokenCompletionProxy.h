//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSRESTClientCompletionProxyProtocol.h"

@class EMSRESTClient;
@class EMSRequestFactory;

@interface EMSRefreshTokenCompletionProxy : NSObject <EMSRESTClientCompletionProxyProtocol>

@property(nonatomic, strong) id <EMSRESTClientCompletionProxyProtocol> completionProxy;

- (instancetype)initWithCompletionProxy:(id <EMSRESTClientCompletionProxyProtocol>)completionProxy
                             restClient:(EMSRESTClient *)restClient
                         requestFactory:(EMSRequestFactory *)requestFactory;

@end