//
// Copyright (c) 2020 Emarsys. All rights reserved.
//
#import "EMSStorage.h"
#import "EMSMacros.h"
#import "EMSStatusLog.h"

@interface EMSStorage ()

@property(nonatomic, strong) NSArray <NSUserDefaults *> *userDefaultsArray;
@property(nonatomic, strong) NSUserDefaults *fallbackUserDefaults;
@property(nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation EMSStorage

- (instancetype)initWithSuiteNames:(NSArray<NSString *> *)suiteNames
                       accessGroup:(nullable NSString *)accessGroup {
    NSParameterAssert(suiteNames);
    if (self = [super init]) {
        NSMutableArray <NSUserDefaults *> *mutableUserDefaults = [NSMutableArray new];
        for (NSString *suiteName in suiteNames) {

            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:suiteName];
            [mutableUserDefaults addObject:userDefaults];
        }
        _accessGroup = accessGroup;
        _userDefaultsArray = [NSArray arrayWithArray:mutableUserDefaults];
        _fallbackUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.emarsys.sdk"];
    }
    return self;
}

- (void)setData:(nullable NSData *)data
         forKey:(NSString *)key {
    OSStatus status = [self setData:data
                             forKey:key
                        accessGroup:nil];
    if (status != errSecSuccess) {
        [self.fallbackUserDefaults setObject:data
                                      forKey:key];

        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"data"] = [[NSString alloc] initWithData:data
                                                    encoding:NSUTF8StringEncoding];
        parameters[@"key"] = key;
        NSMutableDictionary *statusDict = [NSMutableDictionary dictionary];
        statusDict[@"osStatus"] = @(status);
        EMSStatusLog *logEntry = [[EMSStatusLog alloc] initWithClass:[self class]
                                                                 sel:_cmd
                                                          parameters:[NSDictionary dictionaryWithDictionary:parameters]
                                                              status:[NSDictionary dictionaryWithDictionary:statusDict]];
        EMSLog(logEntry, LogLevelDebug);
    }
}

- (OSStatus)setData:(nullable NSData *)data
             forKey:(NSString *)key
        accessGroup:(nullable NSString *)accessGroup {
    NSParameterAssert(key);
    NSMutableDictionary *mutableQuery = [NSMutableDictionary new];
    mutableQuery[(id) kSecAttrAccount] = key;
    mutableQuery[(id) kSecClass] = (id) kSecClassGenericPassword;
    mutableQuery[(id) kSecAttrAccessible] = (id) kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
    mutableQuery[(id) kSecValueData] = data;

    mutableQuery[(id) kSecAttrAccessGroup] = accessGroup;

    NSDictionary *query = [NSDictionary dictionaryWithDictionary:mutableQuery];

    OSStatus status = [self storeInSecureStorageWithQuery:query];
    if (status == errSecDuplicateItem) {
        NSMutableDictionary *mutableDeleteQuery = [query mutableCopy];
        [mutableDeleteQuery removeObjectForKey:(id) kSecAttrAccessible];
        NSDictionary *deleteQuery = [NSDictionary dictionaryWithDictionary:mutableDeleteQuery];

        SecItemDelete((__bridge CFDictionaryRef) deleteQuery);
        status = [self storeInSecureStorageWithQuery:query];
    }
    return status;
}

- (OSStatus)storeInSecureStorageWithQuery:(NSDictionary *)query {
    return SecItemAdd((__bridge CFDictionaryRef) query, NULL);
}

- (void)setString:(nullable NSString *)string
           forKey:(NSString *)key {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [self setData:data
           forKey:key];
}

- (void)setNumber:(nullable NSNumber *)number
           forKey:(NSString *)key {
    NSError *error;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:number
                                         requiringSecureCoding:NO
                                                         error:&error];
    if (error) {
        NSMutableDictionary *parameterDictionary = [NSMutableDictionary new];
        parameterDictionary[@"number"] = number;
        parameterDictionary[@"key"] = key;
        NSMutableDictionary *statusDictionary = [NSMutableDictionary new];
        if (data) {
            statusDictionary[@"data"] = [[NSString alloc] initWithData:data
                                                              encoding:NSUTF8StringEncoding];
        }
        statusDictionary[@"error"] = error.localizedDescription;
        EMSStatusLog *log = [[EMSStatusLog alloc] initWithClass:self.class
                                                            sel:_cmd
                                                     parameters:parameterDictionary
                                                         status:statusDictionary];
        EMSLog(log, LogLevelDebug);
    }
    [self setData:data
           forKey:key];
}

