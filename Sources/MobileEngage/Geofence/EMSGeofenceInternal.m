//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSGeofenceInternal.h"
#import "EMSRequestManager.h"
#import "EMSRequestFactory.h"
#import "EMSGeofenceResponseMapper.h"
#import "NSError+EMSCore.h"

@interface EMSGeofenceInternal ()

@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSGeofenceResponseMapper *responseMapper;
@property(nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation EMSGeofenceInternal

- (instancetype)initWithRequestFactory:(EMSRequestFactory *)requestFactory
                        requestManager:(EMSRequestManager *)requestManager
                        responseMapper:(EMSGeofenceResponseMapper *)responseMapper
                       locationManager:(CLLocationManager *)locationManager {
    NSParameterAssert(requestFactory);
    NSParameterAssert(requestManager);
    NSParameterAssert(responseMapper);
    NSParameterAssert(locationManager);
    if (self = [super init]) {
        _requestFactory = requestFactory;
        _requestManager = requestManager;
        _responseMapper = responseMapper;
        _locationManager = locationManager;
    }
    return self;
}

- (void)fetchGeofences {
    EMSRequestModel *requestModel = [self.requestFactory createGeofenceRequestModel];
    [self.requestManager submitRequestModelNow:requestModel
                                  successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                      [self.responseMapper mapFromResponseModel:response];
                                  }
                                    errorBlock:^(NSString *requestId, NSError *error) {

                                    }];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {

}

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region {

}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region {

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
        [self.locationManager startUpdatingLocation];
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

}

@end