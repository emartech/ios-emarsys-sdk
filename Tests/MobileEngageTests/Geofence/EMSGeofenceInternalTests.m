//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CoreLocation/CoreLocation.h>
#import "EMSGeofenceInternal.h"
#import "EMSRequestFactory.h"
#import "EMSRequestManager.h"
#import "EMSGeofenceResponseMapper.h"
#import "EMSResponseModel.h"
#import "NSError+EMSCore.h"
#import "EMSGeofenceResponse.h"
#import "EMSGeofenceGroup.h"
#import "EMSGeofence.h"
#import "EMSGeofenceTrigger.h"
#import "EMSActionFactory.h"
#import "EMSActionProtocol.h"
#import "EMSStorage.h"
#import "MEExperimental.h"
#import "EMSInnerFeature.h"
#import "EmarsysTestUtils.h"

@interface EMSGeofenceInternalTests : XCTestCase

@property(nonatomic, strong) EMSGeofenceInternal *geofenceInternal;
@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;
@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) EMSActionFactory *mockActionFactory;
@property(nonatomic, strong) EMSGeofenceResponseMapper *mockResponseMapper;
@property(nonatomic, strong) EMSRequestModel *mockRequestModel;
@property(nonatomic, strong) EMSResponseModel *mockResponseModel;
@property(nonatomic, strong) EMSStorage *mockStorage;
@property(nonatomic, strong) id mockLocationManager;
@property(nonatomic, assign) double refreshRadiusRatio;
@property(nonatomic, strong) NSOperationQueue *queue;

@end

@implementation EMSGeofenceInternalTests

