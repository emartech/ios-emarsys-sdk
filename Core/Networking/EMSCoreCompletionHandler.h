//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSCoreCompletion.h"
#import "EMSCoreCompletionHandlerProtocol.h"

@interface EMSCoreCompletionHandler : NSObject <EMSCoreCompletionHandlerProtocol>

- (instancetype)initWithSuccessBlock:(CoreSuccessBlock)successBlock
                          errorBlock:(CoreErrorBlock)errorBlock;


@end