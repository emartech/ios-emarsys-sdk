//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSCoreCompletion.h"

@protocol EMSRequestModelRepositoryProtocol;
@protocol EMSRESTClientCompletionProxyProtocol;
@protocol EMSWorkerProtocol;

@interface EMSRESTClientCompletionProxyFactory : NSObject

- (instancetype)initWithRequestRepository:(id <EMSRequestModelRepositoryProtocol>)requestRepository
                           operationQueue:(NSOperationQueue *)operationQueue
                      defaultSuccessBlock:(CoreSuccessBlock)defaultSuccessBlock
                        defaultErrorBlock:(CoreErrorBlock)defaultErrorBlock;

- (id <EMSRESTClientCompletionProxyProtocol>)createWithWorker:(id <EMSWorkerProtocol>)worker
                                                 successBlock:(CoreSuccessBlock)successBlock
                                                   errorBlock:(CoreErrorBlock)errorBlock;

@end