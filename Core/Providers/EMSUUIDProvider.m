//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSUUIDProvider.h"

@implementation EMSUUIDProvider

- (NSUUID *)provideUUID {
    return [NSUUID UUID];
}

@end