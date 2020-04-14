//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSRandomProvider.h"

@implementation EMSRandomProvider {

}

- (NSNumber *)provideDoubleUntil:(NSNumber *)until {
    return @((double) arc4random() / UINT32_MAX * [until doubleValue]);
}

@end