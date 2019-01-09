//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSShardRepositoryProtocol.h"

typedef void (^FakeCompletionBlock)(NSOperationQueue *currentQueue);

@interface FakeShardRepository : NSObject <EMSShardRepositoryProtocol>

@property(nonatomic, strong) FakeCompletionBlock completionBlock;

- (instancetype)initWithCompletionBlock:(FakeCompletionBlock)completionBlock;

@end