//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSMethodNotAllowed.h"

@interface EMSMethodNotAllowed ()

@property(nonatomic, strong) NSDictionary<NSString *, id> *data;

- (instancetype)initWithClassName:(NSString *)className
                              sel:(SEL)sel
                       parameters:(nullable NSDictionary<NSString *, id> *)parameters;

@end

@implementation EMSMethodNotAllowed

- (instancetype)initWithClass:(Class)klass
                          sel:(SEL)sel
                   parameters:(nullable NSDictionary<NSString *, id> *)parameters {
    NSParameterAssert(klass);
    NSParameterAssert(sel);
    return [self initWithClassName:NSStringFromClass(klass)
                               sel:sel
                        parameters:parameters];
}

- (instancetype)initWithProtocol:(Protocol *)proto
                             sel:(SEL)sel
                      parameters:(nullable NSDictionary<NSString *, id> *)parameters {
    NSParameterAssert(proto);
    NSParameterAssert(sel);
    return [self initWithClassName:NSStringFromProtocol(proto)
                               sel:sel
                        parameters:parameters];
}

- (instancetype)initWithClassName:(NSString *)className
                              sel:(SEL)sel
                       parameters:(nullable NSDictionary<NSString *, id> *)parameters {
    if (self = [super init]) {
        NSMutableDictionary *mutableData = [NSMutableDictionary dictionary];
        mutableData[@"class_name"] = className;
        mutableData[@"method_name"] = NSStringFromSelector(sel);
        mutableData[@"parameters"] = parameters;
        _data = [NSDictionary dictionaryWithDictionary:mutableData];
        NSLog(@"Feature disabled, Class: %@ method: %@ not allowed. Please check your config.", className, NSStringFromSelector(sel));
    }
    return self;
}

- (NSString *)topic {
    return @"log_method_not_allowed";
}

@end