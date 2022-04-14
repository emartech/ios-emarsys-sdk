//
// Copyright (c) 2022 Emarsys. All rights reserved.
//

#import "EMSInMemoryStorage.h"

@interface EMSInMemoryStorage ()

@property(nonatomic, strong) id <EMSStorageProtocol> storage;
@property(nonatomic, strong) NSMutableDictionary<NSString *, id> *store;

@end

@implementation EMSInMemoryStorage


- (instancetype)initWithStorage:(id <EMSStorageProtocol>)storage {
    NSParameterAssert(storage);
    if (self = [super init]) {
        _storage = storage;
        _store = [NSMutableDictionary new];
    }
    return self;
}

- (void)setData:(NSData *)data
         forKey:(NSString *)key {
    self.store[key] = data;
    [self.storage setData:data
                   forKey:key];
}

- (void)setString:(NSString *)string
           forKey:(NSString *)key {
    self.store[key] = string;
    [self.storage setString:string
                     forKey:key];
}

- (void)setNumber:(NSNumber *)number
           forKey:(NSString *)key {
    self.store[key] = number;
    [self.storage setNumber:number
                     forKey:key];
}

- (void)setDictionary:(NSDictionary *)dictionary
               forKey:(NSString *)key {
    self.store[key] = dictionary;
    [self.storage setDictionary:dictionary
                         forKey:key];
}

- (nullable NSData *)dataForKey:(NSString *)key {
    return [self objectForKey:key
                 storageBlock:^id(id <EMSStorageProtocol> storage) {
        return [storage dataForKey:key];
    }];
}

- (nullable NSString *)stringForKey:(NSString *)key {
    return [self objectForKey:key
                 storageBlock:^id(id <EMSStorageProtocol> storage) {
                     return [storage stringForKey:key];
                 }];
}

- (nullable NSNumber *)numberForKey:(NSString *)key {
    return [self objectForKey:key
                 storageBlock:^id(id <EMSStorageProtocol> storage) {
                     return [storage numberForKey:key];
                 }];
}

- (nullable NSDictionary *)dictionaryForKey:(NSString *)key {
    return [self objectForKey:key
                 storageBlock:^id(id <EMSStorageProtocol> storage) {
                     return [storage dictionaryForKey:key];
                 }];
}

- (NSData *)objectForKeyedSubscript:(NSString *)key {
    return self.inMemoryStore[key];
}

- (void)setObject:(NSData *)obj
forKeyedSubscript:(NSString *)key {
    [self setData:obj
           forKey:key];
}

- (NSDictionary<NSString *, id> *)inMemoryStore {
    return self.store;
}

- (id)objectForKey:(NSString *)key
      storageBlock:(id(^)(id<EMSStorageProtocol> storage))storageBlock {
    id result = self.inMemoryStore[key];
    if (!result) {
        result = storageBlock(self.storage);
        self.store[key] = result;
    }
    return result;
}

@end