- (void)setDictionary:(nullable NSDictionary *)dictionary
               forKey:(NSString *)key {
    NSError *error;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dictionary
                                         requiringSecureCoding:NO
                                                         error:&error];
    if (error) {
        NSMutableDictionary *parameterDictionary = [NSMutableDictionary new];
        parameterDictionary[@"dictionary"] = dictionary;
        parameterDictionary[@"key"] = key;
        NSMutableDictionary *statusDictionary = [NSMutableDictionary new];
        if (data) {
            statusDictionary[@"data"] = [[NSString alloc] initWithData:data
                                                              encoding:NSUTF8StringEncoding];
        }
        statusDictionary[@"error"] = error.localizedDescription;
        EMSStatusLog *log = [[EMSStatusLog alloc] initWithClass:self.class
                                                            sel:_cmd
                                                     parameters:parameterDictionary
                                                         status:statusDictionary];
        EMSLog(log, LogLevelDebug);
    }

    [self setData:data
           forKey:key];
}

- (nullable NSData *)dataForKey:(NSString *)key {
    NSData *result = [self dataForKey:key
                          accessGroup:nil];
    if (!result) {
        for (NSUserDefaults *userDefaults in self.userDefaultsArray) {
            id userDefaultsValue = [userDefaults objectForKey:key];

            if ([userDefaultsValue isKindOfClass:[NSString class]]) {
                userDefaultsValue = [userDefaultsValue dataUsingEncoding:NSUTF8StringEncoding];
            } else if ([userDefaultsValue isKindOfClass:[NSNumber class]]) {
                NSError *error;
                userDefaultsValue = [NSKeyedArchiver archivedDataWithRootObject:userDefaultsValue
                                                          requiringSecureCoding:NO
                                                                          error:&error];
                if (error) {
                    NSMutableDictionary *parameterDictionary = [NSMutableDictionary new];
                    parameterDictionary[@"userDefaultsValue"] = userDefaultsValue;
                    parameterDictionary[@"key"] = key;
                    NSMutableDictionary *statusDictionary = [NSMutableDictionary new];
                    if (userDefaultsValue) {
                        statusDictionary[@"data"] = [[NSString alloc] initWithData:userDefaultsValue
                                                                          encoding:NSUTF8StringEncoding];
                    }
                    statusDictionary[@"error"] = error.localizedDescription;
                    EMSStatusLog *log = [[EMSStatusLog alloc] initWithClass:self.class
                                                                        sel:_cmd
                                                                 parameters:parameterDictionary
                                                                     status:statusDictionary];
                    EMSLog(log, LogLevelDebug);
                }
            } else if ([userDefaultsValue isKindOfClass:[NSDictionary class]]) {
                NSError *error;
                userDefaultsValue = [NSKeyedArchiver archivedDataWithRootObject:userDefaultsValue
                                                          requiringSecureCoding:NO
                                                                          error:&error];
                if (error) {
                    NSMutableDictionary *parameterDictionary = [NSMutableDictionary new];
                    parameterDictionary[@"userDefaultsValue"] = userDefaultsValue;
                    parameterDictionary[@"key"] = key;
                    NSMutableDictionary *statusDictionary = [NSMutableDictionary new];
                    if (userDefaultsValue) {
                        statusDictionary[@"data"] = [[NSString alloc] initWithData:userDefaultsValue
                                                                          encoding:NSUTF8StringEncoding];
                    }
                    statusDictionary[@"error"] = error.localizedDescription;
                    EMSStatusLog *log = [[EMSStatusLog alloc] initWithClass:self.class
                                                                        sel:_cmd
                                                                 parameters:parameterDictionary
                                                                     status:statusDictionary];
                    EMSLog(log, LogLevelDebug);
                }
            }
            if (userDefaultsValue) {
                [userDefaults removeObjectForKey:key];
                [self setData:userDefaultsValue
                       forKey:key];
                result = userDefaultsValue;
                break;
            }
        }
    }

    return result;
}

