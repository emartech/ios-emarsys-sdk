//
// Copyright (c) 2020 Emarsys. All rights reserved.
//
#import "EMSStorage.h"
#import "EMSMacros.h"
#import "EMSStatusLog.h"
#import "NSOperationQueue+EMSCore.h"

@interface EMSStorage ()

@property(nonatomic, strong) NSArray <NSUserDefaults *> *userDefaultsArray;
@property(nonatomic, strong) NSUserDefaults *fallbackUserDefaults;
@property(nonatomic, strong) NSOperationQueue *operationQueue;

- (OSStatus)createValue:(NSData *)value
                 forKey:(NSString *)key
        withAccessGroup:(nullable NSString *)accessGroup;

- (nullable NSData *)readValueForKey:(NSString *)key
                     withAccessGroup:(nullable NSString *)accessGroup;

- (OSStatus)updateValue:(NSData *)value
                 forKey:(NSString *)key
        withAccessGroup:(nullable NSString *)accessGroup;

- (OSStatus)deleteValueForKey:(NSString *)key
              withAccessGroup:(nullable NSString *)accessGroup;


- (NSMutableDictionary *)createQueryWithKey:(NSString *)key
                                accessGroup:(nullable NSString *)accessGroup;

- (NSMutableDictionary *)appendAccessModifierToQuery:(NSMutableDictionary *)query;

- (NSMutableDictionary *)appendResultAttributesToQuery:(NSMutableDictionary *)query;

- (NSMutableDictionary *)appendValueToQuery:(NSMutableDictionary *)query
                                      value:(NSData *)value;


- (OSStatus)duplicateItemRemovingMethodExecution:(NSData *)value
                                             key:(NSString *)key
                                     accessGroup:(nullable NSString *)accessGroup
                                     methodBlock:(OSStatus(^)(NSData *value, NSString *key,  NSString * _Nullable accessGroup))methodBlock;

@end

@implementation EMSStorage

- (instancetype)initWithSuiteNames:(NSArray<NSString *> *)suiteNames
                       accessGroup:(nullable NSString *)accessGroup
                    operationQueue:(nonnull NSOperationQueue *)operationQueue {
    NSParameterAssert(suiteNames);
    NSParameterAssert(operationQueue);
    if (self = [super init]) {
        _operationQueue = operationQueue;
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
        if (data) {
            parameters[@"data"] = [[NSString alloc] initWithData:data
                                                        encoding:NSUTF8StringEncoding];
        }
        parameters[@"key"] = key;
        NSMutableDictionary *statusDict = [NSMutableDictionary dictionary];
        statusDict[@"osStatus"] = @(status);
        if (self.accessGroup) {
            statusDict[@"self.accessGroup"] = self.accessGroup;
        }
        statusDict[@"accessGroupWasUsed"] = @NO;
        EMSStatusLog *logEntry = [[EMSStatusLog alloc] initWithClass:[self class]
                                                                 sel:_cmd
                                                          parameters:[NSDictionary dictionaryWithDictionary:parameters]
                                                              status:[NSDictionary dictionaryWithDictionary:statusDict]];
        EMSLog(logEntry, LogLevelError);
    }
}

