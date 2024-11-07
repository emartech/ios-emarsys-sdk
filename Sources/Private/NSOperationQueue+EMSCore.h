////
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^EMSRunnerBlock)(void);

@interface NSOperationQueue (EMSCore)

- (void)runSynchronized:(EMSRunnerBlock)runnerBlock;

@end

NS_ASSUME_NONNULL_END
