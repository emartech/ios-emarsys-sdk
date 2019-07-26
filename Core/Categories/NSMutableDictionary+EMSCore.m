//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "NSMutableDictionary+EMSCore.h"


@implementation NSMutableDictionary (EMSCore)

- (id)takeValueForKey:(NSString *)key {
    id value = self[key];
    [self removeObjectForKey:key];
    return value;
}

@end