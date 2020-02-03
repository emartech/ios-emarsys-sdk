//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSLogEntryProtocol.h"

@interface EMSCrashLog : NSObject <EMSLogEntryProtocol>

- (instancetype)initWithException:(NSException *)exception;

@end