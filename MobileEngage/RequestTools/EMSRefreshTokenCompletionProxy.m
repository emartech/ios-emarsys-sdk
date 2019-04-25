//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSRefreshTokenCompletionProxy.h"
#import "EMSResponseModel.h"
#import "EMSResponseModel+EMSCore.h"
#import "EMSContactTokenResponseHandler.h"

@implementation EMSRefreshTokenCompletionProxy

- (instancetype)initWithCompletionProxy:(id <EMSRESTClientCompletionProxyProtocol>)completionProxy
                             restClient:(EMSRESTClient *)restClient
                         requestFactory:(EMSRequestFactory *)requestFactory
                 contactResponseHandler:(EMSContactTokenResponseHandler *)contactResponseHandler {
    NSParameterAssert(completionProxy);
    NSParameterAssert(restClient);
    NSParameterAssert(requestFactory);
    NSParameterAssert(contactResponseHandler);
    if (self = [super init]) {
        _completionProxy = completionProxy;
        _restClient = restClient;
        _requestFactory = requestFactory;
        _contactResponseHandler = contactResponseHandler;
    }
    return self;
}

- (EMSRESTClientCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    return ^(EMSRequestModel *requestModel, EMSResponseModel *responseModel, NSError *error) {
        if (responseModel.statusCode == 401) {
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
