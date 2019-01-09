//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "FakeShardRepository.h"

@implementation FakeShardRepository

- (instancetype)initWithCompletionBlock:(FakeCompletionBlock)completionBlock {
    if (self = [super init]) {
        _completionBlock = completionBlock;
    }
    return self;
}


- (void)add:(EMSShard *)item {
    [self complete];
}

- (void)remove:(id <EMSSQLSpecificationProtocol>)sqlSpecification {
    [self complete];
}

- (NSArray<EMSShard *> *)query:(id <EMSSQLSpecificationProtocol>)sqlSpecification {
    [self complete];
    return nil;
}

- (BOOL)isEmpty {
    [self complete];
    return NO;
}

- (void)complete {
    self.completionBlock([NSOperationQueue currentQueue]);
}

@end