- (void)setUp {
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockRequestModel = OCMClassMock([EMSRequestModel class]);
    _mockResponseModel = OCMClassMock([EMSResponseModel class]);
    _mockResponseMapper = OCMClassMock([EMSGeofenceResponseMapper class]);
    _mockActionFactory = OCMClassMock([EMSActionFactory class]);
    _mockStorage = OCMClassMock([EMSStorage class]);
    _queue = [[NSOperationQueue alloc] init];
    [self.queue setMaxConcurrentOperationCount:1];
    [self.queue setName:@"testQueue"];

    _mockLocationManager = OCMClassMock([CLLocationManager class]);

    OCMStub([self.mockRequestFactory createGeofenceRequestModel]).andReturn(self.mockRequestModel);
    OCMStub([self.mockStorage numberForKey:@"isGeofenceEnabled"]).andReturn(@(YES));

    [MEExperimental enableFeature:[EMSInnerFeature mobileEngage]];

    _geofenceInternal = [[EMSGeofenceInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                                             requestManager:self.mockRequestManager
                                                             responseMapper:self.mockResponseMapper
                                                            locationManager:self.mockLocationManager
                                                              actionFactory:self.mockActionFactory
                                                                    storage:self.mockStorage
                                                                      queue:self.queue];
    _refreshRadiusRatio = 0.3;
}

- (void)tearDown {
    [EmarsysTestUtils tearDownEmarsys];
    [self.mockLocationManager stopMocking];
}

- (void)testInit_requestFactory_mustNotBeNil {
    @try {
        [[EMSGeofenceInternal alloc] initWithRequestFactory:nil
                                             requestManager:self.mockRequestManager
                                             responseMapper:self.mockResponseMapper
                                            locationManager:self.mockLocationManager
                                              actionFactory:self.mockActionFactory
                                                    storage:self.mockStorage
                                                      queue:self.queue];
        XCTFail(@"Expected Exception when requestFactory is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestFactory");
    }
}

- (void)testInit_requestManager_mustNotBeNil {
    @try {
        [[EMSGeofenceInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                             requestManager:nil
                                             responseMapper:self.mockResponseMapper
                                            locationManager:self.mockLocationManager
                                              actionFactory:self.mockActionFactory
                                                    storage:self.mockStorage
                                                      queue:self.queue];
        XCTFail(@"Expected Exception when requestManager is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestManager");
    }
}

- (void)testInit_responseMapper_mustNotBeNil {
    @try {
        [[EMSGeofenceInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                             requestManager:self.mockRequestManager
                                             responseMapper:nil
                                            locationManager:self.mockLocationManager
                                              actionFactory:self.mockActionFactory
                                                    storage:self.mockStorage
                                                      queue:self.queue];
        XCTFail(@"Expected Exception when responseMapper is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: responseMapper");
    }
}

- (void)testInit_locationManager_mustNotBeNil {
    @try {
        [[EMSGeofenceInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                             requestManager:self.mockRequestManager
                                             responseMapper:self.mockResponseMapper
                                            locationManager:nil
                                              actionFactory:self.mockActionFactory
                                                    storage:self.mockStorage
                                                      queue:self.queue];
        XCTFail(@"Expected Exception when locationManager is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: locationManager");
    }
}

- (void)testInit_actionFactory_mustNotBeNil {
    @try {
        [[EMSGeofenceInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                             requestManager:self.mockRequestManager
                                             responseMapper:self.mockResponseMapper
                                            locationManager:self.mockLocationManager
                                              actionFactory:nil
                                                    storage:self.mockStorage
                                                      queue:self.queue];
        XCTFail(@"Expected Exception when actionFactory is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: actionFactory");
    }
}

- (void)testInit_storage_mustNotBeNil {
    @try {
        [[EMSGeofenceInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                             requestManager:self.mockRequestManager
                                             responseMapper:self.mockResponseMapper
                                            locationManager:self.mockLocationManager
                                              actionFactory:self.mockActionFactory
                                                    storage:nil
                                                      queue:self.queue];
        XCTFail(@"Expected Exception when storage is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: storage");
    }
}

- (void)testInit_queue_mustNotBeNil {
    @try {
        [[EMSGeofenceInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                             requestManager:self.mockRequestManager
                                             responseMapper:self.mockResponseMapper
                                            locationManager:self.mockLocationManager
                                              actionFactory:self.mockActionFactory
                                                    storage:self.mockStorage
                                                      queue:nil];
        XCTFail(@"Expected Exception when queue is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: queue");
    }
}

- (void)testDidUpdateLocation_whenInitialEnterTriggerEnabled {
    EMSGeofence *geofence1 = [self createGeofenceWithId:@"id1"
                                                    lat:41.13
                                                    lon:13.41
                                                      r:50];
    EMSGeofence *geofence2 = [self createGeofenceWithId:@"id2"
                                                    lat:43.13
                                                    lon:14.41
                                                      r:50];
    
    self.geofenceInternal.initialEnterTriggerEnabled = YES;
    EMSGeofenceInternal *partialMockInternal = OCMPartialMock(self.geofenceInternal);
    
    [partialMockInternal setRegisteredGeofences:[@{
        @"id1": geofence1,
        @"id2": geofence2
    } mutableCopy]];
    
    [partialMockInternal locationManager:self.mockLocationManager didUpdateLocations:@[[[CLLocation alloc] initWithLatitude:41.1301
                                                                                                                    longitude:13.4101]]];
    
    [self waitForOperation];
    
    OCMVerify([partialMockInternal handleActionWithTriggers:@[[geofence1.triggers firstObject]]
                                                       type:@"enter"]);
}

- (void)testEnterInitialTriggerEnabled {
    EMSGeofenceInternal *internal = [[EMSGeofenceInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                         requestManager:self.mockRequestManager
                                         responseMapper:self.mockResponseMapper
                                        locationManager:self.mockLocationManager
                                          actionFactory:self.mockActionFactory
                                                storage:self.mockStorage
                                                  queue:self.queue];
    XCTAssertFalse(internal.initialEnterTriggerEnabled);
}

- (void)testFetchGeofence {
    OCMStub([self.mockRequestManager submitRequestModelNow:self.mockRequestModel
                                              successBlock:([OCMArg invokeBlockWithArgs:@"testRequestId",
                                                                                        self.mockResponseModel,
                                                                                        nil])
                                                errorBlock:[OCMArg any]]);

    [self.geofenceInternal fetchGeofences];

    OCMVerify([self.mockRequestManager submitRequestModelNow:self.mockRequestModel
                                                successBlock:[OCMArg any]
                                                  errorBlock:[OCMArg any]]);
    OCMVerify([self.mockResponseMapper mapFromResponseModel:self.mockResponseModel]);
}

- (void)testFetchGeofence_shouldNotFetch_whenIsEnabledIsNo {
    _mockStorage = OCMClassMock([EMSStorage class]);
    OCMStub([self.mockStorage numberForKey:@"isGeofenceEnabled"]).andReturn(@(NO));

    OCMReject([self.mockRequestFactory createGeofenceRequestModel]);
    OCMReject([self.mockRequestManager submitRequestModelNow:self.mockRequestModel
                                                successBlock:[OCMArg any]
                                                  errorBlock:[OCMArg any]]);

    _geofenceInternal = [[EMSGeofenceInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                                             requestManager:self.mockRequestManager
                                                             responseMapper:self.mockResponseMapper
                                                            locationManager:self.mockLocationManager
                                                              actionFactory:self.mockActionFactory
                                                                    storage:self.mockStorage
                                                                      queue:self.queue];

    [self.geofenceInternal fetchGeofences];
}

- (void)testRequestAlwaysAuthorization {
    [self.geofenceInternal requestAlwaysAuthorization];

    OCMVerify([self.mockLocationManager requestAlwaysAuthorization]);
}

- (void)testGeofenceLimit {
    XCTAssertEqual([self.geofenceInternal geofenceLimit], 20);
}

- (void)testRegisteredGeofences {
    XCTAssertNotNil(self.geofenceInternal.registeredGeofences);
}

- (void)testEnable_whenIsEnabled_YES {
    EMSGeofenceInternal *partialMockGeofenceInternal = OCMPartialMock(self.geofenceInternal);
    OCMReject([partialMockGeofenceInternal fetchGeofences]);

    OCMStub([self.mockLocationManager authorizationStatus]).andReturn(kCLAuthorizationStatusAuthorizedAlways);

    [partialMockGeofenceInternal enableWithCompletionBlock:^(NSError *error) {
    }];

    OCMVerify([self.mockLocationManager startUpdatingLocation]);
    OCMVerify([self.mockLocationManager setDelegate:self.geofenceInternal]);
    OCMVerify([self.mockLocationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters]);

    XCTAssertEqual(partialMockGeofenceInternal.recalculateable, YES);
}

- (void)testEnable_whenIsEnabled_NO {
    _mockStorage = OCMClassMock([EMSStorage class]);
    OCMStub([self.mockStorage numberForKey:@"isGeofenceEnabled"]).andReturn(@(NO));
    _geofenceInternal = [[EMSGeofenceInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                                             requestManager:self.mockRequestManager
                                                             responseMapper:self.mockResponseMapper
                                                            locationManager:self.mockLocationManager
                                                              actionFactory:self.mockActionFactory
                                                                    storage:self.mockStorage
                                                                      queue:self.queue];

    EMSGeofenceInternal *partialMockGeofenceInternal = OCMPartialMock(self.geofenceInternal);

    OCMStub([self.mockLocationManager authorizationStatus]).andReturn(kCLAuthorizationStatusAuthorizedAlways);

    [partialMockGeofenceInternal enableWithCompletionBlock:^(NSError *error) {
    }];

    OCMVerify([self.mockLocationManager startUpdatingLocation]);
    OCMVerify([self.mockLocationManager setDelegate:self.geofenceInternal]);
    OCMVerify([self.mockLocationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters]);
    OCMVerify([partialMockGeofenceInternal fetchGeofences]);

    XCTAssertEqual(partialMockGeofenceInternal.recalculateable, YES);
}

- (void)testEnable_callsCompletionBlockWithError_whenAuthorizationStatusNotAlwaysAuthorized {
    NSError *expectedError = [NSError errorWithCode:1401
                               localizedDescription:@"LocationManager authorization status must be AuthorizedAlways!"];

    OCMStub([self.mockLocationManager authorizationStatus]).andReturn(kCLAuthorizationStatusAuthorizedWhenInUse);
    OCMReject([self.mockLocationManager startUpdatingLocation]);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForError"];
    __block NSError *returnedError = nil;
    [self.geofenceInternal enableWithCompletionBlock:^(NSError *error) {
        returnedError = error;
        [expectation fulfill];
    }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:5];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(returnedError, expectedError);
}

- (void)testEnable_callsCompletionBlockWithNil_whenAuthorizationStatusISAlwaysAuthorized {
    OCMStub([self.mockLocationManager authorizationStatus]).andReturn(kCLAuthorizationStatusAuthorizedAlways);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForError"];
    __block NSError *returnedError = nil;
    [self.geofenceInternal enableWithCompletionBlock:^(NSError *error) {
        returnedError = error;
        [expectation fulfill];
    }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:1];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
}

- (void)testEnable_shouldNotCrash_whenThereIsNoCompletionBlock {
    OCMStub([self.mockLocationManager authorizationStatus]).andReturn(kCLAuthorizationStatusAuthorizedAlways);

    [self.geofenceInternal enableWithCompletionBlock:nil];
}

- (void)testEnable_delegatesToEnableWithCompletionBlock {
    EMSGeofenceInternal *partialGeofenceInternal = OCMPartialMock(self.geofenceInternal);

    [partialGeofenceInternal enable];

    OCMVerify([partialGeofenceInternal enableWithCompletionBlock:nil]);
}

- (void)testIsEnabled_afterEnableCalled_andStoresInStorage {
    _mockStorage = OCMClassMock([EMSStorage class]);
    OCMStub([self.mockStorage numberForKey:@"isGeofenceEnabled"]).andReturn(@(NO));
    _geofenceInternal = [[EMSGeofenceInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                                             requestManager:self.mockRequestManager
                                                             responseMapper:self.mockResponseMapper
                                                            locationManager:self.mockLocationManager
                                                              actionFactory:self.mockActionFactory
                                                                    storage:self.mockStorage
                                                                      queue:self.queue];

    OCMStub([self.mockLocationManager authorizationStatus]).andReturn(kCLAuthorizationStatusAuthorizedAlways);

    [self.geofenceInternal enable];

    OCMVerify([self.mockStorage setNumber:@(YES)
                                   forKey:@"isGeofenceEnabled"]);

    XCTAssertTrue([self.geofenceInternal isEnabled]);
}

- (void)testIsEnabled_afterDisableCalled {
    OCMStub([self.mockLocationManager authorizationStatus]).andReturn(kCLAuthorizationStatusAuthorizedAlways);

    [self.geofenceInternal enable];

    [self.geofenceInternal disable];

    OCMVerify([self.mockStorage setNumber:@(NO)
                                   forKey:@"isGeofenceEnabled"]);

    XCTAssertFalse([self.geofenceInternal isEnabled]);
}

- (void)testIsEnabled_whenNothingCalledBefore {
    OCMReject([self.mockRequestFactory createGeofenceRequestModel]);
    OCMReject([self.mockRequestManager submitRequestModelNow:self.mockRequestModel
                                                successBlock:[OCMArg any]
                                                  errorBlock:[OCMArg any]]);

    _mockStorage = OCMClassMock([EMSStorage class]);
    OCMStub([self.mockStorage numberForKey:@"isGeofenceEnabled"]).andReturn(@(NO));

    _geofenceInternal = [[EMSGeofenceInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                                             requestManager:self.mockRequestManager
                                                             responseMapper:self.mockResponseMapper
                                                            locationManager:self.mockLocationManager
                                                              actionFactory:self.mockActionFactory
                                                                    storage:self.mockStorage
                                                                      queue:self.queue];

    XCTAssertFalse([self.geofenceInternal isEnabled]);
}

- (void)testIsEnabled_initializeFromStorage_withYes {
    OCMStub([self.mockStorage numberForKey:@"isGeofenceEnabled"]).andReturn(@(YES));

    _geofenceInternal = [[EMSGeofenceInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                                             requestManager:self.mockRequestManager
                                                             responseMapper:self.mockResponseMapper
                                                            locationManager:self.mockLocationManager
                                                              actionFactory:self.mockActionFactory
                                                                    storage:self.mockStorage
                                                                      queue:self.queue];

    OCMVerify([self.mockRequestFactory createGeofenceRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModelNow:self.mockRequestModel
                                                successBlock:[OCMArg any]
                                                  errorBlock:[OCMArg any]]);

    XCTAssertTrue(self.geofenceInternal.isEnabled);
}

- (void)testInitialEnterTriggerEnabled_shouldReturnNo_onFirstTime {
    _geofenceInternal = [[EMSGeofenceInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                                             requestManager:self.mockRequestManager
                                                             responseMapper:self.mockResponseMapper
                                                            locationManager:self.mockLocationManager
                                                              actionFactory:self.mockActionFactory
                                                                    storage:self.mockStorage
                                                                      queue:self.queue];
    
    XCTAssertFalse(self.geofenceInternal.initialEnterTriggerEnabled);
}

- (void)testInitialEnterTriggerEnabled_shouldReturnYes_whenWasSetBefore {
    OCMStub([self.mockStorage numberForKey:@"initialEnterTriggerEnabled"]).andReturn(@(YES));
    
    
    _geofenceInternal = [[EMSGeofenceInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                                             requestManager:self.mockRequestManager
                                                             responseMapper:self.mockResponseMapper
                                                            locationManager:self.mockLocationManager
                                                              actionFactory:self.mockActionFactory
                                                                    storage:self.mockStorage
                                                                      queue:self.queue];
    
    XCTAssertTrue(self.geofenceInternal.initialEnterTriggerEnabled);
}

- (void)testInitialEnterTriggerEnabled_shouldStoreIt_whenSetterCalled {
    _geofenceInternal = [[EMSGeofenceInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                                             requestManager:self.mockRequestManager
                                                             responseMapper:self.mockResponseMapper
                                                            locationManager:self.mockLocationManager
                                                              actionFactory:self.mockActionFactory
                                                                    storage:self.mockStorage
                                                                      queue:self.queue];
    
    [self.geofenceInternal setInitialEnterTriggerEnabled:YES];
    
    OCMVerify([self.mockStorage setNumber:@(YES)
                                   forKey:kInitialEnterTriggerEnabled]);
    
    XCTAssertTrue(self.geofenceInternal.initialEnterTriggerEnabled);
}


- (void)testInitialEnterTriggerEnabled_shouldWorkProperly {
    _geofenceInternal = [[EMSGeofenceInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                                             requestManager:self.mockRequestManager
                                                             responseMapper:self.mockResponseMapper
                                                            locationManager:self.mockLocationManager
                                                              actionFactory:self.mockActionFactory
                                                                    storage:self.mockStorage
                                                                      queue:self.queue];
    XCTAssertFalse(self.geofenceInternal.initialEnterTriggerEnabled);
    
    [self.geofenceInternal setInitialEnterTriggerEnabled:YES];
    
    XCTAssertTrue(self.geofenceInternal.initialEnterTriggerEnabled);
    
    [self.geofenceInternal setInitialEnterTriggerEnabled:NO];
    
    XCTAssertFalse(self.geofenceInternal.initialEnterTriggerEnabled);
}

- (void)testDisable {
    CLCircularRegion *region2 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(47.493812, 19.058537)
                                                                  radius:10
                                                              identifier:@"2"];
    CLCircularRegion *region3 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(47.492292, 19.056440)
                                                                  radius:10
                                                              identifier:@"3"];
    NSSet *regions = [NSSet setWithArray:@[region2, region3]];
    OCMStub([self.mockLocationManager monitoredRegions]).andReturn(regions);

    self.geofenceInternal.recalculateable = YES;

    [self.geofenceInternal disable];

    OCMVerify([self.mockLocationManager stopUpdatingLocation]);
    OCMVerify([self.mockLocationManager stopMonitoringForRegion:[self argForRegion:region2]]);
    OCMVerify([self.mockLocationManager stopMonitoringForRegion:[self argForRegion:region3]]);

    XCTAssertEqual(self.geofenceInternal.recalculateable, NO);
}

- (void)testRegisterGeofences_shouldBeCalled_whenLocationUpdated {
    CLLocation *expectedLocation = [[CLLocation alloc] initWithLatitude:12.34
                                                              longitude:56.78];

    EMSGeofenceInternal *partialGeofenceInternal = OCMPartialMock(self.geofenceInternal);

    [partialGeofenceInternal locationManager:self.mockLocationManager
                          didUpdateLocations:@[expectedLocation]];

    [self waitForOperation];

    OCMVerify([partialGeofenceInternal registerGeofences]);

    XCTAssertEqualObjects(partialGeofenceInternal.currentLocation, expectedLocation);
}

- (void)testRegisterGeofences_shouldBeCalled_afterFetchingSucceeded {
    EMSGeofenceInternal *partialGeofenceInternal = OCMPartialMock(self.geofenceInternal);
    EMSGeofenceResponse *expectedGeofenceResponse = OCMClassMock([EMSGeofenceResponse class]);

    OCMStub([self.mockRequestManager submitRequestModelNow:self.mockRequestModel
                                              successBlock:([OCMArg invokeBlockWithArgs:@"testRequestId",
                                                                                        self.mockResponseModel,
                                                                                        nil])
                                                errorBlock:[OCMArg any]]);
    OCMStub([self.mockResponseMapper mapFromResponseModel:self.mockResponseModel]).andReturn(expectedGeofenceResponse);

    [partialGeofenceInternal fetchGeofences];

    OCMVerify([partialGeofenceInternal registerGeofences]);
    XCTAssertEqualObjects(partialGeofenceInternal.geofenceResponse, expectedGeofenceResponse);
}

- (void)testRegisterGeofences_shouldNotRegister_whenCurrentLocation_andGeofenceResponse_areNotAvailable {
    OCMReject([self.mockLocationManager startMonitoringForRegion:[OCMArg any]]);

    [self.geofenceInternal registerGeofences];
}

- (void)testRegisterGeofences {
    CLLocationCoordinate2D emarsysLocation = CLLocationCoordinate2DMake(47.493160, 19.058355);
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:emarsysLocation.latitude
                                                             longitude:emarsysLocation.longitude];
    CLCircularRegion *region1 = [[CLCircularRegion alloc] initWithCenter:emarsysLocation
                                                                  radius:10
                                                              identifier:@"1"];
    CLCircularRegion *region2 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(47.493812, 19.058537)
                                                                  radius:10
                                                              identifier:@"2"];
    CLCircularRegion *region3 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(47.492292, 19.056440)
                                                                  radius:10
                                                              identifier:@"3"];
    CLCircularRegion *regionArea = [[CLCircularRegion alloc] initWithCenter:emarsysLocation
                                                                     radius:49.0792712800666
                                                                 identifier:@"EMSRefreshArea"];
    CLCircularRegion *region4 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(47.493827, 19.060715)
                                                                  radius:10
                                                              identifier:@"4"];
    CLCircularRegion *region5 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(47.489680, 19.061230)
                                                                  radius:10
                                                              identifier:@"5"];

    OCMReject([self.mockLocationManager startMonitoringForRegion:[self argForRegion:region4]]);
    OCMReject([self.mockLocationManager startMonitoringForRegion:[self argForRegion:region5]]);

    [self.geofenceInternal setCurrentLocation:currentLocation];
    [self.geofenceInternal setGeofenceResponse:[self createExpectedResponse]];
    [self.geofenceInternal setGeofenceLimit:4];
    [self.geofenceInternal setRecalculateable:YES];

    [self.geofenceInternal registerGeofences];

    OCMVerify([self.mockLocationManager startMonitoringForRegion:[self argForRegion:region1]]);
    OCMVerify([self.mockLocationManager startMonitoringForRegion:[self argForRegion:region2]]);
    OCMVerify([self.mockLocationManager startMonitoringForRegion:[self argForRegion:region3]]);
    OCMVerify([self.mockLocationManager startMonitoringForRegion:[self argForRegion:regionArea]]);

    XCTAssertEqual(self.geofenceInternal.recalculateable, NO);
}

- (void)testRegisterGeofences_whenFurthestDistanceWithRadiusIsNegative {
    CLLocationCoordinate2D emarsysLocation = CLLocationCoordinate2DMake(47.493160, 19.058355);
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:emarsysLocation.latitude
                                                             longitude:emarsysLocation.longitude];
    CLCircularRegion *region1 = [[CLCircularRegion alloc] initWithCenter:emarsysLocation
                                                                  radius:200
                                                              identifier:@"1"];
    CLCircularRegion *region2 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(47.493812, 19.058537)
                                                                  radius:200
                                                              identifier:@"2"];
    CLCircularRegion *region3 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(47.492292, 19.056440)
                                                                  radius:200
                                                              identifier:@"3"];
    CLCircularRegion *regionArea = [[CLCircularRegion alloc] initWithCenter:emarsysLocation
                                                                     radius:173.59757093355535 * self.refreshRadiusRatio
                                                                 identifier:@"EMSRefreshArea"];
    CLCircularRegion *region4 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(47.493827, 19.060715)
                                                                  radius:200
                                                              identifier:@"4"];
    CLCircularRegion *region5 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(47.489680, 19.061230)
                                                                  radius:200
                                                              identifier:@"5"];

    OCMReject([self.mockLocationManager startMonitoringForRegion:[self argForRegion:region4]]);
    OCMReject([self.mockLocationManager startMonitoringForRegion:[self argForRegion:region5]]);

    [self.geofenceInternal setCurrentLocation:currentLocation];
    [self.geofenceInternal setGeofenceResponse:[self createResponseWithBigRadius]];
    [self.geofenceInternal setGeofenceLimit:4];
    [self.geofenceInternal setRecalculateable:YES];

    [self.geofenceInternal registerGeofences];

    OCMVerify([self.mockLocationManager startMonitoringForRegion:[self argForRegion:region1]]);
    OCMVerify([self.mockLocationManager startMonitoringForRegion:[self argForRegion:region2]]);
    OCMVerify([self.mockLocationManager startMonitoringForRegion:[self argForRegion:region3]]);
    OCMVerify([self.mockLocationManager startMonitoringForRegion:[self argForRegion:regionArea]]);

    XCTAssertEqual(self.geofenceInternal.recalculateable, NO);
}

- (void)testRegisterGeofences_whenLimitIsBiggerThanGeofenceCount {
    CLLocationCoordinate2D emarsysLocation = CLLocationCoordinate2DMake(47.493160, 19.058355);
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:emarsysLocation.latitude
                                                             longitude:emarsysLocation.longitude];
    CLCircularRegion *region1 = [[CLCircularRegion alloc] initWithCenter:emarsysLocation
                                                                  radius:10
                                                              identifier:@"1"];
    CLCircularRegion *region2 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(47.493812, 19.058537)
                                                                  radius:10
                                                              identifier:@"2"];
    CLCircularRegion *region3 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(47.492292, 19.056440)
                                                                  radius:10
                                                              identifier:@"3"];
    CLCircularRegion *region4 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(47.493827, 19.060715)
                                                                  radius:10
                                                              identifier:@"4"];
    CLCircularRegion *region5 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(47.489680, 19.061230)
                                                                  radius:10
                                                              identifier:@"5"];
    CLCircularRegion *regionArea = [[CLCircularRegion alloc] initWithCenter:emarsysLocation
                                                                     radius:130.02930399457298
                                                                 identifier:@"EMSRefreshArea"];

    [self.geofenceInternal setCurrentLocation:currentLocation];
    [self.geofenceInternal setGeofenceResponse:[self createExpectedResponse]];
    [self.geofenceInternal setRecalculateable:YES];

    [self.geofenceInternal registerGeofences];

    OCMVerify([self.mockLocationManager startMonitoringForRegion:[self argForRegion:region1]]);
    OCMVerify([self.mockLocationManager startMonitoringForRegion:[self argForRegion:region2]]);
    OCMVerify([self.mockLocationManager startMonitoringForRegion:[self argForRegion:region3]]);
    OCMVerify([self.mockLocationManager startMonitoringForRegion:[self argForRegion:region4]]);
    OCMVerify([self.mockLocationManager startMonitoringForRegion:[self argForRegion:region5]]);
    OCMVerify([self.mockLocationManager startMonitoringForRegion:[self argForRegion:regionArea]]);
}

