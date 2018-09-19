//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSUUIDProvider.h"

@implementation EMSUUIDProvider

- (NSString *)provideUUIDString {
    return [[NSUUID UUID] UUIDString];
}

@end