//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSGeofenceInternal.h"
#import "EMSRequestFactory.h"
#import "EMSRequestManager.h"
#import "EMSGeofenceResponseMapper.h"
#import "EMSResponseModel.h"

@interface EMSGeofenceInternalTests : XCTestCase

@property(nonatomic, strong) EMSGeofenceInternal *geofenceInternal;
@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;
@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) EMSGeofenceResponseMapper *mockResponseMapper;
@property(nonatomic, strong) EMSRequestModel *mockRequestModel;
@property(nonatomic, strong) EMSResponseModel *mockResponseModel;

@end

@implementation EMSGeofenceInternalTests

- (void)setUp {
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockRequestModel = OCMClassMock([EMSRequestModel class]);
    _mockResponseModel = OCMClassMock([EMSResponseModel class]);
    _mockResponseMapper = OCMClassMock([EMSGeofenceResponseMapper class]);

    OCMStub([self.mockRequestFactory createGeofenceRequestModel]).andReturn(self.mockRequestModel);

    _geofenceInternal = [[EMSGeofenceInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                                             requestManager:self.mockRequestManager
                                                             responseMapper:self.mockResponseMapper];
}

- (void)testInit_requestFactory_mustNotBeNil {
    @try {
        [[EMSGeofenceInternal alloc] initWithRequestFactory:nil
                                             requestManager:self.mockRequestManager
                                             responseMapper:self.mockResponseMapper];
        XCTFail(@"Expected Exception when requestFactory is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestFactory");
    }
}

- (void)testInit_requestManager_mustNotBeNil {
    @try {
        [[EMSGeofenceInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                             requestManager:nil
                                             responseMapper:self.mockResponseMapper];
        XCTFail(@"Expected Exception when requestManager is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestManager");
    }
}

- (void)testInit_responseMapper_mustNotBeNil {
    @try {
        [[EMSGeofenceInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                             requestManager:self.mockRequestManager
                                             responseMapper:nil];
        XCTFail(@"Expected Exception when responseMapper is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: responseMapper");
    }
}

- (void)testFetchGeofence {
    OCMStub([self.mockRequestManager submitRequestModelNow:self.mockRequestModel
                                              successBlock:([OCMArg invokeBlockWithArgs:@"testRequestId", self.mockResponseModel, nil])
                                                errorBlock:[OCMArg any]]);

    [self.geofenceInternal fetchGeofences];

    OCMVerify([self.mockRequestManager submitRequestModelNow:self.mockRequestModel
                                                successBlock:[OCMArg any]
                                                  errorBlock:[OCMArg any]]);
    OCMVerify([self.mockResponseMapper mapFromResponseModel:self.mockResponseModel]);
}


@end
