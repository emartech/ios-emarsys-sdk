//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Social/Social.h>
#import "EMSCrashLog.h"

@interface EMSCrashLog ()

@property(nonatomic, strong) NSDictionary<NSString *, id> *data;

@end

@implementation EMSCrashLog

- (instancetype)initWithException:(NSException *)exception {
    NSParameterAssert(exception);
    if (self = [super init]) {
        NSMutableDictionary *crashInfos = [@{
            @"type": exception.name,
            @"stack_trace": exception.callStackSymbols
        } mutableCopy];
        if (exception.reason) {
            crashInfos[@"reason"] = exception.reason;
        }
        if (exception.userInfo) {
            crashInfos[@"user_info"] = exception.userInfo;
        }
        _data = [NSDictionary dictionaryWithDictionary:crashInfos];
    }
    return self;
}

- (NSString *)topic {
    return @"log_crash";
}


@end