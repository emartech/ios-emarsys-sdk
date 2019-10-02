//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSInDatabaseTime.h"
#import "NSDate+EMSCore.h"

@interface EMSInDatabaseTime ()

@property(nonatomic, strong) NSDictionary<NSString *, id> *data;

@end

@implementation EMSInDatabaseTime

- (instancetype)initWithRequestModel:(EMSRequestModel *)requestModel
                             endDate:(NSDate *)endDate {
    if (self = [super init]) {
        NSDate *start = [requestModel timestamp];
        NSMutableDictionary *mutableData = [NSMutableDictionary dictionary];

        mutableData[@"request_id"] = [requestModel requestId];
        mutableData[@"start"] = [start numberValueInMillis];
        mutableData[@"end"] = [endDate numberValueInMillis];
        mutableData[@"duration"] = [endDate numberValueInMillisFromDate:start];
        mutableData[@"url"] = [[requestModel url] absoluteString];

        _data = [NSDictionary dictionaryWithDictionary:mutableData];
    }
    return self;
}

- (NSString *)topic {
    return @"log_in_database_time";
}

@end