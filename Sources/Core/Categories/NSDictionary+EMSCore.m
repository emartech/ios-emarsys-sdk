//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "NSDictionary+EMSCore.h"
#import "EMSStatusLog.h"
#import "EMSMacros.h"
#import "EMSDBTrigger.h"
#import "MEInAppMessage.h"

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
    NSError *error;
    NSData *result = [NSKeyedArchiver archivedDataWithRootObject:self
                                           requiringSecureCoding:NO
                                                           error:&error];
    if (error) {
        NSMutableDictionary *statusDict = [NSMutableDictionary dictionary];
        statusDict[@"error"] = error.localizedDescription;
        NSMutableDictionary *parametersDict = [NSMutableDictionary dictionary];
        parametersDict[@"self"] = [NSDictionary dictionaryWithDictionary:self];
        EMSStatusLog *logEntry = [[EMSStatusLog alloc] initWithClass:[self class]
                                                                 sel:_cmd
                                                          parameters:[NSDictionary dictionaryWithDictionary:parametersDict]
                                                              status:[NSDictionary dictionaryWithDictionary:statusDict]];
        EMSLog(logEntry, LogLevelDebug);
    }
    return result;
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
    NSError *error;
    NSDictionary *result = nil;
    @try {
        result = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithArray:@[[NSNull class], [NSNumber class], [NSString class], [NSArray class], [NSDictionary class]]]
                                                     fromData:data
                                                        error:&error];
    } @catch (NSException *exception) {
        NSMutableDictionary *statusDict = [NSMutableDictionary dictionary];
        statusDict[@"error"] = exception.reason;
        NSMutableDictionary *parametersDict = [NSMutableDictionary dictionary];
        parametersDict[@"base64Data"] = [data base64EncodedStringWithOptions:0];
        EMSStatusLog *logEntry = [[EMSStatusLog alloc] initWithClass:[self class]
                                                                 sel:_cmd
                                                          parameters:[NSDictionary dictionaryWithDictionary:parametersDict]
                                                              status:[NSDictionary dictionaryWithDictionary:statusDict]];
        EMSLog(logEntry, LogLevelError);
    }

    if (error && data) {
        NSMutableDictionary *statusDict = [NSMutableDictionary dictionary];
        statusDict[@"error"] = error.localizedDescription;
        NSMutableDictionary *parametersDict = [NSMutableDictionary dictionary];
        parametersDict[@"data"] = [[NSString alloc] initWithData:data
                                                        encoding:NSUTF8StringEncoding];

        EMSStatusLog *logEntry = [[EMSStatusLog alloc] initWithClass:[self class]
                                                                 sel:_cmd
                                                          parameters:[NSDictionary dictionaryWithDictionary:parametersDict]
                                                              status:[NSDictionary dictionaryWithDictionary:statusDict]];
        EMSLog(logEntry, LogLevelDebug);
    }
    return result;
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

- (nullable id)nullSafeValueForKey:(NSString *)key {
    id result = self[key];
    if ([result isKindOfClass:[NSNull class]]) {
        result = nil;
    }
    return result;
}

- (NSDictionary *)mergeWithDictionary:(NSDictionary *)dictionary {
    NSMutableDictionary *mutableSelf = [self mutableCopy];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSDictionary *selfValue = mutableSelf[key];
        if ([obj isKindOfClass:[NSDictionary class]] && selfValue) {
            mutableSelf[key] = [selfValue mergeWithDictionary:obj];
        } else {
            mutableSelf[key] = obj;
        };
    }];
    return [NSDictionary dictionaryWithDictionary:mutableSelf];
}

- (NSDictionary *)dictionaryWithAllowedTypes:(NSSet<Class> *)allowedTypes {
    NSMutableDictionary *result = [self mutableCopy];
    for (NSString *key in result.allKeys) {
        id value = [self valueWithAllowedTypes:allowedTypes
                                        object:result[key]];
        result[key] = value;
    }
    return [NSDictionary dictionaryWithDictionary:result];
}

- (NSArray *)arrayWithAllowedTypes:(NSSet<Class> *)allowedTypes
                            object:(id)object {
    NSMutableArray *mutableArray = [object mutableCopy];
    for (NSInteger i = mutableArray.count - 1; i >= 0; --i) {
        id value = [self valueWithAllowedTypes:allowedTypes
                                        object:mutableArray[(NSUInteger) i]];
        mutableArray[(NSUInteger) i] = value;
    }
    return [NSArray arrayWithArray:mutableArray];
}

- (id)valueWithAllowedTypes:(NSSet<Class> *)allowedTypes
                     object:(id)object {
    id result = object;
    if ([object isKindOfClass:[NSDictionary class]]) {
        result = [object dictionaryWithAllowedTypes:allowedTypes];
    } else if ([object isKindOfClass:[NSArray class]]) {
        result = [self arrayWithAllowedTypes:allowedTypes
                                      object:object];
    } else if (![self isKindOfAllowedTypes:allowedTypes
                                    object:object]) {
        result = [object description];
    }
    return result;
}

- (BOOL)isKindOfAllowedTypes:(NSSet<Class> *)classes
                      object:(id)object {
    BOOL result = NO;
    for (Class aClass in classes) {
        if ([object isKindOfClass:aClass]) {
            result = YES;
            break;
        }
    }
    return result;
}

@end
