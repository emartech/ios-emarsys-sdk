//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSMobileEngageRefreshTokenCompletionProxy.h"
#import "EMSResponseModel.h"
#import "EMSResponseModel+EMSCore.h"
#import "EMSContactTokenResponseHandler.h"
#import "EMSEndpoint.h"

@implementation EMSMobileEngageRefreshTokenCompletionProxy

- (instancetype)initWithCompletionProxy:(id <EMSRESTClientCompletionProxyProtocol>)completionProxy
                             restClient:(EMSRESTClient *)restClient
                         requestFactory:(EMSRequestFactory *)requestFactory
                 contactResponseHandler:(EMSContactTokenResponseHandler *)contactResponseHandler
                               endpoint:(EMSEndpoint *)endpoint {
    NSParameterAssert(completionProxy);
    NSParameterAssert(restClient);
    NSParameterAssert(requestFactory);
    NSParameterAssert(contactResponseHandler);
    NSParameterAssert(endpoint);
    if (self = [super init]) {
        _completionProxy = completionProxy;
        _restClient = restClient;
        _requestFactory = requestFactory;
        _contactResponseHandler = contactResponseHandler;
        _endpoint = endpoint;
    }
    return self;
}

- (EMSRESTClientCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    return ^(EMSRequestModel *requestModel, EMSResponseModel *responseModel, NSError *error) {
        if (responseModel.statusCode == 401 && [self.endpoint isV3url:requestModel.url.absoluteString]) {
            weakSelf.originalRequestModel = requestModel;
            [weakSelf.restClient executeWithRequestModel:[weakSelf.requestFactory createRefreshTokenRequestModel]
                                     coreCompletionProxy:weakSelf];
        } else if (responseModel.isSuccess && weakSelf.originalRequestModel) {
            [weakSelf.contactResponseHandler processResponse:responseModel];
            [weakSelf.restClient executeWithRequestModel:weakSelf.originalRequestModel
                                     coreCompletionProxy:weakSelf];
            weakSelf.originalRequestModel = nil;
        } else {
            weakSelf.completionProxy.completionBlock(requestModel, responseModel, error);
        }
    };
}

@end
