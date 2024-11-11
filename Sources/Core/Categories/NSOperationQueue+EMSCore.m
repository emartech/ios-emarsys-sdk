////
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

#import "NSOperationQueue+EMSCore.h"

@implementation NSOperationQueue (EMSCore)

- (void)runSynchronized:(EMSRunnerBlock)runnerBlock {
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:runnerBlock];
    [self addOperations:@[operation]
      waitUntilFinished:YES];
}

@end