- (void)testRegisterGeofences_shouldNotStartMonitoring_whenNotRecalculateable {
    CLLocationCoordinate2D emarsysLocation = CLLocationCoordinate2DMake(47.493160, 19.058355);
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:emarsysLocation.latitude
                                                             longitude:emarsysLocation.longitude];
    CLCircularRegion *region1 = [[CLCircularRegion alloc] initWithCenter:emarsysLocation
                                                                  radius:10
                                                              identifier:@"1"];
    CLCircularRegion *region2 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(47.493812, 19.058537)
                                                                  radius:10
                                                              identifier:@"2"];
    CLCircularRegion *region3 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(47.492292, 19.056440)
                                                                  radius:10
                                                              identifier:@"3"];
    CLCircularRegion *region4 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(47.493827, 19.060715)
                                                                  radius:10
                                                              identifier:@"4"];
    CLCircularRegion *region5 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(47.489680, 19.061230)
                                                                  radius:10
                                                              identifier:@"5"];
    CLCircularRegion *regionArea = [[CLCircularRegion alloc] initWithCenter:emarsysLocation
                                                                     radius:433.431 * self.refreshRadiusRatio
                                                                 identifier:@"EMSRefreshArea"];

    [self.geofenceInternal setCurrentLocation:currentLocation];
    [self.geofenceInternal setGeofenceResponse:[self createExpectedResponse]];

    OCMReject([self.mockLocationManager startMonitoringForRegion:[self argForRegion:region1]]);
    OCMReject([self.mockLocationManager startMonitoringForRegion:[self argForRegion:region2]]);
    OCMReject([self.mockLocationManager startMonitoringForRegion:[self argForRegion:region3]]);
    OCMReject([self.mockLocationManager startMonitoringForRegion:[self argForRegion:region4]]);
    OCMReject([self.mockLocationManager startMonitoringForRegion:[self argForRegion:region5]]);
    OCMReject([self.mockLocationManager startMonitoringForRegion:[self argForRegion:regionArea]]);

    [self.geofenceInternal setRecalculateable:NO];

    [self.geofenceInternal registerGeofences];
}

