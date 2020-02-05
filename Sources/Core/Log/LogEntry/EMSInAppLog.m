//
// Copyright (c) 2020 Emarsys. All rights reserved.
//
#import "EMSInAppLog.h"
#import "MEInAppMessage.h"
#import "NSDate+EMSCore.h"

@interface EMSInAppLog ()

@property(nonatomic, strong) NSDictionary<NSString *, id> *data;

@end

@implementation EMSInAppLog

- (instancetype)initWithMessage:(MEInAppMessage *)message
                 loadingTimeEnd:(NSDate *)loadingTimeEnd {
    NSParameterAssert(message);
    NSParameterAssert(loadingTimeEnd);
    if (self = [super init]) {
        NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];

        mutableDictionary[@"loadingTimeStart"] = [message.responseTimestamp numberValueInMillis];
        mutableDictionary[@"loadingTimeEnd"] = [loadingTimeEnd numberValueInMillis];
        mutableDictionary[@"loadingTimeDuration"] = [loadingTimeEnd numberValueInMillisFromDate:message.responseTimestamp];
        mutableDictionary[@"campaignId"] = message.campaignId;

        _data = [NSDictionary dictionaryWithDictionary:mutableDictionary];

    }
    return self;
}

- (void)setOnScreenTimeStart:(NSDate *)onScreenTimeStart {
    NSParameterAssert(onScreenTimeStart);
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:self.data];
    mutableDictionary[@"onScreenTimeStart"] = [onScreenTimeStart numberValueInMillis];

    _data = [NSDictionary dictionaryWithDictionary:mutableDictionary];

}

- (void)setOnScreenTimeEnd:(NSDate *)onScreenTimeEnd {
    NSParameterAssert(onScreenTimeEnd);
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:self.data];
    mutableDictionary[@"onScreenTimeEnd"] = [onScreenTimeEnd numberValueInMillis];
    mutableDictionary[@"onScreenTimeDuration"] = @([[onScreenTimeEnd numberValueInMillis] intValue] - [mutableDictionary[@"onScreenTimeStart"] intValue]);

    _data = [NSDictionary dictionaryWithDictionary:mutableDictionary];
}

- (NSString *)topic {
    return @"log_inapp_metrics";
}

@end