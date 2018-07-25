//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSLockableProtocol.h"

@protocol EMSWorkerProtocol <EMSLockableProtocol>

- (void)run;

@end