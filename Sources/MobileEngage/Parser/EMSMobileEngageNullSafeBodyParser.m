//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import "EMSMobileEngageNullSafeBodyParser.h"
#import "EMSStatusLog.h"
#import "EMSMacros.h"
#import "EMSResponseModel.h"
#import "NSDate+EMSCore.h"

@interface EMSMobileEngageNullSafeBodyParser ()

@property(nonatomic, assign) BOOL shouldSendLog;

@end

@implementation EMSMobileEngageNullSafeBodyParser

- (instancetype)initWithEndpoint:(EMSEndpoint *)endpoint {
    NSParameterAssert(endpoint);
    if (self = [super init]) {
        _endpoint = endpoint;
    }
    return self;
}

- (BOOL)shouldParse:(EMSRequestModel *)requestModel
       responseBody:(NSData *)responseBody {
    return [self.endpoint isMobileEngageUrl:requestModel.url.absoluteString]
            && ![self.endpoint isPushToInAppUrl:requestModel.url.absoluteString]
            && responseBody
            && responseBody.length > 0;
}

- (id)parseWithRequestModel:(EMSRequestModel *)requestModel
               responseBody:(NSData *)responseBody {
    NSError *error;
    id result = nil;
    id parsedBody = [NSJSONSerialization JSONObjectWithData:responseBody
                                                    options:NSJSONReadingMutableContainers
                                                      error:&error];

    if (error) {
        [self setShouldSendLog:YES];
    } else {
        if ([parsedBody isKindOfClass:[NSDictionary class]]) {
            result = [NSDictionary dictionaryWithDictionary:[self removeNSNullsFromDictionary:parsedBody]];
        } else if ([parsedBody isKindOfClass:[NSArray class]]) {
            result = [self removeNSNullsFromArray:parsedBody];
        }
    }

    if ([self shouldSendLog]) {
        [self sendLogWithRequestModel:requestModel
                         responseBody:responseBody
                                error:error];
    }
    return result;
}

- (NSMutableDictionary *)removeNSNullsFromDictionary:(NSMutableDictionary *)dictionary {
    NSArray *keys = dictionary.allKeys;
    for (NSString *key in keys) {
        NSObject *value = dictionary[key];
        if ([value isKindOfClass:[NSNull class]]) {
            [dictionary removeObjectForKey:key];
            [self setShouldSendLog:YES];
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            [self removeNSNullsFromDictionary:(NSMutableDictionary *) value];
        } else if ([value isKindOfClass:[NSArray class]]) {
            dictionary[key] = [self removeNSNullsFromArray:(NSArray *) value];
        }
    };
    return dictionary;
}

- (NSArray *)removeNSNullsFromArray:(NSArray *)array {
    NSMutableArray *nullSafeArray = [NSMutableArray array];
    for (id item in array) {
        if ([item isKindOfClass:[NSNull class]]) {
            [self setShouldSendLog:YES];
        } else if ([item isKindOfClass:[NSArray class]]) {
            [nullSafeArray addObject:[self removeNSNullsFromArray:item]];
        } else if ([item isKindOfClass:[NSDictionary class]]) {
            [nullSafeArray addObject:[self removeNSNullsFromDictionary:(NSMutableDictionary *) item]];
        } else {
            [nullSafeArray addObject:item];
        }
    }
    return [NSArray arrayWithArray:nullSafeArray];
}

- (void)sendLogWithRequestModel:(EMSRequestModel *)requestModel
                   responseBody:(NSData *)responseBody
                          error:(NSError *)error {
    NSMutableDictionary *statusDict = [NSMutableDictionary dictionary];
    statusDict[@"responseBody"] = [[NSString alloc] initWithData:responseBody
                                                        encoding:NSUTF8StringEncoding];
    statusDict[@"url"] = [[requestModel url] absoluteString];
    statusDict[@"timestamp"] = [[requestModel timestamp] stringValueInUTC];
    statusDict[@"error"] = error.localizedDescription;

    EMSStatusLog *logEntry = [[EMSStatusLog alloc] initWithClass:[self class]
                                                             sel:_cmd
                                                      parameters:nil
                                                          status:[NSDictionary dictionaryWithDictionary:statusDict]];
    EMSLog(logEntry, LogLevelError);

    [self setShouldSendLog:NO];
}

@end