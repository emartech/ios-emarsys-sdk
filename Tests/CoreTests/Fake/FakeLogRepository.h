//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSLogRepositoryProtocol.h"

@interface FakeLogRepository : NSObject <EMSLogRepositoryProtocol>

@property(nonatomic, readonly) NSMutableArray <NSDictionary<NSString *, id> *> *loggedElements;

@end