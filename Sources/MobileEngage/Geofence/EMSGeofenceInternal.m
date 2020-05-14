//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSGeofenceInternal.h"
#import "EMSRequestManager.h"
#import "EMSRequestFactory.h"
#import "EMSGeofenceResponseMapper.h"
#import "NSError+EMSCore.h"
#import "EMSGeofenceResponse.h"
#import "EMSGeofenceGroup.h"
#import "EMSGeofence.h"
#import "EMSGeofenceTrigger.h"
#import "EMSActionFactory.h"
#import "EMSActionProtocol.h"
#import "EMSStorage.h"

@interface EMSGeofenceInternal ()

@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSGeofenceResponseMapper *responseMapper;
@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) EMSActionFactory *actionFactory;
@property(nonatomic, strong) EMSStorage *storage;
@property(nonatomic, strong) NSOperationQueue *queue;

@property(nonatomic, assign) BOOL enabled;

@end

@implementation EMSGeofenceInternal

- (instancetype)initWithRequestFactory:(EMSRequestFactory *)requestFactory
                        requestManager:(EMSRequestManager *)requestManager
                        responseMapper:(EMSGeofenceResponseMapper *)responseMapper
                       locationManager:(CLLocationManager *)locationManager
                         actionFactory:(EMSActionFactory *)actionFactory
                               storage:(EMSStorage *)storage
                                 queue:(NSOperationQueue *)queue {
    NSParameterAssert(requestFactory);
    NSParameterAssert(requestManager);
    NSParameterAssert(responseMapper);
    NSParameterAssert(locationManager);
    NSParameterAssert(actionFactory);
    NSParameterAssert(storage);
    NSParameterAssert(queue);
    if (self = [super init]) {
        _requestFactory = requestFactory;
        _requestManager = requestManager;
        _responseMapper = responseMapper;
        _locationManager = locationManager;
        _actionFactory = actionFactory;
        _storage = storage;
        _queue = queue;
        _geofenceLimit = 20;
        _registeredGeofences = [NSMutableDictionary dictionary];
        _enabled = [[self.storage numberForKey:kIsGeofenceEnabled] boolValue];
        if (self.isEnabled) {
            [self fetchGeofences];
        }
    }
    return self;
}

- (void)fetchGeofences {
    if (self.isEnabled) {
        EMSRequestModel *requestModel = [self.requestFactory createGeofenceRequestModel];
        __weak typeof(self) weakSelf = self;
        [self.requestManager submitRequestModelNow:requestModel
                                      successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                          EMSGeofenceResponse *geofenceResponse = [self.responseMapper mapFromResponseModel:response];
                                          weakSelf.geofenceResponse = geofenceResponse;
                                          [weakSelf registerGeofences];
                                      }
                                        errorBlock:^(NSString *requestId, NSError *error) {

                                        }];
    }
}

- (void)registerGeofences {
    if (self.currentLocation && self.geofenceResponse && self.recalculateable) {
        self.recalculateable = NO;
        NSDictionary<NSNumber *, CLCircularRegion *> *distanceRegionsDict = [self createDistanceRegionDictionary];
        NSArray *sortedDistances = [distanceRegionsDict.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
            return [obj1 compare:obj2];
        }];
        NSUInteger lastGeofenceIndex = [self lastGeofenceIndexWithDistances:sortedDistances];
        for (NSUInteger i = 0; i <= lastGeofenceIndex; ++i) {
            [self.locationManager startMonitoringForRegion:distanceRegionsDict[sortedDistances[i]]];
        }
        [self.locationManager startMonitoringForRegion:[self createRefreshAreaRegionWithDistances:sortedDistances
                                                                               distanceRegionDict:distanceRegionsDict
                                                                                lastGeofenceIndex:lastGeofenceIndex]];
    }
}

- (NSUInteger)lastGeofenceIndexWithDistances:(NSArray *)sortedDistances {
    return sortedDistances.count < self.geofenceLimit ? sortedDistances.count - 1 : self.geofenceLimit - 2;
}

