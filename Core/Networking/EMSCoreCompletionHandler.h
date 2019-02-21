//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSCoreCompletion.h"

@interface EMSCoreCompletionHandler : NSObject

@property(nonatomic, readonly) CoreSuccessBlock successBlock;
@property(nonatomic, readonly) CoreErrorBlock errorBlock;

- (instancetype)initWithSuccessBlock:(CoreSuccessBlock)successBlock
                          errorBlock:(CoreErrorBlock)errorBlock;


@end