- (nullable NSData *)dataForKey:(NSString *)key
                    accessGroup:(nullable NSString *)accessGroup {
    NSParameterAssert(key);
    NSData *result;
    NSMutableDictionary *mutableQuery = [NSMutableDictionary new];
    mutableQuery[(id) kSecClass] = (id) kSecClassGenericPassword;
    mutableQuery[(id) kSecAttrAccount] = key;
    mutableQuery[(id) kSecReturnData] = (id) kCFBooleanTrue;
    mutableQuery[(id) kSecReturnAttributes] = (id) kCFBooleanTrue;
    mutableQuery[(id) kSecAttrAccessible] = (id) kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;

    mutableQuery[(id) kSecAttrAccessGroup] = accessGroup;

    NSDictionary *query = [NSDictionary dictionaryWithDictionary:mutableQuery];

    CFTypeRef resultRef = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef) query, &resultRef);
    if (status == errSecSuccess) {
        NSDictionary *resultDict = (__bridge NSDictionary *) resultRef;
        NSString *returnedAccessGroup = resultDict[(id) kSecAttrAccessGroup];
        if ((!accessGroup && ![returnedAccessGroup isEqual:self.accessGroup]) || (accessGroup && [accessGroup isEqual:returnedAccessGroup])) {
            result = resultDict[(id) kSecValueData];
        }
    } else if (status != errSecItemNotFound) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"key"] = key;
        NSMutableDictionary *statusDict = [NSMutableDictionary dictionary];
        statusDict[@"osStatus"] = @(status);
        EMSStatusLog *logEntry = [[EMSStatusLog alloc] initWithClass:[self class]
                                                                 sel:_cmd
                                                          parameters:[NSDictionary dictionaryWithDictionary:parameters]
                                                              status:[NSDictionary dictionaryWithDictionary:statusDict]];
        EMSLog(logEntry, LogLevelDebug);
    }

    if (resultRef) {
        CFRelease(resultRef);
    }
    return result;
}

- (nullable NSString *)stringForKey:(NSString *)key {
    NSData *data = [self dataForKey:key];

    return data ? [[NSString alloc] initWithData:data
                                        encoding:NSUTF8StringEncoding] : nil;
}

- (nullable NSNumber *)numberForKey:(NSString *)key {
    NSData *data = [self dataForKey:key];
    NSError *error;
    NSNumber *result = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSNumber class]
                                                         fromData:data
                                                            error:&error];
    if (error) {
        NSMutableDictionary *parameterDictionary = [NSMutableDictionary new];
        parameterDictionary[@"key"] = key;
        NSMutableDictionary *statusDictionary = [NSMutableDictionary new];
        if (result) {
            statusDictionary[@"data"] = result;
        }
        statusDictionary[@"error"] = error.localizedDescription;
        EMSStatusLog *log = [[EMSStatusLog alloc] initWithClass:self.class
                                                            sel:_cmd
                                                     parameters:parameterDictionary
                                                         status:statusDictionary];
        EMSLog(log, LogLevelDebug);
    }
    return result;
}

- (nullable NSDictionary *)dictionaryForKey:(NSString *)key {
    NSData *data = [self dataForKey:key];
    NSError *error;
    NSDictionary *result =  [NSKeyedUnarchiver unarchivedObjectOfClass:[NSDictionary class]
                                             fromData:data
                                                error:&error];
    if (error) {
        NSMutableDictionary *parameterDictionary = [NSMutableDictionary new];
        parameterDictionary[@"key"] = key;
        NSMutableDictionary *statusDictionary = [NSMutableDictionary new];
        if (result) {
            statusDictionary[@"data"] = result;
        }
        statusDictionary[@"error"] = error.localizedDescription;
        EMSStatusLog *log = [[EMSStatusLog alloc] initWithClass:self.class
                                                            sel:_cmd
                                                     parameters:parameterDictionary
                                                         status:statusDictionary];
        EMSLog(log, LogLevelDebug);
    }
    return result;
}

- (NSData *)objectForKeyedSubscript:(NSString *)key {
    return [self dataForKey:key];
}

- (void)setObject:(NSData *)obj
forKeyedSubscript:(NSString *)key {
    [self setData:obj
           forKey:key];
}

- (void)setSharedData:(NSData *)data
               forKey:(NSString *)key {
    OSStatus status = [self setData:data
                             forKey:key
                        accessGroup:self.accessGroup];
    if (status != errSecSuccess) {
        [self setData:data
               forKey:key];
    }
}

- (nullable NSData *)sharedDataForKey:(NSString *)key {
    NSData *result = [self dataForKey:key
                          accessGroup:self.accessGroup];
    if (!result) {
        result = [self dataForKey:key];
        [self setSharedData:result
                     forKey:key];
    }
    return result;
}

@end