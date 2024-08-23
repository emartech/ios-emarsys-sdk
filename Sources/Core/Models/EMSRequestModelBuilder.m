//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSRequestModelBuilder.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSMacros.h"
#import "EMSStatusLog.h"

@implementation EMSRequestModelBuilder


- (instancetype)initWithTimestampProvider:(EMSTimestampProvider *)timestampProvider
                             uuidProvider:(EMSUUIDProvider *)uuidProvider {
    if (self = [super init]) {
        _requestId = [uuidProvider provideUUIDString];
        _timestamp = [timestampProvider provideTimestamp];
        _requestMethod = @"POST";
        _expiry = DEFAULT_REQUESTMODEL_EXPIRY;
    }
    return self;
}


- (EMSRequestModelBuilder *)setMethod:(HTTPMethod)method {
    switch (method) {
        case HTTPMethodPOST:
            _requestMethod = @"POST";
            break;
        case HTTPMethodPUT:
            _requestMethod = @"PUT";
            break;
        case HTTPMethodGET:
            _requestMethod = @"GET";
            break;
        case HTTPMethodDELETE:
            _requestMethod = @"DELETE";
            break;
    }
    return self;
}

- (EMSRequestModelBuilder *)setUrl:(NSString *)url {
    NSURL *urlToCheck = [NSURL URLWithString:url];
    if (urlToCheck && urlToCheck.scheme && urlToCheck.host) {
        _requestUrl = urlToCheck;
    } else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"url"] = url;
        EMSLog([[EMSStatusLog alloc] initWithClass:[self class]
                                               sel:_cmd
                                        parameters:parameters
                                            status:nil], LogLevelError);
    }
    return self;
}

- (EMSRequestModelBuilder *)setUrl:(NSString *)url
                   queryParameters:(NSDictionary<NSString *, NSString *> *)queryParameters {
    NSURL *urlToCheck = [NSURL URLWithString:url];
    if (urlToCheck && urlToCheck.scheme && urlToCheck.host) {
        NSURLComponents *components = [[NSURLComponents alloc] initWithURL:urlToCheck
                                                   resolvingAgainstBaseURL:YES];
        NSMutableArray *queryItems = [NSMutableArray array];
        for (NSString *name in queryParameters.allKeys) {
            NSString *const queryParameterValue = queryParameters[name];
            if ([queryParameterValue isKindOfClass:[NSString class]]) {
                [queryItems addObject:[[NSURLQueryItem alloc] initWithName:name
                                                                     value:queryParameterValue]];
            }
        }
        [components setQueryItems:queryItems];
        _requestUrl = [components URL];
    } else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"url"] = url;
        parameters[@"queryParameters"] = queryParameters;
        EMSLog([[EMSStatusLog alloc] initWithClass:[self class]
                                               sel:_cmd
                                        parameters:parameters
                                            status:nil], LogLevelError);
    }
    return self;
}

- (EMSRequestModelBuilder *)setExpiry:(NSTimeInterval)expiry {
    _expiry = expiry;
    return self;
}

- (EMSRequestModelBuilder *)setPayload:(NSDictionary<NSString *, id> *)payload {
    _payload = payload;
    return self;
}

- (EMSRequestModelBuilder *)setHeaders:(NSDictionary<NSString *, NSString *> *)headers {
    _headers = headers;
    return self;
}

- (EMSRequestModelBuilder *)setExtras:(NSDictionary<NSString *, NSString *> *)extras {
    _extras = extras;
    return self;
}

@end
