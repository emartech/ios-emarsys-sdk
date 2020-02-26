//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSGeofenceTrigger;

@interface EMSGeofence : NSObject

@property(nonatomic, strong) NSString *id;
@property(nonatomic, assign) double lat;
@property(nonatomic, assign) double lon;
@property(nonatomic, assign) int r;
@property(nonatomic, assign) double waitInterval;
@property(nonatomic, strong) NSArray<EMSGeofenceTrigger *> *triggers;

- (instancetype)initWithId:(NSString *)id
                       lat:(double)lat
                       lon:(double)lon
                         r:(int)r
              waitInterval:(double)waitInterval
                  triggers:(NSArray<EMSGeofenceTrigger *> *)triggers;

@end