- (CLCircularRegion *)createRefreshAreaRegionWithDistances:(NSArray *)distances
                                        distanceRegionDict:(NSDictionary<NSNumber *, CLCircularRegion *> *)distanceRegionDict
                                         lastGeofenceIndex:(NSUInteger)lastGeofenceIndex {
    NSNumber *distance = distances[lastGeofenceIndex];
    double radius = [distance doubleValue] * self.geofenceResponse.refreshRadiusRatio;
    if ([distance doubleValue] < 0) {
        radius = ([distance doubleValue] + distanceRegionDict[distance].radius) * self.geofenceResponse.refreshRadiusRatio;
    }
    return [[CLCircularRegion alloc] initWithCenter:self.currentLocation.coordinate
                                             radius:radius
                                         identifier:@"EMSRefreshArea"];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    __weak typeof(self) weakSelf = self;
    [self.queue addOperationWithBlock:^{
        if (locations && locations.firstObject) {
            weakSelf.currentLocation = locations.firstObject;
            [weakSelf registerGeofences];
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region {
    __weak typeof(self) weakSelf = self;
    [self.queue addOperationWithBlock:^{
        EMSGeofence *geofence = self.registeredGeofences[region.identifier];
        [weakSelf handleActionWithTriggers:geofence.triggers
                                  type:@"enter"];
    }];
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region {
    __weak typeof(self) weakSelf = self;
    [self.queue addOperationWithBlock:^{
        EMSGeofence *geofence = weakSelf.registeredGeofences[region.identifier];

        if ([geofence.id isEqualToString:@"EMSRefreshArea"]) {
            weakSelf.recalculateable = YES;
            [weakSelf stopRegionMonitoring];
            [weakSelf registerGeofences];
        } else {
            [weakSelf handleActionWithTriggers:geofence.triggers
                                      type:@"exit"];
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager
               didVisit:(CLVisit *)visit {

}

- (void)requestAlwaysAuthorization {
    [self.locationManager requestAlwaysAuthorization];
}

- (void)enable {
    [self enableWithCompletionBlock:nil];
}

- (void)enableWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways) {
        self.recalculateable = YES;
        [self.locationManager setDelegate:self];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        [self.locationManager startUpdatingLocation];
        if (!self.enabled) {
            self.enabled = true;
            [self fetchGeofences];
        }
        if (completionBlock) {
            completionBlock(nil);
        }
    } else {
        if (completionBlock) {
            NSError *error = [NSError errorWithCode:1401
                               localizedDescription:@"LocationManager authorization status must be AuthorizedAlways!"];
            completionBlock(error);
        }
    }
}

- (void)disable {
    self.enabled = NO;
    self.recalculateable = NO;
    [self.locationManager stopUpdatingLocation];
    [self stopRegionMonitoring];
}

- (BOOL)isEnabled {
    return self.enabled;
}

- (void)setEnabled:(BOOL)enabled {
    [self.storage setNumber:@(enabled)
                     forKey:kIsGeofenceEnabled];
    _enabled = enabled;
}

- (void)stopRegionMonitoring {
    for (CLCircularRegion *region in self.locationManager.monitoredRegions) {
        [self.locationManager stopMonitoringForRegion:region];
    }
}

- (void)handleActionWithTriggers:(NSArray<EMSGeofenceTrigger *> *)triggers
                            type:(NSString *)type {
    for (EMSGeofenceTrigger *trigger in triggers) {
        if ([trigger.type.lowercaseString isEqualToString:type]) {
            [self.actionFactory setEventHandler:self.eventHandler];
            id <EMSActionProtocol> action = [self.actionFactory createActionWithActionDictionary:trigger.action];
            [action execute];
        }
    }
}

- (CLCircularRegion *)createRegionFromGeofence:(EMSGeofence *)geofence {
    return [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(geofence.lat, geofence.lon)
                                             radius:geofence.r
                                         identifier:geofence.id];
}

- (NSDictionary<NSNumber *, CLCircularRegion *> *)createDistanceRegionDictionary {
    [self.registeredGeofences removeAllObjects];
    NSMutableDictionary *regions = [NSMutableDictionary dictionary];
    for (EMSGeofenceGroup *group in self.geofenceResponse.groups) {
        for (EMSGeofence *geofence in group.geofences) {
            self.registeredGeofences[geofence.id] = geofence;
            CLLocation *location = [[CLLocation alloc] initWithLatitude:geofence.lat
                                                              longitude:geofence.lon];
            CLLocationDistance distance = [self.currentLocation distanceFromLocation:location];
            distance -= geofence.r;
            regions[@(distance)] = [self createRegionFromGeofence:geofence];
        }
    }
    return [NSDictionary dictionaryWithDictionary:regions];
}

@end
