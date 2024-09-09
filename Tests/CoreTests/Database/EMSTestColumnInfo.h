////
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMSTestColumnInfo : NSObject

@property(nonatomic, strong) NSString *columnName;
@property(nonatomic, strong) NSString *columnType;
@property(nonatomic, strong) NSString *defaultValue;
@property(nonatomic, assign) BOOL primaryKey;
@property(nonatomic, assign) BOOL notNull;

- (instancetype)initWithColumnName:(NSString *)columnName columnType:(NSString *)columnType;

- (instancetype)initWithColumnName:(NSString *)columnName
                        columnType:(NSString *)columnType
                      defaultValue:(NSString *)defaultValue
                        primaryKey:(BOOL)primaryKey
                           notNull:(BOOL)notNull;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToInfo:(EMSTestColumnInfo *)info;

- (NSUInteger)hash;

- (NSString *)description;
@end


NS_ASSUME_NONNULL_END
