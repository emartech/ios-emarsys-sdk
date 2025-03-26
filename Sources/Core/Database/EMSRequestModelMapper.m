//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSRequestModelMapper.h"
#import "EMSRequestModel.h"
#import "NSDictionary+EMSCore.h"
#import "EMSSchemaContract.h"
#import "EMSMacros.h"
#import "EMSCrashLog.h"
#import "EMSStatusLog.h"

@interface EMSRequestModelMapper ()

- (NSData *)dataFromStatement:(sqlite3_stmt *)statement
                        index:(int)index;

- (BOOL)isNotNull:(sqlite3_stmt *)statement
          atIndex:(int)index;
- (nullable NSString *)mapToString:(const unsigned char *)utf8String;

@end

@implementation EMSRequestModelMapper


- (id)modelFromStatement:(sqlite3_stmt *)statement {
    NSString *requestId = [self mapToString:sqlite3_column_text(statement, 0)];
    NSString *method = [self mapToString:sqlite3_column_text(statement, 1)];
    NSString *urlString = [self mapToString:sqlite3_column_text(statement, 2)];
    NSURL *url = [NSURL URLWithString:urlString];
    NSDictionary<NSString *, NSString *> *headers;
    if ([self isNotNull:statement atIndex:3]) {
        headers = [NSDictionary dictionaryWithData:[self dataFromStatement:statement
                                                                     index:3]];
    }
    NSDictionary<NSString *, id> *payload;
    if ([self isNotNull:statement atIndex:4]) {
        payload = [NSDictionary dictionaryWithData:[self dataFromStatement:statement
                                                                     index:4]];
    }
    NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 5)];
    NSTimeInterval expiry = sqlite3_column_double(statement, 6);
    if (!requestId || !method || !url || !timestamp || !expiry) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"requestId"] = requestId;
        parameters[@"method"] = method;
        parameters[@"url"] = url;
        parameters[@"urlString"] = urlString;
        parameters[@"timestamp"] = [timestamp description];
        parameters[@"expiry"] = [NSString stringWithFormat:@"%@", @(expiry)];
        if (headers) {
            parameters[@"headers_exists"] = @"YES";
            parameters[@"headers"] = [headers asJSONString];
        }
        if (payload) {
            parameters[@"payload_exists"] = @"YES";
            parameters[@"payload"] = [payload asJSONString];
        }
        EMSStatusLog *logEntry = [[EMSStatusLog alloc] initWithClass:[self class]
                                                                 sel:_cmd
                                                          parameters:[NSDictionary dictionaryWithDictionary:parameters]
                                                              status:nil];
        EMSLog(logEntry, LogLevelError);
    }
    return [[EMSRequestModel alloc] initWithRequestId:requestId
                                            timestamp:timestamp
                                               expiry:expiry
                                                  url:url
                                               method:method
                                              payload:payload
                                              headers:headers
                                               extras:nil];
}

- (sqlite3_stmt *)bindStatement:(sqlite3_stmt *)statement fromModel:(EMSRequestModel *)model {
    sqlite3_bind_text(statement, 1, [[model requestId] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 2, [[model method] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 3, [[[model url] absoluteString] UTF8String], -1, SQLITE_TRANSIENT);

    NSData *headers = [[model headers] archive];
    sqlite3_bind_blob(statement, 4, [headers bytes], (int) [headers length], SQLITE_TRANSIENT);
    NSData *payload = [[model payload] archive];
    sqlite3_bind_blob(statement, 5, [payload bytes], (int) [payload length], SQLITE_TRANSIENT);
    sqlite3_bind_double(statement, 6, [[model timestamp] timeIntervalSince1970]);
    sqlite3_bind_double(statement, 7, [model ttl]);
    return statement;
}

#pragma mark - Private methods

- (NSData *)dataFromStatement:(sqlite3_stmt *)statement
                        index:(int)index {
    const void *blob = sqlite3_column_blob(statement, index);
    NSUInteger size = (NSUInteger) sqlite3_column_bytes(statement, index);
    return [[NSData alloc] initWithBytes:blob
                                  length:size];
}

- (BOOL)isNotNull:(sqlite3_stmt *)statement
          atIndex:(int)index {
    return sqlite3_column_type(statement, index) != SQLITE_NULL;
}

- (nullable NSString *)mapToString:(const unsigned char *)utf8String {
    NSString *result = nil;
    if (utf8String) {
        result = [NSString stringWithUTF8String:(char *)utf8String];
    }
    return result;
}

- (NSString *)tableName {
    return REQUEST_TABLE_NAME;
}


- (NSUInteger)fieldCount {
    return 7;
}


@end