- (void)testDidEnter_triggerMobileEngageInternalEvent {
    id <EMSEventHandler> handler = OCMProtocolMock(@protocol(EMSEventHandler));

    id mockAction = OCMProtocolMock(@protocol(EMSActionProtocol));
    OCMStub([self.mockActionFactory createActionWithActionDictionary:(@{
            @"id": @"testActionId1",
            @"title": @"Custom event",
            @"type": @"MECustomEvent",
            @"name": @"nameValue",
            @"payload": @{
                    @"someKey": @"someValue"
            }})]).andReturn(mockAction);

    OCMReject([self.mockActionFactory createActionWithActionDictionary:(@{@"id": @"testActionId2",
            @"type": @"BadgeCount",
            @"method": @"add",
            @"value": @1
    })]);

    EMSGeofence *geofence = [self createGeofenceWithId:@"geofenceId"
                                                   lat:12.34
                                                   lon:56.78
                                                     r:12];
    CLCircularRegion *enteringRegion = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(12.34, 56.78)
                                                                         radius:12
                                                                     identifier:@"geofenceId"];
    [self.geofenceInternal setRegisteredGeofences:[@{@"geofenceId": geofence} mutableCopy]];
    [self.geofenceInternal setEventHandler:handler];

    [self.geofenceInternal locationManager:self.mockLocationManager
                            didEnterRegion:enteringRegion];

    [self waitForOperation];

    OCMVerify([self.mockActionFactory setEventHandler:handler]);
    OCMVerify([self.mockActionFactory createActionWithActionDictionary:(@{
            @"id": @"testActionId1",
            @"title": @"Custom event",
            @"type": @"MECustomEvent",
            @"name": @"nameValue",
            @"payload": @{
                    @"someKey": @"someValue"
            }})]);
    OCMVerify([mockAction execute]);
}

