//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EMSLockableProtocol <NSObject>

- (void)lock;

- (void)unlock;

- (BOOL)isLocked;

@end