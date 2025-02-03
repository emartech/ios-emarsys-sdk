//
// Copyright (c) 2020 Emarsys. All rights reserved.
//
#import "EMSInAppLog.h"
#import "MEInAppMessage.h"
#import "NSDate+EMSCore.h"

@interface EMSInAppLog ()

@property(nonatomic, strong) NSDictionary<NSString *, NSString *> *data;

@end

@implementation EMSInAppLog

- (instancetype)initWithMessage:(MEInAppMessage *)message
                 loadingTimeEnd:(NSDate *)loadingTimeEnd {
    NSParameterAssert(message);
    NSParameterAssert(loadingTimeEnd);
    if (self = [super init]) {
        NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
        if ([message response]) {
            mutableDictionary[@"requestId"] = [[[message response] requestModel] requestId];
        } else {
            mutableDictionary[@"requestId"] = [[NSUUID UUID] UUIDString];
        }
        mutableDictionary[@"loadingTimeStart"] = [NSString stringWithFormat:@"%@", [message.responseTimestamp numberValueInMillis]];
        mutableDictionary[@"loadingTimeEnd"] = [NSString stringWithFormat:@"%@", [loadingTimeEnd numberValueInMillis]];
        mutableDictionary[@"loadingTimeDuration"] = [NSString stringWithFormat:@"%@", [loadingTimeEnd numberValueInMillisFromDate:message.responseTimestamp]];
        mutableDictionary[@"campaignId"] = message.campaignId;

        _data = [NSDictionary dictionaryWithDictionary:mutableDictionary];

    }
    return self;
}

- (void)setOnScreenTimeStart:(NSDate *)onScreenTimeStart {
    NSParameterAssert(onScreenTimeStart);
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:self.data];
    mutableDictionary[@"onScreenTimeStart"] = [NSString stringWithFormat:@"%@", [onScreenTimeStart numberValueInMillis]];

    _data = [NSDictionary dictionaryWithDictionary:mutableDictionary];

}

- (void)setOnScreenTimeEnd:(NSDate *)onScreenTimeEnd {
    NSParameterAssert(onScreenTimeEnd);
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:self.data];
    mutableDictionary[@"onScreenTimeEnd"] = [NSString stringWithFormat:@"%@", [onScreenTimeEnd numberValueInMillis]];
    mutableDictionary[@"onScreenTimeDuration"] = [NSString stringWithFormat:@"%@", @([[onScreenTimeEnd numberValueInMillis] intValue] - [mutableDictionary[@"onScreenTimeStart"] intValue])];

    _data = [NSDictionary dictionaryWithDictionary:mutableDictionary];
}

- (NSString *)topic {
    return @"log_inapp_metrics";
}

@end
