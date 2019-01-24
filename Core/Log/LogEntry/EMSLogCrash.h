//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSLogEntryProtocol.h"

@interface EMSLogCrash : NSObject <EMSLogEntryProtocol>

- (instancetype)initWithException:(NSException *)exception;

@end