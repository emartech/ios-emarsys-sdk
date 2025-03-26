//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (EMSCore)

- (BOOL)subsetOfDictionary:(NSDictionary *)dictionary;

- (NSData *)archive;

- (nullable id)valueForKey:(id)key
                      type:(Class)expectedClass;

- (nullable NSString *)stringValueForKey:(id)key;

- (nullable NSNumber *)numberValueForKey:(id)key;

- (nullable NSDictionary *)dictionaryValueForKey:(id)key;

- (nullable NSArray *)arrayValueForKey:(id)key;

+ (NSDictionary *)dictionaryWithData:(NSData *)data;

- (nullable id)valueForInsensitiveKey:(NSString *)key;

- (nullable id)nullSafeValueForKey:(NSString *)key;

- (NSDictionary *)mergeWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)dictionaryWithAllowedTypes:(NSSet<Class> *)allowedTypes;

- (nullable NSString *)asJSONString;

@end

NS_ASSUME_NONNULL_END
