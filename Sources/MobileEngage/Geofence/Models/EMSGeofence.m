//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSGeofence.h"
#import "EMSGeofenceTrigger.h"

@implementation EMSGeofence

- (instancetype)initWithId:(NSString *)id
                       lat:(double)lat
                       lon:(double)lon
                         r:(int)r
              waitInterval:(double)waitInterval
                  triggers:(NSArray<EMSGeofenceTrigger *> *)triggers {
    if (self = [super init]) {
        _id = id;
        _lat = lat;
        _lon = lon;
        _r = r;
        _waitInterval = waitInterval;
        _triggers = triggers;
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToGeofence:other];
}

- (BOOL)isEqualToGeofence:(EMSGeofence *)geofence {
    if (self == geofence)
        return YES;
    if (geofence == nil)
        return NO;
    if (self.id != geofence.id && ![self.id isEqualToString:geofence.id])
        return NO;
    if (self.lat != geofence.lat)
        return NO;
    if (self.lon != geofence.lon)
        return NO;
    if (self.r != geofence.r)
        return NO;
    if (self.waitInterval != geofence.waitInterval)
        return NO;
    if (self.triggers != geofence.triggers && ![self.triggers isEqualToArray:geofence.triggers])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.id hash];
    hash = hash * 31u + [[NSNumber numberWithDouble:self.lat] hash];
    hash = hash * 31u + [[NSNumber numberWithDouble:self.lon] hash];
    hash = hash * 31u + self.r;
    hash = hash * 31u + [[NSNumber numberWithDouble:self.waitInterval] hash];
    hash = hash * 31u + [self.triggers hash];
    return hash;
}

@end