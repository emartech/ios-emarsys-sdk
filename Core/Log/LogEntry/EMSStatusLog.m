//
// Copyright (c) 2020 Emarsys. All rights reserved.
//
#import "EMSStatusLog.h"

@interface EMSStatusLog ()

@property(nonatomic, strong) NSDictionary<NSString *, id> *data;

@end

@implementation EMSStatusLog

- (instancetype)initWithClass:(Class)klass
                          sel:(SEL)sel
                   parameters:(nullable NSDictionary<NSString *, id> *)parameters
                       status:(nullable NSDictionary<NSString *, id> *)status {
    NSParameterAssert(klass);
    NSParameterAssert(sel);
    if (self = [super init]) {
        NSMutableDictionary *mutableData = [NSMutableDictionary dictionary];
        mutableData[@"class_name"] = NSStringFromClass(klass);
        mutableData[@"method_name"] = NSStringFromSelector(sel);
        mutableData[@"parameters"] = parameters;
        mutableData[@"status"] = status;
        _data = [NSDictionary dictionaryWithDictionary:mutableData];
    }
    return self;
}

- (NSString *)topic {
    return @"log_status";
}

@end