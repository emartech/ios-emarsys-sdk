//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSRESTClientCompletionProxyFactory.h"
#import "EMSRequestModelRepositoryProtocol.h"
#import "EMSRESTClientCompletionProxyProtocol.h"
#import "EMSWorkerProtocol.h"
#import "EMSCoreCompletionHandler.h"
#import "EMSCoreCompletionHandlerMiddleware.h"

@interface EMSRESTClientCompletionProxyFactory ()

@property(nonatomic, strong) CoreSuccessBlock defaultSuccessBlock;
@property(nonatomic, strong) CoreErrorBlock defaultErrorBlock;
@property(nonatomic, strong) id <EMSRequestModelRepositoryProtocol> requestRepository;
@property(nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation EMSRESTClientCompletionProxyFactory

- (instancetype)initWithRequestRepository:(id <EMSRequestModelRepositoryProtocol>)requestRepository
                           operationQueue:(NSOperationQueue *)operationQueue
                      defaultSuccessBlock:(CoreSuccessBlock)defaultSuccessBlock
                        defaultErrorBlock:(CoreErrorBlock)defaultErrorBlock {
    NSParameterAssert(requestRepository);
    NSParameterAssert(operationQueue);
    NSParameterAssert(defaultSuccessBlock);
    NSParameterAssert(defaultErrorBlock);
    if (self = [super init]) {
        _defaultSuccessBlock = defaultSuccessBlock;
        _defaultErrorBlock = defaultErrorBlock;
        _requestRepository = requestRepository;
        _operationQueue = operationQueue;
    }
    return self;
}

 - (id <EMSRESTClientCompletionProxyProtocol>)createWithWorker:(id <EMSWorkerProtocol>)worker
                                                 successBlock:(CoreSuccessBlock)successBlock
                                                   errorBlock:(CoreErrorBlock)errorBlock {
    NSParameterAssert((successBlock != nil) == (errorBlock != nil));
    id <EMSRESTClientCompletionProxyProtocol> result = [[EMSCoreCompletionHandler alloc] initWithSuccessBlock:self.defaultSuccessBlock
                                                                                                   errorBlock:self.defaultErrorBlock];
    if (successBlock && errorBlock) {
        result = [[EMSCoreCompletionHandler alloc] initWithSuccessBlock:successBlock
                                                             errorBlock:errorBlock];
    }
    if (worker) {
        result = [[EMSCoreCompletionHandlerMiddleware alloc] initWithCoreCompletionHandler:result
                                                                                    worker:worker
                                                                         requestRepository:self.requestRepository
                                                                            operationQueue:self.operationQueue];
    }
    return result;
}

@end