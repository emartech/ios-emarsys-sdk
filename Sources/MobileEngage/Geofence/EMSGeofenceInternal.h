//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "EMSGeofenceProtocol.h"
#import "EMSEventHandler.h"

@class EMSRequestManager;
@class EMSRequestFactory;
@class EMSGeofenceResponseMapper;
@class CLLocationManager;
@class EMSGeofenceResponse;

NS_ASSUME_NONNULL_BEGIN

@interface EMSGeofenceInternal : NSObject <EMSGeofenceProtocol, CLLocationManagerDelegate>

@property(nonatomic, weak, nullable) id <EMSEventHandler> eventHandler;
@property(nonatomic, strong) EMSGeofenceResponse *geofenceResponse;
@property(nonatomic, strong) CLLocation *currentLocation;
@property(nonatomic, assign) int geofenceLimit;

- (instancetype)initWithRequestFactory:(EMSRequestFactory *)requestFactory
                        requestManager:(EMSRequestManager *)requestManager
                        responseMapper:(EMSGeofenceResponseMapper *)responseMapper
                       locationManager:(CLLocationManager *)locationManager;

- (void)fetchGeofences;
- (void)registerGeofences;

@end

NS_ASSUME_NONNULL_END