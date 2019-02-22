//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSCoreCompletion.h"

@protocol EMSCoreCompletionHandlerProtocol <NSObject>

- (CoreSuccessBlock)successBlock;

- (CoreErrorBlock)errorBlock;

@end