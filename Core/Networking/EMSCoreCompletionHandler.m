//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSCoreCompletionHandler.h"

@interface EMSCoreCompletionHandler ()

@property(nonatomic, readonly) CoreSuccessBlock successBlock;
@property(nonatomic, readonly) CoreErrorBlock errorBlock;

@end

@implementation EMSCoreCompletionHandler

- (instancetype)initWithSuccessBlock:(CoreSuccessBlock)successBlock
                          errorBlock:(CoreErrorBlock)errorBlock {
    NSParameterAssert(successBlock);
    NSParameterAssert(errorBlock);
    if (self = [super init]) {
        _successBlock = successBlock;
        _errorBlock = errorBlock;
    }
    return self;
}

@end