//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSGeofenceResponse.h"
#import "EMSGeofenceGroup.h"

@implementation EMSGeofenceResponse

- (instancetype)initWithGroups:(NSArray<EMSGeofenceGroup *> *)groups
            refreshRadiusRatio:(double)refreshRadiusRatio {
    if (self = [super init]) {
        _groups = groups;
        _refreshRadiusRatio = refreshRadiusRatio;
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToResponse:other];
}

- (BOOL)isEqualToResponse:(EMSGeofenceResponse *)response {
    if (self == response)
        return YES;
    if (response == nil)
        return NO;
    if (self.groups != response.groups && ![self.groups isEqualToArray:response.groups])
        return NO;
    if (self.refreshRadiusRatio != response.refreshRadiusRatio)
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.groups hash];
    hash = hash * 31u + [[NSNumber numberWithDouble:self.refreshRadiusRatio] hash];
    return hash;
}

@end