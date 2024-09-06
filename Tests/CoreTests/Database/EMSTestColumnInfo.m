////
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

#import "EMSTestColumnInfo.h"

@implementation EMSTestColumnInfo

- (instancetype)initWithColumnName:(NSString *)columnName columnType:(NSString *)columnType {
    if (self = [super init]) {
        _columnName = columnName;
        _columnType = columnType;
    }
    
    return self;
}

- (instancetype)initWithColumnName:(NSString *)columnName
                        columnType:(NSString *)columnType
                      defaultValue:(NSString *)defaultValue
                        primaryKey:(BOOL)primaryKey
                           notNull:(BOOL)notNull {
    if (self = [super init]) {
        _columnName = columnName;
        _columnType = columnType;
        _defaultValue = defaultValue;
        _primaryKey = primaryKey;
        _notNull = notNull;
    }
    
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;
    
    return [self isEqualToInfo:other];
}

- (BOOL)isEqualToInfo:(EMSTestColumnInfo *)info {
    if (self == info)
        return YES;
    if (info == nil)
        return NO;
    if (self.columnName != info.columnName && ![self.columnName isEqualToString:info.columnName])
        return NO;
    if (self.columnType != info.columnType && ![self.columnType isEqualToString:info.columnType])
        return NO;
    if (self.defaultValue != info.defaultValue && ![self.defaultValue isEqualToString:info.defaultValue])
        return NO;
    if (self.primaryKey != info.primaryKey)
        return NO;
    if (self.notNull != info.notNull)
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.columnName hash];
    hash = hash * 31u + [self.columnType hash];
    hash = hash * 31u + [self.defaultValue hash];
    hash = hash * 31u + self.primaryKey;
    hash = hash * 31u + self.notNull;
    return hash;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.columnName=%@", self.columnName];
    [description appendFormat:@", self.columnType=%@", self.columnType];
    [description appendFormat:@", self.defaultValue=%@", self.defaultValue];
    [description appendFormat:@", self.primaryKey=%d", self.primaryKey];
    [description appendFormat:@", self.notNull=%d", self.notNull];
    [description appendString:@">"];
    return description;
}

@end
