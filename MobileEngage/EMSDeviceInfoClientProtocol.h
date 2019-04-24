//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

@protocol EMSDeviceInfoClientProtocol <NSObject>

- (void)sendDeviceInfoWithCompletionBlock:(EMSCompletionBlock)completionBlock;

@end