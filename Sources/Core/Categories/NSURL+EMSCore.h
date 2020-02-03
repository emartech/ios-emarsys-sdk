//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSURL (EMSCore)

+ (NSURL *)urlWithBaseUrl:(NSString *)url
          queryParameters:(NSDictionary<NSString *, NSString *> *)queryParameters;

@end