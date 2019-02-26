//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSWorkerProtocol.h"
#import "EMSCoreCompletion.h"
#import "EMSConnectionWatchdog.h"
#import "EMSRequestModelRepositoryProtocol.h"
#import "EMSRESTClient.h"

@class EMSRESTClientCompletionProxyFactory;

NS_ASSUME_NONNULL_BEGIN

@interface EMSDefaultWorker : NSObject <EMSWorkerProtocol, EMSConnectionChangeListener>

- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue
                     requestRepository:(id <EMSRequestModelRepositoryProtocol>)repository
                    connectionWatchdog:(EMSConnectionWatchdog *)connectionWatchdog
                            restClient:(EMSRESTClient *)client
                            errorBlock:(CoreErrorBlock)errorBlock
                          proxyFactory:(EMSRESTClientCompletionProxyFactory *)proxyFactory;
@end

NS_ASSUME_NONNULL_END