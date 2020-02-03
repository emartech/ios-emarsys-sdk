//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "NSURL+EMSCore.h"

@implementation NSURL (EMSCore)

+ (NSURL *)urlWithBaseUrl:(NSString *)urlString
          queryParameters:(NSDictionary<NSString *, NSString *> *)queryParameters {
    NSParameterAssert(urlString);
    NSParameterAssert(queryParameters);
    NSURL __unused *url = [NSURL URLWithString:urlString];
    NSParameterAssert(url.scheme);
    NSParameterAssert(url.host);

    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"\"`;/?:^%#@&=$+{}<>,| "] invertedSet];
    NSMutableString *fullUrl = [NSMutableString stringWithFormat:@"%@?", urlString];
    [queryParameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [fullUrl appendFormat:@"%@=%@&",
                              [[NSString stringWithFormat:@"%@",
                                                          key] stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters],
                              [[NSString stringWithFormat:@"%@",
                                                          value] stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters]];
    }];
    [fullUrl deleteCharactersInRange:NSMakeRange(fullUrl.length - 1, 1)];
    return [NSURL URLWithString:fullUrl];
}

@end