- (OSStatus)setData:(nullable NSData *)data
             forKey:(NSString *)key
        accessGroup:(nullable NSString *)accessGroup {
    NSParameterAssert(key);
    __block OSStatus status = 0;
    [self.operationQueue runSynchronized:^{
        NSData *existingValue = [self readValueForKey:key
                                      withAccessGroup:accessGroup];
        if (data) {
            if (existingValue) {
                status = [self updateValue:data
                                    forKey:key
                           withAccessGroup:accessGroup];
            } else {
                status = [self createValue:data
                                    forKey:key
                           withAccessGroup:accessGroup];
            }
        } else {
            if (existingValue) {
                status = [self deleteValueForKey:key
                                 withAccessGroup:accessGroup];
            }
        }
    }];
    return status;
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
    NSString *numberString = [number stringValue];
    NSData *data = [numberString dataUsingEncoding:NSUTF8StringEncoding];

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
    NSData *data = nil;
    NSError *error = nil;
    NSMutableDictionary *statusDictionary = [NSMutableDictionary new];
    if (dictionary) {
        @try {
            data = [NSJSONSerialization dataWithJSONObject:dictionary
                                                   options:0
                                                     error:&error];
        } @catch (NSException *exception) {
            statusDictionary[@"dictJsonException"] = exception.reason;
        } @finally {
            if (error) {
                statusDictionary[@"dictJsonError"] = error.description;
            }
        }
    }
    if (error) {
        NSMutableDictionary *parameterDictionary = [NSMutableDictionary new];
        parameterDictionary[@"dictionary"] = dictionary;
        parameterDictionary[@"key"] = key;
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
                NSString *stringValue = [userDefaultsValue stringValue];
                userDefaultsValue = [stringValue dataUsingEncoding: NSUTF8StringEncoding];

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
                NSMutableDictionary *statusDictionary = [NSMutableDictionary new];
                @try {
                    userDefaultsValue = [NSJSONSerialization dataWithJSONObject:userDefaultsValue
                                                                        options:0
                                                                          error:&error];
                } @catch (NSException *exception) {
                    statusDictionary[@"userDefaultsFallbackJsonException"] = exception.reason;
                } @finally {
                    if (error) {
                        statusDictionary[@"userDefaultsFallbackJsonError"] = error.description;
                    }
                }
                if (error) {
                    NSMutableDictionary *parameterDictionary = [NSMutableDictionary new];
                    parameterDictionary[@"userDefaultsValue"] = userDefaultsValue;
                    parameterDictionary[@"key"] = key;
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
    __block NSData *result = nil;
    [self.operationQueue runSynchronized:^{
        result = [self readValueForKey:key
                       withAccessGroup:accessGroup];
        
    }];
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
    NSNumber *result = nil;
    if (data) {
        NSString *numberString = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];

        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        result = [formatter numberFromString:numberString];
    }

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
    NSDictionary *result = nil;
    NSMutableDictionary *statusDictionary = [NSMutableDictionary new];
    if (data) {
        @try {
            result = [NSJSONSerialization JSONObjectWithData:data
                                                     options:0
                                                       error:&error];
        } @catch (NSException *exception) {
            statusDictionary[@"dataToDictJsonException"] = exception.reason;
        } @finally {
            if (error) {
                statusDictionary[@"dataToDictJsonError"] = error.description;
            }
        }
    }
    if (error) {
        NSMutableDictionary *parameterDictionary = [NSMutableDictionary new];
        parameterDictionary[@"key"] = key;
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

- (NSMutableDictionary *)createQueryWithKey:(NSString *)key
                                accessGroup:(nullable NSString *)accessGroup {
    NSMutableDictionary *mutableQuery = [NSMutableDictionary new];
    mutableQuery[(id) kSecClass] = (id) kSecClassGenericPassword;
    mutableQuery[(id) kSecAttrAccount] = key;
    if (accessGroup) {
        mutableQuery[(id) kSecAttrAccessGroup] = accessGroup;
    }
    return mutableQuery;
}

- (NSMutableDictionary *)appendAccessModifierToQuery:(NSMutableDictionary *)query {
    query[(id) kSecAttrAccessible] = (id) kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
    return query;
}

- (NSMutableDictionary *)appendResultAttributesToQuery:(NSMutableDictionary *)query {
    query[(id) kSecReturnData] = (id) kCFBooleanTrue;
    query[(id) kSecReturnAttributes] = (id) kCFBooleanTrue;
    return query;
}

- (NSMutableDictionary *)appendValueToQuery:(NSMutableDictionary *)query
                                      value:(NSData *)value {
    query[(id) kSecValueData] = value;
    return query;
}

- (OSStatus)createValue:(NSData *)value
                 forKey:(NSString *)key
        withAccessGroup:(nullable NSString *)accessGroup {
    __weak typeof(self) weakSelf = self;
    return [self duplicateItemRemovingMethodExecution:value
                                                  key:key
                                          accessGroup:accessGroup
                                          methodBlock:^OSStatus(NSData *value, NSString *key, NSString * _Nullable accessGroup) {
        OSStatus result;
        NSMutableDictionary *mutableQuery = [weakSelf createQueryWithKey:key
                                                             accessGroup:accessGroup];
        mutableQuery = [weakSelf appendAccessModifierToQuery:mutableQuery];
        mutableQuery = [weakSelf appendValueToQuery:mutableQuery
                                              value:value];
        NSDictionary *query = [NSDictionary dictionaryWithDictionary:mutableQuery];
        result = SecItemAdd((__bridge CFDictionaryRef) query, NULL);
        return result;
    }];
}

- (nullable NSData *)readValueForKey:(NSString *)key
                     withAccessGroup:(nullable NSString *)accessGroup {
    NSData *result = nil;
    NSMutableDictionary *mutableQuery = [self createQueryWithKey:key
                                                     accessGroup:accessGroup];
    mutableQuery = [self appendResultAttributesToQuery:mutableQuery];
    NSDictionary *query = [NSDictionary dictionaryWithDictionary:mutableQuery];
    
    CFTypeRef resultRef = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef) query, &resultRef);
    if (status == errSecSuccess) {
        NSDictionary *resultDict = (__bridge NSDictionary *) resultRef;
        NSString *returnedAccessGroup = resultDict[(id) kSecAttrAccessGroup];
        if ((accessGroup && [returnedAccessGroup isEqual:accessGroup]) || !accessGroup) {
            result = resultDict[(id) kSecValueData];
        } else {
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            parameters[@"key"] = key;
            parameters[@"accessGroup"] = accessGroup;
            NSMutableDictionary *statusDict = [NSMutableDictionary dictionary];
            statusDict[@"osStatus"] = [NSString stringWithFormat:@"%d", status];
            statusDict[@"returnedAccessGroup"] = returnedAccessGroup;
            EMSStatusLog *logEntry = [[EMSStatusLog alloc] initWithClass:[self class]
                                                                     sel:_cmd
                                                              parameters:[NSDictionary dictionaryWithDictionary:parameters]
                                                                  status:[NSDictionary dictionaryWithDictionary:statusDict]];
            EMSLog(logEntry, LogLevelError);
        }
    }
    if (resultRef) {
        CFRelease(resultRef);
    }
    return result;
}

- (OSStatus)updateValue:(NSData *)value
                 forKey:(NSString *)key
        withAccessGroup:(nullable NSString *)accessGroup {
    __weak typeof(self) weakSelf = self;
    return [self duplicateItemRemovingMethodExecution:value
                                                  key:key
                                          accessGroup:accessGroup
                                          methodBlock:^OSStatus(NSData *value, NSString *key, NSString * _Nullable accessGroup) {
        OSStatus result;
        NSDictionary *query = [weakSelf createQueryWithKey:key
                                               accessGroup:accessGroup];
        NSMutableDictionary *attributesDictionary = [NSMutableDictionary dictionary];
        attributesDictionary = [weakSelf appendValueToQuery:attributesDictionary
                                                      value:value];
        result = SecItemUpdate((__bridge CFDictionaryRef) query, (__bridge CFDictionaryRef) attributesDictionary);
        return result;
    }];
}

- (OSStatus)deleteValueForKey:(NSString *)key
              withAccessGroup:(nullable NSString *)accessGroup {
    OSStatus result;
    NSMutableDictionary *mutableQuery = [self createQueryWithKey:key
                                                     accessGroup:accessGroup];
    NSDictionary *query = [NSDictionary dictionaryWithDictionary:mutableQuery];
    result = SecItemDelete((__bridge CFDictionaryRef) query);
    return result;
}

- (OSStatus)duplicateItemRemovingMethodExecution:(NSData *)value
                                             key:(NSString *)key
                                     accessGroup:(nullable NSString *)accessGroup
                                     methodBlock:(OSStatus(^)(NSData *value, NSString *key,  NSString * _Nullable accessGroup))methodBlock {
    OSStatus result = methodBlock(value, key, accessGroup);
    if (result == errSecDuplicateItem) {
        OSStatus deleteResult = [self deleteValueForKey:key
                                        withAccessGroup:accessGroup];
        if (deleteResult == errSecSuccess) {
            result = methodBlock(value, key, accessGroup);
        } else {
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            parameters[@"key"] = key;
            parameters[@"value"] = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
            parameters[@"accessGroup"] = accessGroup;
            NSMutableDictionary *statusDict = [NSMutableDictionary dictionary];
            statusDict[@"deleteOsStatus"] = [NSString stringWithFormat:@"%d", deleteResult];
            statusDict[@"osStatus"] = [NSString stringWithFormat:@"%d", result];;
            EMSStatusLog *logEntry = [[EMSStatusLog alloc] initWithClass:[self class]
                                                                     sel:_cmd
                                                              parameters:[NSDictionary dictionaryWithDictionary:parameters]
                                                                  status:[NSDictionary dictionaryWithDictionary:statusDict]];
            EMSLog(logEntry, LogLevelError);
        }
    }
    return result;
}

@end
