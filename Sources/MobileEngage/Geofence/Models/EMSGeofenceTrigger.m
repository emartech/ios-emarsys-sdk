//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSGeofenceTrigger.h"

@implementation EMSGeofenceTrigger

- (instancetype)initWithId:(NSString *)id
                      type:(NSString *)type
            loiteringDelay:(int)loiteringDelay
                    action:(NSDictionary<NSString *, id> *)action {
    if (self = [super init]) {
        _id = id;
        _type = type;
        _loiteringDelay = loiteringDelay;
        _action = action;
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToTrigger:other];
}

- (BOOL)isEqualToTrigger:(EMSGeofenceTrigger *)trigger {
    if (self == trigger)
        return YES;
    if (trigger == nil)
        return NO;
    if (self.id != trigger.id && ![self.id isEqualToString:trigger.id])
        return NO;
    if (self.type != trigger.type && ![self.type isEqualToString:trigger.type])
        return NO;
    if (self.loiteringDelay != trigger.loiteringDelay)
        return NO;
    if (self.action != trigger.action && ![self.action isEqualToDictionary:trigger.action])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.id hash];
    hash = hash * 31u + [self.type hash];
    hash = hash * 31u + self.loiteringDelay;
    hash = hash * 31u + [self.action hash];
    return hash;
}

@end