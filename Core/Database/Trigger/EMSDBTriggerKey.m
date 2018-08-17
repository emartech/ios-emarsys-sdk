//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "EMSDBTriggerKey.h"


@implementation EMSDBTriggerKey {

}
- (instancetype)initWithTableName:(NSString *)tableName
                        withEvent:(EMSDBTriggerEvent *)triggerEvent
                         withType:(EMSDBTriggerType *)triggerType {
    self = [super init];
    if (self) {
        _tableName = tableName;
        _triggerEvent = triggerEvent;
        _triggerType = triggerType;
    }

    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [[EMSDBTriggerKey alloc] initWithTableName:[self.tableName copyWithZone:zone]
                                            withEvent:[self.triggerEvent copyWithZone:zone]
                                             withType:[self.triggerType copyWithZone:zone]];
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToKey:other];
}

- (BOOL)isEqualToKey:(EMSDBTriggerKey *)key {
    if (self == key)
        return YES;
    if (key == nil)
        return NO;
    if (self.tableName != key.tableName && ![self.tableName isEqualToString:key.tableName])
        return NO;
    if (self.triggerEvent != key.triggerEvent && ![self.triggerEvent isEqual:key.triggerEvent])
        return NO;
    if (self.triggerType != key.triggerType && ![self.triggerType isEqual:key.triggerType])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.tableName hash];
    hash = hash * 31u + [self.triggerEvent hash];
    hash = hash * 31u + [self.triggerType hash];
    return hash;
}


@end