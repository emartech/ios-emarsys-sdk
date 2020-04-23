//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "NSDictionary+EMSCore.h"
#import "EMSStatusLog.h"
#import "EMSMacros.h"

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
        parametersDict[@"data"] = [[NSString alloc] initWithData:data
                                                        encoding:NSASCIIStringEncoding];
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

@end
