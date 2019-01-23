//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSInAppLoadingTime.h"
#import "NSDate+EMSCore.h"

@interface EMSInAppLoadingTime ()

@property(nonatomic, strong) NSDictionary<NSString *, id> *data;

@end

@implementation EMSInAppLoadingTime

- (instancetype)initWithInAppMessage:(MEInAppMessage *)message
                   timestampProvider:(EMSTimestampProvider *)timestampProvider {
    NSParameterAssert(message);
    NSParameterAssert(timestampProvider);
    if (self = [super init]) {
        NSMutableDictionary *dict = [@{
            @"campaign_id": message.campaignId,
            @"loading_time": [[timestampProvider provideTimestamp] numberValueInMillisFromDate:message.responseTimestamp]
        } mutableCopy];
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
    return @"log_inapp_loading_time";
}

@end