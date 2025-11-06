//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "NSURL+EMSCore.h"
#import "NSString+EMSCore.h"

@implementation NSURL (EMSCore)

+ (NSURL *)urlWithBaseUrl:(NSString *)urlString
          queryParameters:(NSDictionary<NSString *, NSString *> *)queryParameters {
    NSParameterAssert(urlString);
    NSURLComponents *components = [NSURLComponents componentsWithString:urlString];
    NSAssert((components), @"Invalid parameter not satisfying: %@", urlString);
    NSAssert((components.host && [components.host length] > 0), @"Invalid parameter not satisfying: %@", urlString);
    NSAssert((components.scheme), @"Invalid parameter not satisfying: %@", urlString);
    
    NSMutableString *fullUrl = [NSMutableString stringWithFormat:@"%@?", urlString];
        [queryParameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
            [fullUrl appendFormat:@"%@=%@&",
             [[NSString stringWithFormat:@"%@", key] percentEncode],
             [[NSString stringWithFormat:@"%@", value] percentEncode]];
        }];
        [fullUrl deleteCharactersInRange:NSMakeRange(fullUrl.length - 1, 1)];
    return [NSURL URLWithString:fullUrl];
}

@end