- (void)testDidExit_triggerBadgeCountEvent {
    id <EMSEventHandler> handler = OCMProtocolMock(@protocol(EMSEventHandler));
    id mockAction = OCMProtocolMock(@protocol(EMSActionProtocol));
    OCMStub([self.mockActionFactory createActionWithActionDictionary:(@{@"id": @"testActionId2",
            @"type": @"BadgeCount",
            @"method": @"add",
            @"value": @1
    })]).andReturn(mockAction);

    OCMReject([self.mockActionFactory createActionWithActionDictionary:(@{
            @"id": @"testActionId1",
            @"title": @"Custom event",
            @"type": @"MECustomEvent",
            @"name": @"nameValue",
            @"payload": @{
                    @"someKey": @"someValue"
            }})]);

    EMSGeofence *geofence = [self createGeofenceWithId:@"geofenceId"
                                                   lat:12.34
                                                   lon:56.78
                                                     r:12];
    CLCircularRegion *enteringRegion = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(12.34, 56.78)
                                                                         radius:12
                                                                     identifier:@"geofenceId"];
    [self.geofenceInternal setRegisteredGeofences:[@{@"geofenceId": geofence} mutableCopy]];
    [self.geofenceInternal setEventHandler:handler];

    [self.geofenceInternal locationManager:self.mockLocationManager
                             didExitRegion:enteringRegion];

    [self waitForOperation];

    OCMVerify([self.mockActionFactory setEventHandler:handler]);
    OCMVerify([self.mockActionFactory createActionWithActionDictionary:(@{@"id": @"testActionId2",
            @"type": @"BadgeCount",
            @"method": @"add",
            @"value": @1
    })]);
    OCMVerify([mockAction execute]);
}

