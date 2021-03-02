//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import "EMSLogLevel.h"

@interface EMSLogLevel()

@property(nonatomic, strong) NSString *level;

@end

@implementation EMSLogLevel

static id <EMSLogLevelProtocol> _trace;
static id <EMSLogLevelProtocol> _debug;
static id <EMSLogLevelProtocol> _info;
static id <EMSLogLevelProtocol> _warn;
static id <EMSLogLevelProtocol> _error;
static id <EMSLogLevelProtocol> _basic;

- (instancetype)initWithLevel:(NSString *)level {
    if (self = [super init]) {
        _level = level;
    }
    return self;
}

+ (id)trace {
    if (!_trace) {
        _trace = [[EMSLogLevel alloc] initWithLevel:@"TRACE"];
    }
    return _trace;
}

+ (id)debug {
    if (!_debug) {
        _debug = [[EMSLogLevel alloc] initWithLevel:@"DEBUG"];
    }
    return _debug;
}

+ (id)info {
    if (!_info) {
        _info = [[EMSLogLevel alloc] initWithLevel:@"INFO"];
    }
    return _info;
}

+ (id)warn {
    if (!_warn) {
        _warn = [[EMSLogLevel alloc] initWithLevel:@"WARN"];
    }
    return _warn;
}

+ (id)error {
    if (!_error) {
        _error = [[EMSLogLevel alloc] initWithLevel:@"ERROR"];
    }
    return _error;
}

+ (id)basic {
    if (!_basic) {
        _basic = [[EMSLogLevel alloc] initWithLevel:@"BASIC"];
    }
    return _basic;
}


@end