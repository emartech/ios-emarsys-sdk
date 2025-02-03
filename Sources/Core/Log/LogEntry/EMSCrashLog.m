//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Social/Social.h>
#import "EMSCrashLog.h"

@interface EMSCrashLog ()

@property(nonatomic, strong) NSDictionary<NSString *, NSString *> *data;

@end

@implementation EMSCrashLog

- (instancetype)initWithException:(NSException *)exception {
    NSParameterAssert(exception);
    NSMutableDictionary *crashInfos = [NSMutableDictionary dictionary];
    if (self = [super init]) {
        NSString *exceptionName = nil;
        if (exception.name) {
            exceptionName = [NSString stringWithFormat:@"%@", exception.name ];
        }
        crashInfos[@"exception"] = exceptionName;
        NSString *stackTrace = nil;
        if (exception.callStackSymbols) {
            NSMutableString *callStackSymbols = [[NSMutableString alloc] init];
            for (NSString *line in exception.callStackSymbols) {
                [callStackSymbols appendString:line];
                [callStackSymbols appendString:@"\n"];
            }
            stackTrace = [NSString stringWithString:callStackSymbols];
        }
        crashInfos[@"stackTrace"] = stackTrace;
    }
    if (exception.reason) {
        crashInfos[@"reason"] = exception.reason;
    }
    if (exception.userInfo) {
        crashInfos[@"userInfo"] = [NSString stringWithFormat:@"%@", exception.userInfo];
    }
    _data = [NSDictionary dictionaryWithDictionary:crashInfos];
    return self;
}

- (NSString *)topic {
    return @"log_crash";
}


@end
