//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSDeviceInfoV3ClientInternal.h"
#import "EMSDeviceInfo+MEClientPayload.h"
#import "EMSRequestManager.h"
#import "EMSRequestFactory.h"
#import "MERequestContext.h"

@interface EMSDeviceInfoV3ClientInternalTests : XCTestCase

@property(nonatomic, strong) EMSDeviceInfoV3ClientInternal *deviceInfoInternal;
@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;
@property(nonatomic, strong) EMSDeviceInfo *mockDeviceInfo;

@end

@implementation EMSDeviceInfoV3ClientInternalTests

- (void)setUp {
    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    _mockDeviceInfo = OCMClassMock([EMSDeviceInfo class]);

    _deviceInfoInternal = [[EMSDeviceInfoV3ClientInternal alloc] initWithRequestManager:self.mockRequestManager
                                                                         requestFactory:self.mockRequestFactory
                                                                             deviceInfo:self.mockDeviceInfo];
}

- (void)testInit_requestManager_mustNotBeNil {
    @try {
        [[EMSDeviceInfoV3ClientInternal alloc] initWithRequestManager:nil
                                                       requestFactory:self.mockRequestFactory
                                                           deviceInfo:self.mockDeviceInfo];
        XCTFail(@"Expected Exception when requestManager is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestManager");
    }
}

- (void)testInit_requestFactory_mustNotBeNil {
    @try {
        [[EMSDeviceInfoV3ClientInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       requestFactory:nil
                                                           deviceInfo:self.mockDeviceInfo];
        XCTFail(@"Expected Exception when requestFactory is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestFactory");
    }
}

- (void)testInit_deviceInfo_mustNotBeNil {
    @try {
        [[EMSDeviceInfoV3ClientInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       requestFactory:self.mockRequestFactory
                                                           deviceInfo:nil];
        XCTFail(@"Expected Exception when deviceInfo is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: deviceInfo");
    }
}

- (void)testSendDeviceInfo_submitRequest {
    EMSCompletionBlock completionBlock = ^(NSError *error) {
    };
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
    [userDefaults setObject:@{@"testStoredPayloadKey": @"testStoredPayloadValue"}
                     forKey:kDEVICE_INFO];
    [userDefaults synchronize];

    NSDictionary *expectedDeviceInfoDict = @{
        @"testPayloadKey": @"testPayloadValue",
        @"testPayloadKey2": @"testPayloadValue2"
    };
    EMSRequestModel *requestModel = OCMClassMock([EMSRequestModel class]);

    OCMStub([self.mockDeviceInfo clientPayload]).andReturn(expectedDeviceInfoDict);
    OCMStub([self.mockRequestFactory createDeviceInfoRequestModel]).andReturn(requestModel);

    [self.deviceInfoInternal sendDeviceInfoWithCompletionBlock:completionBlock];

    NSDictionary *storedDeviceInfoDict = [userDefaults dictionaryForKey:kDEVICE_INFO];

    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:completionBlock]);
    XCTAssertEqualObjects(storedDeviceInfoDict, expectedDeviceInfoDict);
}

- (void)testSendDeviceInfo_shouldNotSubmit_whenDeviceInfoHasNotChanged {
    EMSDeviceInfo *deviceInfo = [[EMSDeviceInfo alloc] initWithSDKVersion:@"0.0.1"];
    _deviceInfoInternal = [[EMSDeviceInfoV3ClientInternal alloc] initWithRequestManager:self.mockRequestManager
                                                                         requestFactory:self.mockRequestFactory
                                                                             deviceInfo:deviceInfo];
    OCMReject([self.mockRequestManager submitRequestModel:[OCMArg any]
                                      withCompletionBlock:[OCMArg any]]);

    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];

    NSDictionary *deviceInfoDictionary = [deviceInfo clientPayload];
    [userDefaults setObject:deviceInfoDictionary
                     forKey:kDEVICE_INFO];
    [userDefaults synchronize];

    [self.deviceInfoInternal sendDeviceInfoWithCompletionBlock:^(NSError *error) {
    }];
}

@end
