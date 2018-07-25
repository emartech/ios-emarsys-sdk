//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSDate (EMSCore)

- (NSNumber *)numberValueInMillis;

- (NSNumber *)numberValueInMillisFromDate:(NSDate *)date;

- (NSString *)stringValueInUTC;

@end