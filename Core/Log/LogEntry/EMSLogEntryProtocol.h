//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol EMSLogEntryProtocol <NSObject>

- (NSString *)topic;

- (NSDictionary<NSString *, id> *)data;

@end