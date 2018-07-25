//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MEConfig;

@interface MEDefaultHeaders : NSObject

+ (NSDictionary *)additionalHeadersWithConfig:(MEConfig *)config;

@end