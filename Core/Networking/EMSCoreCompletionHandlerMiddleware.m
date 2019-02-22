//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSCoreCompletionHandlerMiddleware.h"
#import "EMSWorkerProtocol.h"
#import "EMSRequestModelRepositoryProtocol.h"

@interface EMSCoreCompletionHandlerMiddleware ()

@end

@implementation EMSCoreCompletionHandlerMiddleware

- (instancetype)initWithCoreCompletionHandler:(id <EMSRESTClientCompletionProxyProtocol>)completionHandler
                                       worker:(id <EMSWorkerProtocol>)worker
                            requestRepository:(id <EMSRequestModelRepositoryProtocol>)requestRepository
                               operationQueue:(NSOperationQueue *)operationQueue {
    NSParameterAssert(completionHandler);
    NSParameterAssert(worker);
    NSParameterAssert(requestRepository);
    NSParameterAssert(operationQueue);
    if (self = [super init]) {

    }
    return self;
}

- (CoreSuccessBlock)successBlock {
    return ^(NSString *requestId, EMSResponseModel *response) {
    };
}

- (CoreErrorBlock)errorBlock {
    return ^(NSString *requestId, NSError *error) {
    };
}


@end