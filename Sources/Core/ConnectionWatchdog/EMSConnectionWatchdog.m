//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSConnectionWatchdog.h"
#import <Network/Network.h>

@interface EMSConnectionWatchdog ()


@property(nonatomic, strong) NSOperationQueue *operationQueue;
@property(nonatomic, strong) nw_path_monitor_t pathMonitor;
@property(nonatomic, assign) EMSNetworkStatus connectionStatus;
@property(nonatomic, assign) BOOL isSatisfied;

@end

@implementation EMSConnectionWatchdog

- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue {
    NSParameterAssert(operationQueue);
    if (self = [super init]) {
        _pathMonitor = nw_path_monitor_create();
        dispatch_queue_t queue = dispatch_queue_create("ems_queue", DISPATCH_QUEUE_CONCURRENT);
        nw_path_monitor_set_queue(self.pathMonitor, queue);
        _operationQueue = operationQueue;
        _isSatisfied = NO;
    }
    return self;
}

- (EMSNetworkStatus)connectionState {
    return self.connectionStatus;
}

- (BOOL)isConnected {
    return self.isSatisfied;
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
    __weak typeof(self) weakSelf = self;
    nw_path_monitor_set_update_handler(self.pathMonitor, ^(nw_path_t  _Nonnull path) {
        [weakSelf.operationQueue addOperationWithBlock:^{
            nw_path_status_t status = nw_path_get_status(path);
            weakSelf.isSatisfied = status == nw_path_status_satisfied;
            weakSelf.connectionStatus = NotReachable;
            if (weakSelf.isSatisfied) {
                BOOL isWiFi = nw_path_uses_interface_type(path, nw_interface_type_wifi);
                BOOL isCellular = nw_path_uses_interface_type(path, nw_interface_type_cellular);
                BOOL isWire = nw_path_uses_interface_type(path, nw_interface_type_wired);
                BOOL isLoopback = nw_path_uses_interface_type(path, nw_interface_type_loopback);
                BOOL isOther = nw_path_uses_interface_type(path, nw_interface_type_other);
                if (isWiFi) {
                    weakSelf.connectionStatus = ReachableViaWiFi;
                } else if (isCellular) {
                    weakSelf.connectionStatus = ReachableViaWWAN;
                } else if (isWire) {
                    weakSelf.connectionStatus = ReachableViaWire;
                } else if (isLoopback) {
                    weakSelf.connectionStatus = ReachableViaLoopback;
                } else if (isOther) {
                    weakSelf.connectionStatus = ReachableViaOther;
                }
            }
            [weakSelf.connectionChangeListener connectionChangedToNetworkStatus:weakSelf.connectionStatus
                                                               connectionStatus:weakSelf.isSatisfied];
        }];
    });
    nw_path_monitor_start(self.pathMonitor);
}

@end
