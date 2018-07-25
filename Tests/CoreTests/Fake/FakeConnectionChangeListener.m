//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "FakeConnectionChangeListener.h"

@interface FakeConnectionChangeListener ()

@property(nonatomic, strong) FakeConnectionChangeListenerCompletionBlock completionBlock;

@end

@implementation FakeConnectionChangeListener

- (instancetype)initWithCompletionBlock:(FakeConnectionChangeListenerCompletionBlock)completionBlock {
    NSParameterAssert(completionBlock);
    if (self = [super init]) {
        _completionBlock = completionBlock;
    }
    return self;
}

- (void)connectionChangedToNetworkStatus:(EMSNetworkStatus)networkStatus
                        connectionStatus:(BOOL)connected {
    self.networkStatus = networkStatus;
    self.connected = connected;
    self.completionBlock([NSOperationQueue currentQueue]);
}

@end