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

NS_ASSUME_NONNULL_BEGIN

@interface EMSGeofenceInternal : NSObject <EMSGeofenceProtocol, CLLocationManagerDelegate>

@property(nonatomic, weak, nullable) id <EMSEventHandler> eventHandler;

- (instancetype)initWithRequestFactory:(EMSRequestFactory *)requestFactory
                        requestManager:(EMSRequestManager *)requestManager
                        responseMapper:(EMSGeofenceResponseMapper *)responseMapper
                       locationManager:(CLLocationManager *)locationManager;

- (void)fetchGeofences;

@end

NS_ASSUME_NONNULL_END