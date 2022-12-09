//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "NSMutableDictionary+EMSCore.h"


@implementation NSMutableDictionary (EMSCore)

- (id)takeValueForKey:(NSString *)key {
    id value = self[key];
    if ([value isMemberOfClass:[NSNull class]]) {
        value = nil;
    }
    [self removeObjectForKey:key];
    return value;
}

@end