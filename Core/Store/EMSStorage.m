//
// Copyright (c) 2020 Emarsys. All rights reserved.
//
#import "EMSStorage.h"
#import "EMSMacros.h"
#import "EMSStatusLog.h"

@interface EMSStorage ()

@property(nonatomic, strong) NSArray <NSUserDefaults *> *userDefaultsArray;
@property(nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation EMSStorage

- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue
                            suiteNames:(NSArray<NSString *> *)suiteNames {
    NSParameterAssert(operationQueue);
    NSParameterAssert(suiteNames);

    if (self = [super init]) {
        _operationQueue = operationQueue;
        NSMutableArray <NSUserDefaults *> *mutableUserDefaults = [NSMutableArray new];
        for (NSString *suiteName in suiteNames) {

            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:suiteName];
            [mutableUserDefaults addObject:userDefaults];
        }
        _userDefaultsArray = [NSArray arrayWithArray:mutableUserDefaults];
    }
    return self;
}

- (void)setData:(nullable NSData *)data
         forKey:(NSString *)key {
    NSParameterAssert(key);
    [self.operationQueue addOperationWithBlock:^{
        NSMutableDictionary *mutableQuery = [NSMutableDictionary new];
        mutableQuery[(id) kSecAttrAccount] = key;
        mutableQuery[(id) kSecClass] = (id) kSecClassGenericPassword;
        mutableQuery[(id) kSecAttrAccessible] = (id) kSecAttrAccessibleWhenUnlockedThisDeviceOnly;
        mutableQuery[(id) kSecValueData] = data;

        NSDictionary *query = [NSDictionary dictionaryWithDictionary:mutableQuery];

        OSStatus status = SecItemAdd((__bridge CFDictionaryRef) query, NULL);
        if (status == errSecDuplicateItem) {
            SecItemDelete((__bridge CFDictionaryRef) query);
            SecItemAdd((__bridge CFDictionaryRef) query, NULL);
        } else if (status != errSecSuccess) {
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            parameters[@"data"] = data;
            parameters[@"key"] = key;
            NSMutableDictionary *statusDict = [NSMutableDictionary dictionary];
            statusDict[@"osStatus"] = @(status);
            EMSStatusLog *logEntry = [[EMSStatusLog alloc] initWithClass:[self class]
                                                                     sel:_cmd
                                                              parameters:parameters
                                                                  status:statusDict];
            EMSLog(logEntry);
        }
    }];
}

- (void)setString:(nullable NSString *)string
           forKey:(NSString *)key {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [self setData:data
           forKey:key];
}

- (void)setNumber:(nullable NSNumber *)number
           forKey:(NSString *)key {
    [self setData:[NSKeyedArchiver archivedDataWithRootObject:number]
           forKey:key];
}

- (void)setDictionary:(nullable NSDictionary *)dictionary
               forKey:(NSString *)key {
    [self setData:[NSKeyedArchiver archivedDataWithRootObject:dictionary]
           forKey:key];
}

- (nullable NSData *)dataForKey:(NSString *)key {
    NSParameterAssert(key);
    NSData *result;
    NSMutableDictionary *mutableQuery = [NSMutableDictionary new];
    mutableQuery[(id) kSecClass] = (id) kSecClassGenericPassword;
    mutableQuery[(id) kSecAttrAccessible] = (id) kSecAttrAccessibleWhenUnlockedThisDeviceOnly;
    mutableQuery[(id) kSecAttrAccount] = key;
    mutableQuery[(id) kSecReturnData] = (id) kCFBooleanTrue;
    mutableQuery[(id) kSecReturnAttributes] = (id) kCFBooleanTrue;

    NSDictionary *query = [NSDictionary dictionaryWithDictionary:mutableQuery];

    CFTypeRef resultRef = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef) query, &resultRef);
    if (status == errSecSuccess) {
        NSDictionary *resultDict = (__bridge NSDictionary *) resultRef;
        result = resultDict[(id) kSecValueData];
    } else if (status != errSecItemNotFound) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"key"] = key;
        NSMutableDictionary *statusDict = [NSMutableDictionary dictionary];
        statusDict[@"osStatus"] = @(status);
        EMSStatusLog *logEntry = [[EMSStatusLog alloc] initWithClass:[self class]
                                                                 sel:_cmd
                                                          parameters:parameters
                                                              status:statusDict];
        EMSLog(logEntry);
    }

    if (resultRef) {
        CFRelease(resultRef);
    }

    if (!result) {
        for (NSUserDefaults *userDefaults in self.userDefaultsArray) {
            id userDefaultsValue = [userDefaults objectForKey:key];

            if ([userDefaultsValue isKindOfClass:[NSString class]]) {
                userDefaultsValue = [userDefaultsValue dataUsingEncoding:NSUTF8StringEncoding];
            } else if ([userDefaultsValue isKindOfClass:[NSNumber class]]) {
                userDefaultsValue = [NSKeyedArchiver archivedDataWithRootObject:userDefaultsValue];
            } else if ([userDefaultsValue isKindOfClass:[NSDictionary class]]) {
                userDefaultsValue = [NSKeyedArchiver archivedDataWithRootObject:userDefaultsValue];
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

- (nullable NSString *)stringForKey:(NSString *)key {
    NSData *data = [self dataForKey:key];

    return data ? [[NSString alloc] initWithData:data
                                        encoding:NSUTF8StringEncoding] : nil;
}

- (nullable NSNumber *)numberForKey:(NSString *)key {
    NSData *data = [self dataForKey:key];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (nullable NSDictionary *)dictionaryForKey:(NSString *)key {
    NSData *data = [self dataForKey:key];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (NSData *)objectForKeyedSubscript:(NSString *)key {
    return [self dataForKey:key];
}

- (void)setObject:(NSData *)obj
forKeyedSubscript:(NSString *)key {
    [self setData:obj
           forKey:key];
}

@end