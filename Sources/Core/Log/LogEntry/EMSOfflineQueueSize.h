//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSLogEntryProtocol.h"

@interface EMSOfflineQueueSize : NSObject <EMSLogEntryProtocol>

- (instancetype)initWithQueueSize:(NSUInteger)queueSize;

@end