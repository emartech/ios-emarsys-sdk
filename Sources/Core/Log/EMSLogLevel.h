//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSLogLevelProtocol.h"

@interface EMSLogLevel : NSObject <EMSLogLevelProtocol>

@property(class, nonatomic, readonly) id <EMSLogLevelProtocol> trace;
@property(class, nonatomic, readonly) id <EMSLogLevelProtocol> debug;
@property(class, nonatomic, readonly) id <EMSLogLevelProtocol> info;
@property(class, nonatomic, readonly) id <EMSLogLevelProtocol> warn;
@property(class, nonatomic, readonly) id <EMSLogLevelProtocol> error;
@property(class, nonatomic, readonly) id <EMSLogLevelProtocol> metric;

@end