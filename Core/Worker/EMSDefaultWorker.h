//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSWorkerProtocol.h"
#import "EMSCoreCompletion.h"
#import "EMSConnectionWatchdog.h"
#import "EMSRequestModelRepositoryProtocol.h"
#import "EMSLogRepositoryProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSDefaultWorker : NSObject <EMSWorkerProtocol, EMSConnectionChangeListener>

- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue
                     requestRepository:(id <EMSRequestModelRepositoryProtocol>)requestRepository
                         logRepository:(id <EMSLogRepositoryProtocol>)logRepository
                          successBlock:(CoreSuccessBlock)successBlock
                            errorBlock:(CoreErrorBlock)errorBlock;
@end

NS_ASSUME_NONNULL_END