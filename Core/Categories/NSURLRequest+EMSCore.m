//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "NSURLRequest+EMSCore.h"
#import "EMSRequestModel.h"

@implementation NSURLRequest (EMSCore)

+ (NSURLRequest *)requestWithRequestModel:(EMSRequestModel *)requestModel
                        additionalHeaders:(nullable NSDictionary *)additionalHeaders {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestModel.url];
    [request setHTTPMethod:requestModel.method];
    NSMutableDictionary *headers;
    if (requestModel.headers) {
        headers = [NSMutableDictionary dictionaryWithDictionary:requestModel.headers];
        if (additionalHeaders) {
            [headers addEntriesFromDictionary:additionalHeaders];
        }
    } else if (additionalHeaders) {
        headers = [additionalHeaders mutableCopy];
    }
    [request setAllHTTPHeaderFields:headers];

    NSError *error;
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:requestModel.payload
                                                         options:NSJSONWritingPrettyPrinted
                                                           error:&error]];
    if (error) {
        request = nil;
    }
    NSAssert(request, @"Cannot create NSURLRequest from RequestModel");
    return request;
}

+ (NSURLRequest *)requestWithRequestModel:(EMSRequestModel *)requestModel {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestModel.url];
    [request setHTTPMethod:requestModel.method];
    if (requestModel.headers) {
        [request setAllHTTPHeaderFields:requestModel.headers];
    }
    if (requestModel.payload) {
        NSError *error;
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:requestModel.payload
                                                             options:NSJSONWritingPrettyPrinted
                                                               error:&error]];
        if (error) {
            request = nil;
        }
    }
    NSAssert(request, @"Cannot create NSURLRequest from RequestModel");
    return request;
}

@end