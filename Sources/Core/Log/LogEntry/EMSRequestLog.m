//
// Copyright (c) 2020 Emarsys. All rights reserved.
//
#import "EMSRequestLog.h"
#import "EMSResponseModel.h"
#import "NSDate+EMSCore.h"

@interface EMSRequestLog ()

@property(nonatomic, strong) NSDictionary<NSString *, NSString *> *data;

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
        mutableData[@"statusCode"] = [NSString stringWithFormat:@"%@", @(responseModel.statusCode)];
        mutableData[@"inDbStart"] = [NSString stringWithFormat:@"%@", [responseModel.requestModel.timestamp numberValueInMillis]];
        mutableData[@"inDbEnd"] = [NSString stringWithFormat:@"%@", [networkingStartTime numberValueInMillis]];
        mutableData[@"inDbDuration"] = [NSString stringWithFormat:@"%@", [networkingStartTime numberValueInMillisFromDate:responseModel.requestModel.timestamp]];
        mutableData[@"networkingStart"] = [NSString stringWithFormat:@"%@", [networkingStartTime numberValueInMillis]];
        mutableData[@"networkingEnd"] = [NSString stringWithFormat:@"%@", [responseModel.timestamp numberValueInMillis]];
        mutableData[@"networkingDuration"] = [NSString stringWithFormat:@"%@", [responseModel.timestamp numberValueInMillisFromDate:networkingStartTime]];
        NSString *jsonHeaders = nil;
        if (headers) {
            NSError *error;
            @try {
                NSData *headersData = [NSJSONSerialization dataWithJSONObject:headers
                                                                     options:NSJSONWritingPrettyPrinted
                                                                       error:&error];
                if (headersData) {
                    jsonHeaders = [[NSString alloc] initWithData:headersData
                                                        encoding:NSUTF8StringEncoding];
                }
            } @catch (NSException *exception) {
                mutableData[@"headersJsonException"] = exception.reason;
            } @finally {
                if (error) {
                    mutableData[@"headersJsonError"] = error.description;
                }
            }
        }
        mutableData[@"headers"] = jsonHeaders;
        NSString *jsonPayload = nil;
        if (payload) {
            NSError *error;
            @try {
                NSData *payloadData = [NSJSONSerialization dataWithJSONObject:payload
                                                                      options:NSJSONWritingPrettyPrinted
                                                                        error:&error];

                if (payloadData) {
                    jsonPayload = [[NSString alloc] initWithData:payloadData
                                                        encoding:NSUTF8StringEncoding];
                }
            } @catch (NSException *exception) {
                mutableData[@"payloadJsonException"] = exception.reason;
            } @finally {
                if (error) {
                    mutableData[@"payloadJsonError"] = error.description;
                }
            }
        }
        mutableData[@"payload"] = jsonPayload;
        _data = [NSDictionary dictionaryWithDictionary:mutableData];
    }
    return self;
}

- (NSString *)topic {
    return @"log_request";
}

@end
