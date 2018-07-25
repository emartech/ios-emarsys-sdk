//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSRequestModel;


@interface MERequestTools : NSObject

+ (BOOL)isRequestCustomEvent:(EMSRequestModel *)request;

@end