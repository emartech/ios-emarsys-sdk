//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSResponseModel.h"

@implementation EMSResponseModel {
    id _parsedBody;
}

- (id)initWithHttpUrlResponse:(NSHTTPURLResponse *)httpUrlResponse
                         data:(NSData *)data
                 requestModel:(EMSRequestModel *)requestModel
                    timestamp:(NSDate *)timestamp {
    return [self initWithStatusCode:httpUrlResponse.statusCode
                            headers:httpUrlResponse.allHeaderFields
                               body:data
                       requestModel:requestModel
                          timestamp:timestamp];
}

- (id)initWithStatusCode:(NSInteger)statusCode
                 headers:(NSDictionary<NSString *, NSString *> *)headers
                    body:(NSData *)body
            requestModel:(EMSRequestModel *)requestModel
               timestamp:(NSDate *)timestamp {
    if (self = [super init]) {
        NSParameterAssert(requestModel);
        _statusCode = statusCode;
        _headers = headers;
        _cookies = [self extractCookies:headers
                           requestModel:requestModel];
        _body = body;
        _requestModel = requestModel;
        _timestamp = timestamp;
    }
    return self;
}

- (NSDictionary <NSString *, NSHTTPCookie *> *)extractCookies:(NSDictionary<NSString *, NSString *> *)headers
                                                 requestModel:(EMSRequestModel *)requestModel {
    NSArray<NSHTTPCookie *> *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:headers
                                                                              forURL:requestModel.url];
    NSMutableDictionary *mutableCookies = [NSMutableDictionary dictionary];
    for (NSHTTPCookie *httpCookie in cookies) {
        mutableCookies[[httpCookie.name lowercaseString]] = httpCookie;
    }
    return [NSDictionary dictionaryWithDictionary:mutableCookies];
}

- (id)parsedBody {
    if (!_parsedBody && _body) {
        _parsedBody = [NSJSONSerialization JSONObjectWithData:_body
                                                      options:0
                                                        error:nil];
    }
    return _parsedBody;
}

@end
