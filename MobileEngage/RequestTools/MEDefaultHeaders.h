//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSConfig;

@interface MEDefaultHeaders : NSObject

+ (NSDictionary *)additionalHeadersWithConfig:(EMSConfig *)config;

@end