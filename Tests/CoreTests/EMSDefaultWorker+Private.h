//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSDefaultWorker.h"
#import "EMSRESTClient.h"

@interface EMSDefaultWorker (Private)

- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue
                     requestRepository:(id <EMSRequestModelRepositoryProtocol>)repository
                    connectionWatchdog:(EMSConnectionWatchdog *)connectionWatchdog
                            restClient:(EMSRESTClient *)client;

- (void)setConnectionWatchdog:(EMSConnectionWatchdog *)connectionWatchdog;

- (void)setRepository:(id <EMSRequestModelRepositoryProtocol>)repository;

- (void)setClient:(EMSRESTClient *)client;

- (EMSRESTClient *)client;

@end