//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSRequestFactory.h"
#import "EMSRequestManager.h"
#import "EMSSessionIdHolder.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSSession : NSObject

@property(nonatomic, strong) EMSSessionIdHolder *sessionIdHolder;
@property(nonatomic, strong, nullable) NSDate *sessionStartTime;

- (instancetype)initWithSessionIdHolder:(EMSSessionIdHolder *)sessionIdHolder
                         requestManager:(EMSRequestManager *)requestManager
                         requestFactory:(EMSRequestFactory *)requestFactory
                         operationQueue:(NSOperationQueue *)operationQueue
                      timestampProvider:(EMSTimestampProvider *)timestampProvider;

- (void)startSession;
- (void)stopSession;

@end

NS_ASSUME_NONNULL_END