//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EMSRandomProvider : NSObject

- (NSNumber *)provideDoubleUntil:(NSNumber *)until;
@end