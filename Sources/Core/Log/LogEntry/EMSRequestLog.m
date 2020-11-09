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
                  networkingStartTime:(NSDate *)networkingStartTime
                              headers:(NSDictionary *)headers
                              payload:(NSDictionary *)payload {
    NSParameterAssert(responseModel);
    NSParameterAssert(networkingStartTime);
    if (self = [super init]) {
        NSMutableDictionary *mutableData = [NSMutableDictionary dictionary];

        mutableData[@"requestId"] = responseModel.requestModel.requestId;
        mutableData[@"url"] = [responseModel.requestModel.url absoluteString];
        mutableData[@"statusCode"] = @(responseModel.statusCode);
        mutableData[@"inDbStart"] = [responseModel.requestModel.timestamp numberValueInMillis];
        mutableData[@"inDbEnd"] = [networkingStartTime numberValueInMillis];
        mutableData[@"inDbDuration"] = [networkingStartTime numberValueInMillisFromDate:responseModel.requestModel.timestamp];
        mutableData[@"networkingStart"] = [networkingStartTime numberValueInMillis];
        mutableData[@"networkingEnd"] = [responseModel.timestamp numberValueInMillis];
        mutableData[@"networkingDuration"] = [responseModel.timestamp numberValueInMillisFromDate:networkingStartTime];
        mutableData[@"headers"] = headers;
        mutableData[@"payload"] = payload;

        _data = [NSDictionary dictionaryWithDictionary:mutableData];
    }
    return self;
}

- (NSString *)topic {
    return @"log_request";
}

@end