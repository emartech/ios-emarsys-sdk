//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSDBTrigger.h"

@interface EMSDBTriggerType ()

@property(nonatomic, strong) NSString *type;

- (instancetype)initWithType:(NSString *)type;

@end

@implementation EMSDBTriggerType

- (instancetype)initWithType:(NSString *)type {
    if (self = [super init]) {
        _type = type;
    }
    return self;
}

+ (EMSDBTriggerType *)beforeType {
    return [[EMSDBTriggerType alloc] initWithType:@"before"];
}

+ (EMSDBTriggerType *)afterType {
    return [[EMSDBTriggerType alloc] initWithType:@"after"];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [[EMSDBTriggerType alloc] initWithType:[self.type copyWithZone:zone]];
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToType:other];
}

- (BOOL)isEqualToType:(EMSDBTriggerType *)type {
    if (self == type)
        return YES;
    if (type == nil)
        return NO;
    if (self.type != type.type && ![self.type isEqualToString:type.type])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    return [self.type hash];
}

- (NSString *)description {
    return self.type;
}


@end

@interface EMSDBTriggerEvent ()

@property(nonatomic, strong) NSString *eventName;

- (instancetype)initWithEventName:(NSString *)eventName;

@end

@implementation EMSDBTriggerEvent

- (instancetype)initWithEventName:(NSString *)eventName {
    if (self = [super init]) {
        _eventName = eventName;
    }
    return self;
}

+ (EMSDBTriggerEvent *)insertEvent {
    return [[EMSDBTriggerEvent alloc] initWithEventName:@"insert"];
}

+ (EMSDBTriggerEvent *)deleteEvent {
    return [[EMSDBTriggerEvent alloc] initWithEventName:@"delete"];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [[EMSDBTriggerEvent alloc] initWithEventName:[self.eventName copyWithZone:zone]];
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToEvent:other];
}

- (BOOL)isEqualToEvent:(EMSDBTriggerEvent *)event {
    if (self == event)
        return YES;
    if (event == nil)
        return NO;
    if (self.eventName != event.eventName && ![self.eventName isEqualToString:event.eventName])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    return [self.eventName hash];
}

- (NSString *)description {
    return self.eventName;
}


@end