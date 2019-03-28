//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSCompletionProxyFactory.h"
#import "EMSRefreshTokenCompletionProxy.h"
#import "EMSContactTokenResponseHandler.h"

@interface EMSCompletionProxyFactory ()

@property(nonatomic, strong) EMSRESTClient *restClient;
@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) EMSContactTokenResponseHandler *contactResponseHandler;

@end

@implementation EMSCompletionProxyFactory

- (instancetype)initWithRequestRepository:(id <EMSRequestModelRepositoryProtocol>)requestRepository
                           operationQueue:(NSOperationQueue *)operationQueue
                      defaultSuccessBlock:(CoreSuccessBlock)defaultSuccessBlock
                        defaultErrorBlock:(CoreErrorBlock)defaultErrorBlock
                               restClient:(EMSRESTClient *)restClient
                           requestFactory:(EMSRequestFactory *)requestFactory
                   contactResponseHandler:(EMSContactTokenResponseHandler *)contactResponseHandler {
    NSParameterAssert(restClient);
    NSParameterAssert(requestFactory);
    NSParameterAssert(contactResponseHandler);
    if (self = [super initWithRequestRepository:requestRepository
                                 operationQueue:operationQueue
                            defaultSuccessBlock:defaultSuccessBlock
                              defaultErrorBlock:defaultErrorBlock]) {
        _restClient = restClient;
        _requestFactory = requestFactory;
        _contactResponseHandler = contactResponseHandler;
    }
    return self;
}


- (id <EMSRESTClientCompletionProxyProtocol>)createWithWorker:(id <EMSWorkerProtocol>)worker
                                                 successBlock:(CoreSuccessBlock)successBlock
                                                   errorBlock:(CoreErrorBlock)errorBlock {
    id <EMSRESTClientCompletionProxyProtocol> proxy = [super createWithWorker:worker
                                                                 successBlock:successBlock
                                                                   errorBlock:errorBlock];
    return [[EMSRefreshTokenCompletionProxy alloc] initWithCompletionProxy:proxy
                                                                restClient:self.restClient
                                                            requestFactory:self.requestFactory
                                                    contactResponseHandler:self.contactResponseHandler];
}

@end