//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSMethodNotAllowed.h"

@interface EMSMethodNotAllowed ()

@property(nonatomic, strong) NSDictionary<NSString *, NSString *> *data;

- (instancetype)initWithClassName:(NSString *)className
                              sel:(SEL)sel
                       parameters:(nullable NSDictionary<NSString *, NSString *> *)parameters;

@end

@implementation EMSMethodNotAllowed

- (instancetype)initWithClass:(Class)klass
                          sel:(SEL)sel
                   parameters:(nullable NSDictionary<NSString *, NSString *> *)parameters {
    NSParameterAssert(klass);
    NSParameterAssert(sel);
    return [self initWithClassName:NSStringFromClass(klass)
                               sel:sel
                        parameters:parameters];
}

- (instancetype)initWithProtocol:(Protocol *)proto
                             sel:(SEL)sel
                      parameters:(nullable NSDictionary<NSString *, NSString *> *)parameters {
    NSParameterAssert(proto);
    NSParameterAssert(sel);
    return [self initWithClassName:NSStringFromProtocol(proto)
                               sel:sel
                        parameters:parameters];
}

- (instancetype)initWithClassName:(NSString *)className
                              sel:(SEL)sel
                       parameters:(nullable NSDictionary<NSString *, NSString *> *)parameters {
    if (self = [super init]) {
        NSMutableDictionary *mutableData = [NSMutableDictionary dictionary];
        mutableData[@"className"] = className;
        mutableData[@"methodName"] = NSStringFromSelector(sel);
        NSString *jsonParameters = nil;
        if (parameters) {
            NSError *error;
            NSData *parametersData = [NSJSONSerialization dataWithJSONObject:parameters
                                                                     options:NSJSONWritingPrettyPrinted
                                                                       error:&error];

            if (parametersData) {
                jsonParameters = [[NSString alloc] initWithData:parametersData
                                                       encoding:NSUTF8StringEncoding];
            }
            if (error) {
                mutableData[@"parametersJsonError"] = error.description;
            }
        }
        mutableData[@"parameters"] = jsonParameters;
        _data = [NSDictionary dictionaryWithDictionary:mutableData];
    }
    return self;
}

- (NSString *)topic {
    return @"log_method_not_allowed";
}

@end
