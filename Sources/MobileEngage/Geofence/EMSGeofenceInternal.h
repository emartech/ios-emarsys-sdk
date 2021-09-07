//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "EMSGeofenceProtocol.h"
#import "EMSBlocks.h"

#define kIsGeofenceEnabled @"isGeofenceEnabled"
#define kInitialEnterTriggerEnabled @"initialEnterTriggerEnabled"

@class EMSRequestManager;
@class EMSRequestFactory;
@class EMSGeofenceResponseMapper;
@class CLLocationManager;
@class EMSGeofenceResponse;
@class EMSGeofenceTrigger;
@class EMSActionFactory;
@class EMSStorage;

NS_ASSUME_NONNULL_BEGIN

@interface EMSGeofenceInternal : NSObject <EMSGeofenceProtocol, CLLocationManagerDelegate>

@property(nonatomic, strong, nullable) EMSEventHandlerBlock eventHandler;
@property(nonatomic, strong) EMSGeofenceResponse *geofenceResponse;
@property(nonatomic, strong) CLLocation *currentLocation;
@property(nonatomic, strong) NSMutableDictionary *registeredGeofencesDictionary;
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
- (void)handleActionWithTriggers:(NSArray<EMSGeofenceTrigger *> *)triggers
                            type:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
