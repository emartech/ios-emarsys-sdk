//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSCompletionProxyFactory.h"
#import "EMSRefreshTokenCompletionProxy.h"

@interface EMSCompletionProxyFactory ()

@property(nonatomic, strong) EMSRESTClient *restClient;
@property(nonatomic, strong) EMSRequestFactory *requestFactory;

@end

@implementation EMSCompletionProxyFactory

- (instancetype)initWithRequestRepository:(id <EMSRequestModelRepositoryProtocol>)requestRepository
                           operationQueue:(NSOperationQueue *)operationQueue
                      defaultSuccessBlock:(CoreSuccessBlock)defaultSuccessBlock
                        defaultErrorBlock:(CoreErrorBlock)defaultErrorBlock
                               restClient:(EMSRESTClient *)restClient
                           requestFactory:(EMSRequestFactory *)requestFactory {
    NSParameterAssert(restClient);
    NSParameterAssert(requestFactory);
    if (self = [super initWithRequestRepository:requestRepository
                                 operationQueue:operationQueue
                            defaultSuccessBlock:defaultSuccessBlock
                              defaultErrorBlock:defaultErrorBlock]) {
        _restClient = restClient;
        _requestFactory = requestFactory;
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
                                                    contactResponseHandler:NULL];
}

@end