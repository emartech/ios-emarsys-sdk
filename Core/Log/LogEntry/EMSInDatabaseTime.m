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
        _data = @{
                @"request_id": [requestModel requestId],
                @"start": [start numberValueInMillis],
                @"end": [endDate numberValueInMillis],
                @"duration": [endDate numberValueInMillisFromDate:start],
                @"url": [[requestModel url] absoluteString]
        };
    }
    return self;
}

- (NSString *)topic {
    return @"log_in_database_time";
}

@end