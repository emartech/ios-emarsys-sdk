//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSNetworkingTime.h"
#import "EMSResponseModel.h"
#import "NSDate+EMSCore.h"

@interface EMSNetworkingTime ()

@property(nonatomic, strong) NSDictionary<NSString *, id> *data;

@end

@implementation EMSNetworkingTime

- (instancetype)initWithResponseModel:(EMSResponseModel *)responseModel
                            startDate:(NSDate *)startDate {
    if (self = [super init]) {
        NSMutableDictionary *mutableData = [NSMutableDictionary dictionary];
        mutableData[@"request_id"] = [responseModel.requestModel requestId];
        mutableData[@"start"] = [startDate numberValueInMillis];
        mutableData[@"end"] = [responseModel.timestamp numberValueInMillis];
        mutableData[@"duration"] = [responseModel.timestamp numberValueInMillisFromDate:startDate];
        mutableData[@"url"] = [[responseModel.requestModel url] absoluteString];
        mutableData[@"status_code"] = @([responseModel statusCode]);
        _data = [NSDictionary dictionaryWithDictionary:mutableData];
    }
    return self;
}

- (NSString *)topic {
    return @"log_networking_time";
}

@end