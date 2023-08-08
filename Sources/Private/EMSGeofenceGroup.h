//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSGeofence;

@interface EMSGeofenceGroup : NSObject

@property(nonatomic, strong) NSString *id;
@property(nonatomic, assign) double waitInterval;
@property(nonatomic, strong) NSArray<EMSGeofence *> *geofences;

- (instancetype)initWithId:(NSString *)id
              waitInterval:(double)waitInterval
                 geofences:(NSArray<EMSGeofence *> *)geofences;

@end