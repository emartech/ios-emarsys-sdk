//
// Copyright (c) 2020 Emarsys. All rights reserved.
//
#import "EMSRequestLog.h"
#import "EMSResponseModel.h"
#import "NSDate+EMSCore.h"

@interface EMSRequestLog ()

@property(nonatomic, strong) NSDictionary<NSString *, id> *data;

@end

@implementation EMSRequestLog

- (instancetype)initWithResponseModel:(EMSResponseModel *)responseModel
                  networkingStartTime:(NSDate *)networkingStartTime {
    NSParameterAssert(responseModel);
    NSParameterAssert(networkingStartTime);
    if (self = [super init]) {
        NSMutableDictionary *mutableData = [NSMutableDictionary dictionary];

        mutableData[@"request_id"] = responseModel.requestModel.requestId;
        mutableData[@"url"] = [responseModel.requestModel.url absoluteString];
        mutableData[@"status_code"] = @(responseModel.statusCode);
        mutableData[@"in_db_start"] = [responseModel.requestModel.timestamp numberValueInMillis];
        mutableData[@"in_db_end"] = [networkingStartTime numberValueInMillis];
        mutableData[@"in_db_duration"] = [networkingStartTime numberValueInMillisFromDate:responseModel.requestModel.timestamp];
        mutableData[@"networking_start"] = [networkingStartTime numberValueInMillis];
        mutableData[@"networking_end"] = [responseModel.timestamp numberValueInMillis];
        mutableData[@"networking_duration"] = [responseModel.timestamp numberValueInMillisFromDate:networkingStartTime];

        _data = [NSDictionary dictionaryWithDictionary:mutableData];
    }
    return self;
}

- (NSString *)topic {
    return @"log_request";
}

@end