- (void)testDidExit_recalculate {
    CLCircularRegion *region1 = OCMClassMock([CLCircularRegion class]);
    CLCircularRegion *region2 = OCMClassMock([CLCircularRegion class]);
    CLCircularRegion *region3 = OCMClassMock([CLCircularRegion class]);
    NSSet *monitoredRegions = [NSSet setWithArray:@[region1, region2, region3]];

    OCMStub([self.mockLocationManager monitoredRegions]).andReturn(monitoredRegions);

    EMSGeofenceInternal *partialGeofenceInternal = OCMPartialMock(self.geofenceInternal);

    EMSGeofence *geofence = [self createGeofenceWithId:@"EMSRefreshArea"
                                                   lat:12.34
                                                   lon:56.78
                                                     r:12];
    CLCircularRegion *enteringRegion = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(12.34, 56.78)
                                                                         radius:12
                                                                     identifier:@"EMSRefreshArea"];
    [partialGeofenceInternal setRegisteredGeofences:[@{@"EMSRefreshArea": geofence} mutableCopy]];

    OCMReject([self.mockActionFactory createActionWithActionDictionary:[OCMArg any]]);

    [partialGeofenceInternal locationManager:self.mockLocationManager
                               didExitRegion:enteringRegion];

    [self waitForOperation];

    OCMVerify([self.mockLocationManager monitoredRegions]);
    OCMVerify([self.mockLocationManager stopMonitoringForRegion:region1]);
    OCMVerify([self.mockLocationManager stopMonitoringForRegion:region2]);
    OCMVerify([self.mockLocationManager stopMonitoringForRegion:region3]);

    OCMVerify([partialGeofenceInternal registerGeofences]);
    XCTAssertEqual(partialGeofenceInternal.recalculateable, YES);
}

