//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSGeofenceGroup;

@interface EMSGeofenceResponse : NSObject

@property(nonatomic, strong) NSArray<EMSGeofenceGroup *> *groups;
@property(nonatomic, assign) double refreshRadiusRatio;

- (instancetype)initWithGroups:(NSArray<EMSGeofenceGroup *> *)groups
            refreshRadiusRatio:(double)refreshRadiusRatio;

@end