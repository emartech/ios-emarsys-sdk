//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSReachability.h"

@protocol EMSConnectionChangeListener

- (void)connectionChangedToNetworkStatus:(EMSNetworkStatus)networkStatus
                        connectionStatus:(BOOL)connected;

@end

@interface EMSConnectionWatchdog : NSObject

@property(nonatomic, weak) id <EMSConnectionChangeListener> connectionChangeListener;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue;

- (instancetype)initWithReachability:(EMSReachability *)reachability
                      operationQueue:(NSOperationQueue *)operationQueue;

- (EMSNetworkStatus)connectionState;

- (BOOL)isConnected;

@end