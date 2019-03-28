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

@interface EMSRefreshTokenCompletionProxy : NSObject <EMSRESTClientCompletionProxyProtocol>

@property(nonatomic, readonly) id <EMSRESTClientCompletionProxyProtocol> completionProxy;
@property(nonatomic, readonly) EMSRESTClient *restClient;
@property(nonatomic, readonly) EMSRequestFactory *requestFactory;
@property(nonatomic, readonly) EMSContactTokenResponseHandler *contactResponseHandler;

@property(nonatomic, readonly) EMSRequestModel *originalRequestModel;

- (instancetype)initWithCompletionProxy:(id <EMSRESTClientCompletionProxyProtocol>)completionProxy
                             restClient:(EMSRESTClient *)restClient
                         requestFactory:(EMSRequestFactory *)requestFactory
                 contactResponseHandler:(EMSContactTokenResponseHandler *)contactResponseHandler;

@end