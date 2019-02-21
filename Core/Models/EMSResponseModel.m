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

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToModel:other];
}

- (BOOL)isEqualToModel:(EMSResponseModel *)model {
    if (self == model)
        return YES;
    if (model == nil)
        return NO;
    if (self.statusCode != model.statusCode)
        return NO;
    if (self.headers != model.headers && ![self.headers isEqualToDictionary:model.headers])
        return NO;
    if (self.cookies != model.cookies && ![self.cookies isEqualToDictionary:model.cookies])
        return NO;
    if (self.requestModel != model.requestModel && ![self.requestModel isEqual:model.requestModel])
        return NO;
    if (self.body != model.body && ![self.body isEqualToData:model.body])
        return NO;
    if (self.timestamp != model.timestamp && ![self.timestamp isEqualToDate:model.timestamp])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [_parsedBody hash];
    hash = hash * 31u + self.statusCode;
    hash = hash * 31u + [self.headers hash];
    hash = hash * 31u + [self.cookies hash];
    hash = hash * 31u + [self.requestModel hash];
    hash = hash * 31u + [self.body hash];
    hash = hash * 31u + [self.timestamp hash];
    return hash;
}


@end
