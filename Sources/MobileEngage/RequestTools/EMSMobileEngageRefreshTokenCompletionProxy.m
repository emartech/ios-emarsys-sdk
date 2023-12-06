//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSMobileEngageRefreshTokenCompletionProxy.h"
#import "EMSResponseModel.h"
#import "EMSResponseModel+EMSCore.h"
#import "EMSContactTokenResponseHandler.h"
#import "EMSEndpoint.h"
#import "EMSStorage.h"

#define kEMSPushTokenKey @"EMSPushTokenKey"

@interface EMSMobileEngageRefreshTokenCompletionProxy()

@property(nonatomic, assign) NSInteger retryCount;
@property(nonatomic, strong) EMSResponseModel *originalResponseModel;

- (void)reset;

@end

@implementation EMSMobileEngageRefreshTokenCompletionProxy

- (instancetype)initWithCompletionProxy:(id <EMSRESTClientCompletionProxyProtocol>)completionProxy
                             restClient:(EMSRESTClient *)restClient
                         requestFactory:(EMSRequestFactory *)requestFactory
                 contactResponseHandler:(EMSContactTokenResponseHandler *)contactResponseHandler
                               endpoint:(EMSEndpoint *)endpoint
                                storage:(id<EMSStorageProtocol>)storage {
    NSParameterAssert(completionProxy);
    NSParameterAssert(restClient);
    NSParameterAssert(requestFactory);
    NSParameterAssert(contactResponseHandler);
    NSParameterAssert(endpoint);
    NSParameterAssert(storage);
    if (self = [super init]) {
        _completionProxy = completionProxy;
        _restClient = restClient;
        _requestFactory = requestFactory;
        _contactResponseHandler = contactResponseHandler;
        _endpoint = endpoint;
        _storage = storage;
    }
    return self;
}

- (EMSRESTClientCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    return ^(EMSRequestModel *requestModel, EMSResponseModel *responseModel, NSError *error) {
        if (weakSelf.retryCount >= 3 || (error && [weakSelf.endpoint isRefreshContactTokenUrl:requestModel.url])) {
            EMSRequestModel *request = weakSelf.originalRequestModel;
            EMSResponseModel *response = weakSelf.originalResponseModel;
            
            [weakSelf reset];
            [response setStatusCode:418];
            weakSelf.completionProxy.completionBlock(request, response, error);
        } else if (responseModel.statusCode == 401 && [weakSelf.endpoint isMobileEngageUrl:requestModel.url.absoluteString]) {
            [weakSelf.storage setData:nil
                               forKey:kEMSPushTokenKey];
            weakSelf.originalRequestModel = requestModel;
            weakSelf.originalResponseModel = responseModel;
            [weakSelf.restClient executeWithRequestModel:[weakSelf.requestFactory createRefreshTokenRequestModel]
                                     coreCompletionProxy:weakSelf];
        } else if (responseModel.isSuccess && [weakSelf.endpoint isRefreshContactTokenUrl:requestModel.url]) {
            [weakSelf.contactResponseHandler processResponse:responseModel];
            [NSThread sleepForTimeInterval:0.5f];
            weakSelf.retryCount += 1;
            [weakSelf.restClient executeWithRequestModel:weakSelf.originalRequestModel
                                     coreCompletionProxy:weakSelf];
        } else {
            [weakSelf reset];
            weakSelf.completionProxy.completionBlock(requestModel, responseModel, error);
        }
    };
}

- (void)reset {
    self.originalRequestModel = nil;
    self.originalResponseModel = nil;
    self.retryCount = 0;
}

@end
