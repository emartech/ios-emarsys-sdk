//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSRESTClientCompletionProxyProtocol.h"

@interface FakeRESTClientCompletionProxy : NSObject <EMSRESTClientCompletionProxyProtocol>

@property(nonatomic, strong) EMSRESTClientCompletionBlock completionBlock;

- (instancetype)initWithCompletionBlock:(EMSRESTClientCompletionBlock)completionBlock;

@end