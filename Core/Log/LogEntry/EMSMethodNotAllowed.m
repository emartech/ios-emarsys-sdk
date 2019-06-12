//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSMethodNotAllowed.h"

@interface EMSMethodNotAllowed ()

@property(nonatomic, strong) NSDictionary<NSString *, id> *data;

@end

@implementation EMSMethodNotAllowed

- (instancetype)initWithClass:(Class)klass
                   methodName:(NSString *)methodName
                   parameters:(nullable NSDictionary<NSString *, id> *)parameters {
    NSParameterAssert(klass);
    NSParameterAssert(methodName);
    if (self = [super init]) {
        NSMutableDictionary *mutableData = [NSMutableDictionary dictionary];
        mutableData[@"class_name"] = NSStringFromClass(klass);
        mutableData[@"method_name"] = methodName;
        mutableData[@"parameters"] = parameters;
        _data = [NSDictionary dictionaryWithDictionary:mutableData];
    }
    return self;
}

- (NSString *)topic {
    return @"log_method_not_allowed";
}

@end