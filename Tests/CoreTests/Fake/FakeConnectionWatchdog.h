//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSConnectionWatchdog.h"

@interface FakeConnectionWatchdog : EMSConnectionWatchdog

@property(nonatomic, strong) NSNumber *isConnectedCallCount;

- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue
                   connectionResponses:(NSArray *)connectionResponses;

@end