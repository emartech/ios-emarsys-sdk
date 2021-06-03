//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import "EMSCustomEventActionModel.h"

@implementation EMSCustomEventActionModel

- (instancetype)initWithId:(NSString *)id
                     title:(NSString *)title
                      type:(NSString *)type
                      name:(NSString *)name
                   payload:(NSDictionary<NSString *, id> *)payload {
    NSParameterAssert(id);
    NSParameterAssert(title);
    NSParameterAssert(type);
    NSParameterAssert(name);
    if (self = [super init]) {
        _id = id;
        _title = title;
        _type = type;
        _name = name;
        _payload = payload;
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToEvent:other];
}

- (BOOL)isEqualToEvent:(EMSCustomEventActionModel *)event {
    if (self == event)
        return YES;
    if (event == nil)
        return NO;
    if (self.id != event.id && ![self.id isEqualToString:event.id])
        return NO;
    if (self.title != event.title && ![self.title isEqualToString:event.title])
        return NO;
    if (self.type != event.type && ![self.type isEqualToString:event.type])
        return NO;
    if (self.name != event.name && ![self.name isEqualToString:event.name])
        return NO;
    if (self.payload != event.payload && ![self.payload isEqualToDictionary:event.payload])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.id hash];
    hash = hash * 31u + [self.title hash];
    hash = hash * 31u + [self.type hash];
    hash = hash * 31u + [self.name hash];
    hash = hash * 31u + [self.payload hash];
    return hash;
}

@end
