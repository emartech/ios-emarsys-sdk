//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSConnectionWatchdog.h"

@interface EMSConnectionWatchdog ()

@property(nonatomic, strong) EMSReachability *reachability;
@property(nonatomic, strong) id notificationToken;
@property(nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation EMSConnectionWatchdog

- (instancetype)initWithReachability:(EMSReachability *)reachability
                      operationQueue:(NSOperationQueue *)operationQueue {
    NSParameterAssert(reachability);
    NSParameterAssert(operationQueue);
    if (self = [super init]) {
        _reachability = reachability;
        _operationQueue = operationQueue;
    }

    return self;
}

- (EMSNetworkStatus)connectionState {
    return [self.reachability currentReachabilityStatus];
}

- (BOOL)isConnected {
    EMSNetworkStatus state = [self connectionState];
    BOOL result = state == ReachableViaWiFi || state == ReachableViaWWAN;
    return result;
}

- (void)setConnectionChangeListener:(id <EMSConnectionChangeListener>)connectionChangeListener {
    _connectionChangeListener = connectionChangeListener;

    if (_connectionChangeListener) {
        [self startObserving];
    } else {
        [self stopObserving];
    }

}

- (void)stopObserving {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.reachability stopNotifier];
    });
    [self.operationQueue addOperationWithBlock:^{
        [[NSNotificationCenter defaultCenter] removeObserver:weakSelf.notificationToken];
    }];
}

- (void)startObserving {
    __weak typeof(self) weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        weakSelf.notificationToken = [[NSNotificationCenter defaultCenter] addObserverForName:kEMSReachabilityChangedNotification
                                                                                       object:nil
                                                                                        queue:weakSelf.operationQueue
                                                                                   usingBlock:^(NSNotification *note) {
                                                                                       EMSNetworkStatus connectionStatus = [note.object currentReachabilityStatus];
                                                                                       BOOL connected = connectionStatus == ReachableViaWiFi || connectionStatus == ReachableViaWWAN;
                                                                                       [weakSelf.connectionChangeListener connectionChangedToNetworkStatus:connectionStatus
                                                                                                                                          connectionStatus:connected];
                                                                                   }];
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.reachability startNotifier];
    });
}

@end
