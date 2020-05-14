//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "EMSGeofenceProtocol.h"
#import "EMSEventHandler.h"

#define kIsGeofenceEnabled @"isGeofenceEnabled"

@class EMSRequestManager;
@class EMSRequestFactory;
@class EMSGeofenceResponseMapper;
@class CLLocationManager;
@class EMSGeofenceResponse;
@class EMSActionFactory;
@class EMSStorage;

NS_ASSUME_NONNULL_BEGIN

@interface EMSGeofenceInternal : NSObject <EMSGeofenceProtocol, CLLocationManagerDelegate>

@property(nonatomic, weak, nullable) id <EMSEventHandler> eventHandler;
@property(nonatomic, strong) EMSGeofenceResponse *geofenceResponse;
@property(nonatomic, strong) CLLocation *currentLocation;
@property(nonatomic, strong) NSMutableDictionary *registeredGeofences;
@property(nonatomic, assign) int geofenceLimit;
@property(nonatomic, assign) BOOL recalculateable;

- (instancetype)initWithRequestFactory:(EMSRequestFactory *)requestFactory
                        requestManager:(EMSRequestManager *)requestManager
                        responseMapper:(EMSGeofenceResponseMapper *)responseMapper
                       locationManager:(CLLocationManager *)locationManager
                         actionFactory:(EMSActionFactory *)actionFactory
                               storage:(EMSStorage *)storage
                                 queue:(NSOperationQueue *)queue;

- (void)fetchGeofences;
- (void)registerGeofences;

@end

NS_ASSUME_NONNULL_END