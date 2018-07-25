//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSRequestManager.h"

@protocol EMSWorkerProtocol;

@interface EMSRequestManager (Private)

- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue
                                worker:(id <EMSWorkerProtocol>)worker
                     requestRepository:(id <EMSRequestModelRepositoryProtocol>)repository;

@end