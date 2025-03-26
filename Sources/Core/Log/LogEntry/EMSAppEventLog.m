//
// Copyright (c) 2020 Emarsys. All rights reserved.
//
#import "EMSAppEventLog.h"

@interface EMSAppEventLog ()

@property(nonatomic, strong) NSDictionary<NSString *, NSString *> *data;

@end

@implementation EMSAppEventLog

- (instancetype)initWithEventName:(NSString *)eventName
                       attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes {
    NSParameterAssert(eventName);
    if (self = [super init]) {
        NSMutableDictionary *mutableData = [NSMutableDictionary dictionary];
        mutableData[@"eventName"] = eventName;
        NSString *jsonAttributes = nil;
        if (attributes) {
            NSError *error;
            @try {
                NSData *attributesData = [NSJSONSerialization dataWithJSONObject:attributes
                                                                         options:NSJSONWritingPrettyPrinted
                                                                           error:&error];

                if (attributesData) {
                    jsonAttributes = [[NSString alloc] initWithData:attributesData
                                                           encoding:NSUTF8StringEncoding];
                }
            } @catch (NSException *exception) {
                mutableData[@"attributesJsonException"] = exception.reason;
            } @finally {
                if (error) {
                    mutableData[@"attributesJsonError"] = error.description;
                }
            }
        }
        mutableData[@"eventAttributes"] = jsonAttributes;
        _data = [NSDictionary dictionaryWithDictionary:mutableData];
    }
    return self;
}

- (NSString *)topic {
    return @"log_app_event";
}


@end
