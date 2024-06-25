//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSConnectionWatchdog.h"
#import <Network/Network.h>

@interface EMSConnectionWatchdog ()


@property(nonatomic, strong) NSOperationQueue *operationQueue;
@property(nonatomic, strong) nw_path_monitor_t pathMonitor;
@property(nonatomic, assign) EMSNetworkStatus connectionStatus;

@end

@implementation EMSConnectionWatchdog

- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue {
    NSParameterAssert(operationQueue);
    if (self = [super init]) {
        _pathMonitor = nw_path_monitor_create();
        _operationQueue = operationQueue;
    }
    return self;
}

- (EMSNetworkStatus)connectionState {
    return self.connectionStatus;
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
    nw_path_monitor_cancel(self.pathMonitor);
}

- (void)startObserving {
    dispatch_queue_t queue = dispatch_queue_create("ems_queue", DISPATCH_QUEUE_SERIAL);
    nw_path_monitor_set_queue(self.pathMonitor, queue);
    __weak typeof(self) weakSelf = self;
    nw_path_monitor_set_update_handler(self.pathMonitor, ^(nw_path_t  _Nonnull path) {
        nw_path_status_t status = nw_path_get_status(path);
        weakSelf.connectionStatus = NotReachable;
        if (status == nw_path_status_satisfied) {
            BOOL isWiFi = nw_path_uses_interface_type(path, nw_interface_type_wifi);
            BOOL isCellular = nw_path_uses_interface_type(path, nw_interface_type_cellular);
            if (isWiFi) {
                weakSelf.connectionStatus = ReachableViaWiFi;
            } else if (isCellular) {
                weakSelf.connectionStatus = ReachableViaWWAN;
            }
        }
        [weakSelf.operationQueue addOperationWithBlock:^{
            [weakSelf.connectionChangeListener connectionChangedToNetworkStatus:weakSelf.connectionStatus
                                                               connectionStatus:weakSelf.connectionStatus != NotReachable];
        }];
    });
    nw_path_monitor_start(self.pathMonitor);
}

@end
