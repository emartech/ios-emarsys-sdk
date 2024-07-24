//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "NSURL+EMSCore.h"
#import "NSString+EMSCore.h"

@implementation NSURL (EMSCore)

+ (NSURL *)urlWithBaseUrl:(NSString *)urlString
          queryParameters:(NSDictionary<NSString *, NSString *> *)queryParameters {
    NSParameterAssert(urlString);
    NSParameterAssert(queryParameters);
    NSURL __unused *url = [NSURL URLWithString:urlString];
    NSParameterAssert(url.scheme);
    NSParameterAssert(url.host);

    NSMutableString *fullUrl = [NSMutableString stringWithFormat:@"%@?", urlString];
    [queryParameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [fullUrl appendFormat:@"%@=%@&",
                              [key percentEncode],
                              [value percentEncode]];
    }];
    [fullUrl deleteCharactersInRange:NSMakeRange(fullUrl.length - 1, 1)];
    return [NSURL URLWithString:fullUrl];
}

@end
