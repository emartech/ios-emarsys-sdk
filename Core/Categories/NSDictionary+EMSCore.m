//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "NSDictionary+EMSCore.h"


@implementation NSDictionary (EMSCore)

- (BOOL)subsetOfDictionary:(NSDictionary *)dictionary {
    BOOL result = NO;

    NSArray *dictKeys = [dictionary allKeys];

    if (!dictionary) {
        result = NO;
    } else if ([dictKeys count] == 0) {
        result = YES;
    } else {
        for (id key in dictKeys) {
            if ([[self allKeys] containsObject:key] && [self[key] isEqual:dictionary[key]]) {
                result = YES;
            }
        }
    }

    return result;
}

- (NSData *)archive {
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

- (nullable id)valueForKey:(id)key
                      type:(Class)expectedClass {
    id result;
    id object = self[key];
    if (object && [object isKindOfClass:expectedClass]) {
        result = object;
    }
    return result;
}

- (nullable NSString *)stringValueForKey:(id)key {
    return [self valueForKey:key
                        type:[NSString class]];
}

- (nullable NSNumber *)numberValueForKey:(id)key {
    return [self valueForKey:key
                        type:[NSNumber class]];
}

- (nullable NSDictionary *)dictionaryValueForKey:(id)key {
    return [self valueForKey:key
                        type:[NSDictionary class]];
}

- (nullable NSArray *)arrayValueForKey:(id)key {
    return [self valueForKey:key
                        type:[NSArray class]];
}

+ (NSDictionary *)dictionaryWithData:(NSData *)data {
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (nullable id)valueForInsensitiveKey:(NSString *)key {
    id result = nil;
    for (id dictKey in self.allKeys) {
        BOOL isString = [dictKey isKindOfClass:[NSString class]];
        if (isString && [[dictKey lowercaseString] isEqualToString:[key lowercaseString]]) {
            result = self[dictKey];
            break;
        }
    }
    return result;
}

@end
