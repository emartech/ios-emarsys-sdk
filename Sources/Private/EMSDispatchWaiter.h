//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMSDispatchWaiter : NSObject

- (void)enter;
- (void)exit;
- (void)waitWithInterval:(int)interval;

@end