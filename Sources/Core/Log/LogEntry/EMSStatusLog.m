//
// Copyright (c) 2020 Emarsys. All rights reserved.
//
#import "EMSStatusLog.h"

@interface EMSStatusLog ()

@property(nonatomic, strong) NSDictionary<NSString *, NSString *> *data;

@end

@implementation EMSStatusLog

- (instancetype)initWithClass:(Class)klass
                          sel:(SEL)sel
                   parameters:(nullable NSDictionary<NSString *, NSString *> *)parameters
                       status:(nullable NSDictionary<NSString *, NSString *> *)status {
    NSParameterAssert(klass);
    NSParameterAssert(sel);
    if (self = [super init]) {
        NSMutableDictionary *mutableData = [NSMutableDictionary dictionary];
        mutableData[@"className"] = NSStringFromClass(klass);
        mutableData[@"methodName"] = NSStringFromSelector(sel);
        NSString *jsonParameters = nil;
        if (parameters) {
            NSError *error;
            @try {
                NSData *parametersData = [NSJSONSerialization dataWithJSONObject:parameters
                                                                         options:NSJSONWritingPrettyPrinted
                                                                           error:&error];
                if (parametersData) {
                    jsonParameters = [[NSString alloc] initWithData:parametersData
                                                           encoding:NSUTF8StringEncoding];
                }
            } @catch (NSException *exception) {
                mutableData[@"parametersJsonException"] = exception.reason;
            } @finally {
                if (error) {
                    mutableData[@"parametersJsonError"] = error.description;
                }
            }
            
        }
        mutableData[@"parameters"] = jsonParameters;
        NSString *jsonStatus = nil;
        if (status) {
            NSError *error;
            @try {
                NSData *statusData = [NSJSONSerialization dataWithJSONObject:status
                                                                     options:NSJSONWritingPrettyPrinted
                                                                       error:&error];

                if (statusData) {
                    jsonStatus = [[NSString alloc] initWithData:statusData
                                                       encoding:NSUTF8StringEncoding];
                }
            } @catch (NSException *exception) {
                mutableData[@"statusJsonException"] = exception.reason;
            } @finally {
                if (error) {
                    mutableData[@"statusJsonError"] = error.description;
                }
            }
        }
        mutableData[@"status"] = jsonStatus;
        _data = [NSDictionary dictionaryWithDictionary:mutableData];
    }
    return self;
}

- (NSString *)topic {
    return @"log_status";
}

@end
