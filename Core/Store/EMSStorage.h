//
// Copyright (c) 2020 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMSStorage : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue
                            suiteNames:(NSArray<NSString *> *)suiteNames;

- (void)setData:(nullable NSData *)data
         forKey:(NSString *)key;

- (nullable NSData *)dataForKey:(NSString *)key;

- (void)setString:(nullable NSString *)string
           forKey:(NSString *)key;

- (nullable NSString *)stringForKey:(NSString *)key;

- (void)setNumber:(nullable NSNumber *)number
           forKey:(NSString *)key;

- (nullable NSNumber *)numberForKey:(NSString *)key;

- (void)setDictionary:(nullable NSDictionary *)dictionary
               forKey:(NSString *)key;

- (nullable NSDictionary *)dictionaryForKey:(NSString *)key;

- (NSData *)objectForKeyedSubscript:(NSString *)key;

- (void)setObject:(NSData *)obj
forKeyedSubscript:(NSString *)key;
@end

NS_ASSUME_NONNULL_END