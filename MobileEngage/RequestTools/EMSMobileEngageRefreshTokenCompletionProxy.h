//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSRESTClientCompletionProxyProtocol.h"
#import "EMSRequestFactory.h"
#import "EMSRESTClient.h"

@class EMSRESTClient;
@class EMSRequestFactory;
@class EMSContactTokenResponseHandler;

@interface EMSMobileEngageRefreshTokenCompletionProxy : NSObject <EMSRESTClientCompletionProxyProtocol>

@property(nonatomic, readonly) id <EMSRESTClientCompletionProxyProtocol> completionProxy;
@property(nonatomic, readonly) EMSRESTClient *restClient;
@property(nonatomic, readonly) EMSRequestFactory *requestFactory;
@property(nonatomic, readonly) EMSContactTokenResponseHandler *contactResponseHandler;
@property(nonatomic, readonly) EMSEndpoint *endpoint;

@property(nonatomic, strong) EMSRequestModel *originalRequestModel;

- (instancetype)initWithCompletionProxy:(id <EMSRESTClientCompletionProxyProtocol>)completionProxy
                             restClient:(EMSRESTClient *)restClient
                         requestFactory:(EMSRequestFactory *)requestFactory
                 contactResponseHandler:(EMSContactTokenResponseHandler *)contactResponseHandler
                               endpoint:(EMSEndpoint *)endpoint;

@end
