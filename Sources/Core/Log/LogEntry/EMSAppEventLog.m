//
// Copyright (c) 2020 Emarsys. All rights reserved.
//
#import "EMSAppEventLog.h"

@interface EMSAppEventLog ()

@property(nonatomic, strong) NSDictionary<NSString *, id> *data;

@end

@implementation EMSAppEventLog

- (instancetype)initWithEventName:(NSString *)eventName
                       attributes:(nullable NSDictionary<NSString *, id> *)attributes {
    NSParameterAssert(eventName);
    if (self = [super init]) {
        NSMutableDictionary *mutableData = [NSMutableDictionary dictionary];
        mutableData[@"eventName"] = eventName;
        mutableData[@"eventAttributes"] = attributes;
        _data = [NSDictionary dictionaryWithDictionary:mutableData];
    }
    return self;
}

- (NSString *)topic {
    return @"log_app_event";
}


@end