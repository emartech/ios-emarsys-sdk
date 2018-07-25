//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSConnectionWatchdog.h"

typedef void (^FakeConnectionChangeListenerCompletionBlock)(NSOperationQueue *currentQueue);

@interface FakeConnectionChangeListener : NSObject <EMSConnectionChangeListener>

@property(nonatomic, assign) EMSNetworkStatus networkStatus;
@property(nonatomic, assign) BOOL connected;

- (instancetype)initWithCompletionBlock:(FakeConnectionChangeListenerCompletionBlock)completionBlock;

@end