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
         [[NSString stringWithFormat:@"%@", key] percentEncode],
         [[NSString stringWithFormat:@"%@", value] percentEncode]];
    }];
    [fullUrl deleteCharactersInRange:NSMakeRange(fullUrl.length - 1, 1)];
    return [NSURL URLWithString:fullUrl];
}

- (BOOL)isEqualIgnoringQueryParamOrderTo:(NSURL *)otherURL {
    BOOL isEqual = YES;
    
    if (![self.scheme isEqualToString:otherURL.scheme] ||
        ![self.host isEqualToString:otherURL.host] ||
        ![self.path isEqualToString:otherURL.path]) {
        isEqual = NO;
    }
    
    if (isEqual) {
        NSDictionary *queryParams1 = [self queryParams];
        NSDictionary *queryParams2 = [otherURL queryParams];
        
        if (queryParams1 || queryParams2) {
            if (![queryParams1 isEqualToDictionary:queryParams2]) {
                isEqual = NO;
            }
        }
    }
    
    return isEqual;
}

- (NSDictionary *)queryParams {
    NSMutableDictionary *queryParams = [NSMutableDictionary dictionary];
    NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
    
    for (NSURLQueryItem *queryItem in components.queryItems) {
        queryParams[queryItem.name] = queryItem.value;
    }
    
    return queryParams;
}

@end
