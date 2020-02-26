//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSGeofenceGroup.h"
#import "EMSGeofence.h"

@implementation EMSGeofenceGroup

- (instancetype)initWithId:(NSString *)id
              waitInterval:(double)waitInterval
                 geofences:(NSArray<EMSGeofence *> *)geofences {
    if (self = [super init]) {
        _id = id;
        _waitInterval = waitInterval;
        _geofences = geofences;
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToGroup:other];
}

- (BOOL)isEqualToGroup:(EMSGeofenceGroup *)group {
    if (self == group)
        return YES;
    if (group == nil)
        return NO;
    if (self.id != group.id && ![self.id isEqualToString:group.id])
        return NO;
    if (self.waitInterval != group.waitInterval)
        return NO;
    if (self.geofences != group.geofences && ![self.geofences isEqualToArray:group.geofences])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.id hash];
    hash = hash * 31u + [[NSNumber numberWithDouble:self.waitInterval] hash];
    hash = hash * 31u + [self.geofences hash];
    return hash;
}

@end