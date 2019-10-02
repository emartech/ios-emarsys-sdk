//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Social/Social.h>
#import "EMSInAppOnScreenTime.h"
#import "NSDate+EMSCore.h"

@interface EMSInAppOnScreenTime ()

@property(nonatomic, strong) NSDictionary<NSString *, id> *data;

@end

@implementation EMSInAppOnScreenTime

- (instancetype)initWithInAppMessage:(MEInAppMessage *)message
                       showTimestamp:(NSDate *)showTimestamp
                   timestampProvider:(EMSTimestampProvider *)timestampProvider {
    NSParameterAssert(message);
    NSParameterAssert(showTimestamp);
    NSParameterAssert(timestampProvider);
    if (self = [super init]) {
        NSDate *endTimeStamp = [timestampProvider provideTimestamp];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"campaign_id"] = message.campaignId;
        dict[@"start"] = [showTimestamp numberValueInMillis];
        dict[@"end"] = [endTimeStamp numberValueInMillis];
        dict[@"duration"] = [endTimeStamp numberValueInMillisFromDate:showTimestamp];
        if (message.response) {
            dict[@"source"] = @"customEvent";
            dict[@"request_id"] = message.response.requestModel.requestId;
        } else {
            dict[@"source"] = @"push";
        }
        _data = [NSDictionary dictionaryWithDictionary:dict];
    }
    return self;
}

- (NSString *)topic {
    return @"log_inapp_on_screen_time";
}

@end