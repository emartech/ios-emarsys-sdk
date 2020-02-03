//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSLogEntryProtocol.h"
#import "EMSTimestampProvider.h"
#import "MEInAppMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSInAppOnScreenTime : NSObject <EMSLogEntryProtocol>

- (instancetype)initWithInAppMessage:(MEInAppMessage *)message
                       showTimestamp:(NSDate *)showTimestamp
                   timestampProvider:(EMSTimestampProvider *)timestampProvider;

@end

NS_ASSUME_NONNULL_END