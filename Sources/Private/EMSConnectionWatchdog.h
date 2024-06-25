//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    NotReachable = 0,
    ReachableViaWiFi,
    ReachableViaWWAN
} EMSNetworkStatus;

@protocol EMSConnectionChangeListener

- (void)connectionChangedToNetworkStatus:(EMSNetworkStatus)networkStatus
                        connectionStatus:(BOOL)connected;

@end

@interface EMSConnectionWatchdog : NSObject

@property(nonatomic, weak) id <EMSConnectionChangeListener> connectionChangeListener;

- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue;

- (EMSNetworkStatus)connectionState;

- (BOOL)isConnected;

@end
