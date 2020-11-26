//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSRequestFactory.h"
#import "EMSRequestManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSSession : NSObject

@property(nonatomic, strong, nullable) NSString *sessionId;
@property(nonatomic, strong, nullable) NSDate *sessionStartTime;

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                        requestFactory:(EMSRequestFactory *)requestFactory
                        operationQueue:(NSOperationQueue *)operationQueue
                     timestampProvider:(EMSTimestampProvider *)timestampProvider;

- (void)startSession;
- (void)stopSession;

@end

NS_ASSUME_NONNULL_END