//
// Copyright (c) 2020 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSLogEntryProtocol.h"

@class MEInAppMessage;

@interface EMSInAppLog : NSObject <EMSLogEntryProtocol>

- (instancetype)initWithMessage:(MEInAppMessage *)message
                 loadingTimeEnd:(NSDate *)loadingTimeEnd;

- (void)setOnScreenTimeStart:(NSDate *)onScreenTimeStart;

- (void)setOnScreenTimeEnd:(NSDate *)onScreenTimeEnd;

@end