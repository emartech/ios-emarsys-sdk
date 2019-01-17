//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSNetworkingTime.h"
#import "EMSResponseModel.h"
#import "NSDate+EMSCore.h"

@interface EMSNetworkingTime()

@property(nonatomic, strong) NSDictionary<NSString *, id> *data;

@end

@implementation EMSNetworkingTime

- (instancetype)initWithResponseModel:(EMSResponseModel *)responseModel
                            startDate:(NSDate *)startDate {
    if (self = [super init]) {
        _data = @{
                @"request_id": [responseModel.requestModel requestId],
                @"start": [startDate numberValueInMillis],
                @"end": [responseModel.timestamp numberValueInMillis],
                @"duration": [responseModel.timestamp numberValueInMillisFromDate:startDate],
                @"url": [[responseModel.requestModel url] absoluteString],
                @"status_code": @([responseModel statusCode])
        };
    }
    return self;
}

- (NSString *)topic {
    return @"log_networking_time";
}

@end