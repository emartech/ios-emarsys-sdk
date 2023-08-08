//
// Copyright (c) 2022 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EMSStorageProtocol <NSObject>

- (void)setData:(nullable NSData *)data
         forKey:(NSString *)key;

- (void)setString:(nullable NSString *)string
           forKey:(NSString *)key;

- (void)setNumber:(nullable NSNumber *)number
           forKey:(NSString *)key;

- (void)setDictionary:(nullable NSDictionary *)dictionary
               forKey:(NSString *)key;

- (nullable NSData *)dataForKey:(NSString *)key;

- (nullable NSString *)stringForKey:(NSString *)key;

- (nullable NSNumber *)numberForKey:(NSString *)key;

- (nullable NSDictionary *)dictionaryForKey:(NSString *)key;

- (NSData *)objectForKeyedSubscript:(NSString *)key;

- (void)setObject:(NSData *)obj
forKeyedSubscript:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
