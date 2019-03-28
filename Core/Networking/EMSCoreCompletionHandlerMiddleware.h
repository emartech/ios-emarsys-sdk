//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSRESTClientCompletionProxyProtocol.h"

@protocol EMSWorkerProtocol;
@protocol EMSRequestModelRepositoryProtocol;

@interface EMSCoreCompletionHandlerMiddleware : NSObject <EMSRESTClientCompletionProxyProtocol>

@property(nonatomic, readonly) id <EMSRESTClientCompletionProxyProtocol> completionHandler;
@property(nonatomic, readonly) id <EMSWorkerProtocol> worker;
@property(nonatomic, readonly) id <EMSRequestModelRepositoryProtocol> requestRepository;
@property(nonatomic, readonly) NSOperationQueue *operationQueue;

- (instancetype)initWithCoreCompletionHandler:(id <EMSRESTClientCompletionProxyProtocol>)completionHandler
                                       worker:(id <EMSWorkerProtocol>)worker
                            requestRepository:(id <EMSRequestModelRepositoryProtocol>)requestRepository
                               operationQueue:(NSOperationQueue *)operationQueue;

@end