- (void)testDidUpdateLocation_schedulesToCoreQueue {
    NSOperationQueue *mockQueue = OCMClassMock([NSOperationQueue class]);
    EMSGeofenceInternal *geofence = [[EMSGeofenceInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                                                         requestManager:self.mockRequestManager
                                                                         responseMapper:self.mockResponseMapper
                                                                        locationManager:self.mockLocationManager
                                                                          actionFactory:self.mockActionFactory
                                                                                storage:self.mockStorage
                                                                                  queue:mockQueue];
    [geofence locationManager:self.mockLocationManager
           didUpdateLocations:@[]];

    OCMVerify([mockQueue addOperationWithBlock:[OCMArg any]]);
}

- (void)testDidEnterRegion_schedulesToCoreQueue {
    NSOperationQueue *mockQueue = OCMClassMock([NSOperationQueue class]);
    EMSGeofenceInternal *geofence = [[EMSGeofenceInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                                                         requestManager:self.mockRequestManager
                                                                         responseMapper:self.mockResponseMapper
                                                                        locationManager:self.mockLocationManager
                                                                          actionFactory:self.mockActionFactory
                                                                                storage:self.mockStorage
                                                                                  queue:mockQueue];

    [geofence locationManager:self.mockLocationManager
               didEnterRegion:OCMClassMock([CLRegion class])];

    OCMVerify([mockQueue addOperationWithBlock:[OCMArg any]]);
}

- (void)testDidExitRegion_schedulesToCoreQueue {
    NSOperationQueue *mockQueue = OCMClassMock([NSOperationQueue class]);
    EMSGeofenceInternal *geofence = [[EMSGeofenceInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                                                         requestManager:self.mockRequestManager
                                                                         responseMapper:self.mockResponseMapper
                                                                        locationManager:self.mockLocationManager
                                                                          actionFactory:self.mockActionFactory
                                                                                storage:self.mockStorage
                                                                                  queue:mockQueue];
    [geofence locationManager:self.mockLocationManager
                didExitRegion:OCMClassMock([CLRegion class])];

    [self waitForOperation];

    OCMVerify([mockQueue addOperationWithBlock:[OCMArg any]]);
}

- (EMSGeofenceResponse *)createExpectedResponse {
    return [[EMSGeofenceResponse alloc] initWithGroups:@[
                    [[EMSGeofenceGroup alloc] initWithId:@"geoGroupId1"
                                            waitInterval:20
                                               geofences:@[
                                                       [self createGeofenceWithId:@"1"
                                                                              lat:47.493160
                                                                              lon:19.058355
                                                                                r:10],
                                                       [self createGeofenceWithId:@"2"
                                                                              lat:47.493812
                                                                              lon:19.058537
                                                                                r:10],
                                                       [self createGeofenceWithId:@"4"
                                                                              lat:47.493827
                                                                              lon:19.060715
                                                                                r:10]
                                               ]],
                    [[EMSGeofenceGroup alloc] initWithId:@"geoGroupId2"
                                            waitInterval:20
                                               geofences:@[
                                                       [self createGeofenceWithId:@"5"
                                                                              lat:47.489680
                                                                              lon:19.061230
                                                                                r:10],
                                                       [self createGeofenceWithId:@"3"
                                                                              lat:47.492292
                                                                              lon:19.056440
                                                                                r:10]
                                               ]]]
                                    refreshRadiusRatio:0.3];
}

- (EMSGeofenceResponse *)createResponseWithBigRadius {
    return [[EMSGeofenceResponse alloc] initWithGroups:@[
                    [[EMSGeofenceGroup alloc] initWithId:@"geoGroupId1"
                                            waitInterval:20
                                               geofences:@[
                                                       [self createGeofenceWithId:@"1"
                                                                              lat:47.493160
                                                                              lon:19.058355
                                                                                r:200],
                                                       [self createGeofenceWithId:@"2"
                                                                              lat:47.493812
                                                                              lon:19.058537
                                                                                r:200],
                                                       [self createGeofenceWithId:@"4"
                                                                              lat:47.493827
                                                                              lon:19.060715
                                                                                r:200]
                                               ]],
                    [[EMSGeofenceGroup alloc] initWithId:@"geoGroupId2"
                                            waitInterval:20
                                               geofences:@[
                                                       [self createGeofenceWithId:@"5"
                                                                              lat:47.489680
                                                                              lon:19.061230
                                                                                r:200],
                                                       [self createGeofenceWithId:@"3"
                                                                              lat:47.492292
                                                                              lon:19.056440
                                                                                r:200]
                                               ]]]
                                    refreshRadiusRatio:0.3];
}

- (EMSGeofence *)createGeofenceWithId:(NSString *)id
                                  lat:(double)lat
                                  lon:(double)lon
                                    r:(int)r {
    return [[EMSGeofence alloc] initWithId:id
                                       lat:lat
                                       lon:lon
                                         r:r
                              waitInterval:30
                                  triggers:@[[[EMSGeofenceTrigger alloc] initWithId:@"triggerId1"
                                                                               type:@"ENTER"
                                                                     loiteringDelay:7
                                                                             action:@{@"id": @"testActionId1",
                                                                                     @"title": @"Custom event",
                                                                                     @"type": @"MECustomEvent",
                                                                                     @"name": @"nameValue",
                                                                                     @"payload": @{
                                                                                             @"someKey": @"someValue"
                                                                                     }}],
                                          [[EMSGeofenceTrigger alloc] initWithId:@"triggerId2"
                                                                            type:@"EXIT"
                                                                  loiteringDelay:7
                                                                          action:@{@"id": @"testActionId2",
                                                                                  @"type": @"BadgeCount",
                                                                                  @"method": @"add",
                                                                                  @"value": @1
                                                                          }]
                                  ]];
}

- (OCMArg *)argForRegion:(CLCircularRegion *)expectedRegion {
    return [OCMArg checkWithBlock:^BOOL(CLCircularRegion *region) {
        BOOL result = YES;
        if (expectedRegion.center.latitude != region.center.latitude) {
            result = NO;
            return result;
        }
        if (expectedRegion.center.longitude != region.center.longitude) {
            result = NO;
            return result;
        }
        if (expectedRegion.radius != region.radius) {
            result = NO;
            return result;
        }
        if (![expectedRegion.identifier isEqualToString:region.identifier]) {
            result = NO;
            return result;
        }
        return result;
    }];
}

- (void)waitForOperation {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"expectation"];

    [self.queue addOperationWithBlock:^{
        [expectation fulfill];
    }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
}


@end
