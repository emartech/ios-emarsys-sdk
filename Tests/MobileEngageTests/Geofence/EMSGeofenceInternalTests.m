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

@interface EMSGeofenceInternalTests : XCTestCase

@property(nonatomic, strong) EMSGeofenceInternal *geofenceInternal;
@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;
@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) EMSGeofenceResponseMapper *mockResponseMapper;
@property(nonatomic, strong) EMSRequestModel *mockRequestModel;
@property(nonatomic, strong) EMSResponseModel *mockResponseModel;
@property(nonatomic, strong) id mockLocationManager;

@end

@implementation EMSGeofenceInternalTests

- (void)setUp {
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockRequestModel = OCMClassMock([EMSRequestModel class]);
    _mockResponseModel = OCMClassMock([EMSResponseModel class]);
    _mockResponseMapper = OCMClassMock([EMSGeofenceResponseMapper class]);

    _mockLocationManager = OCMClassMock([CLLocationManager class]);

    OCMStub([self.mockRequestFactory createGeofenceRequestModel]).andReturn(self.mockRequestModel);

    _geofenceInternal = [[EMSGeofenceInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                                             requestManager:self.mockRequestManager
                                                             responseMapper:self.mockResponseMapper
                                                            locationManager:self.mockLocationManager];
}

- (void)tearDown {
    [self.mockLocationManager stopMocking];
}

- (void)testInit_requestFactory_mustNotBeNil {
    @try {
        [[EMSGeofenceInternal alloc] initWithRequestFactory:nil
                                             requestManager:self.mockRequestManager
                                             responseMapper:self.mockResponseMapper
                                            locationManager:self.mockLocationManager];
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
                                            locationManager:self.mockLocationManager];
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
                                            locationManager:self.mockLocationManager];
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
                                            locationManager:nil];
        XCTFail(@"Expected Exception when locationManager is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: locationManager");
    }
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

- (void)testRequestAlwaysAuthorization {
    [self.geofenceInternal requestAlwaysAuthorization];

    OCMVerify([self.mockLocationManager requestAlwaysAuthorization]);
}

- (void)testEnable {
    OCMStub([self.mockLocationManager authorizationStatus]).andReturn(kCLAuthorizationStatusAuthorizedAlways);

    [self.geofenceInternal enableWithCompletionBlock:^(NSError *error) {
    }];

    OCMVerify([self.mockLocationManager startUpdatingLocation]);
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
                                                          timeout:1];

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


@end
