//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <UserNotifications/UserNotifications.h>
#import <AdSupport/AdSupport.h>
#import "EMSDeviceInfoV3ClientInternal.h"
#import "EMSDeviceInfo+MEClientPayload.h"
#import "EMSRequestManager.h"
#import "EMSRequestFactory.h"
#import "MERequestContext.h"
#import "EMSStorage.h"

@interface EMSDeviceInfoV3ClientInternalTests : XCTestCase

@property(nonatomic, strong) EMSDeviceInfoV3ClientInternal *deviceInfoInternal;
@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;
@property(nonatomic, strong) EMSDeviceInfo *mockDeviceInfo;
@property(nonatomic, strong) MERequestContext *mockRequestContext;
@property(nonatomic, strong) NSArray <NSString *> *suiteNames;

@end

@implementation EMSDeviceInfoV3ClientInternalTests

- (void)setUp {
    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    _mockDeviceInfo = OCMClassMock([EMSDeviceInfo class]);
    _mockRequestContext = OCMClassMock([MERequestContext class]);

    _deviceInfoInternal = [[EMSDeviceInfoV3ClientInternal alloc] initWithRequestManager:self.mockRequestManager
                                                                         requestFactory:self.mockRequestFactory
                                                                             deviceInfo:self.mockDeviceInfo
                                                                         requestContext:self.mockRequestContext];

    _suiteNames = @[@"com.emarsys.core", @"com.emarsys.predict", @"com.emarsys.mobileengage"];
}

- (void)testInit_requestManager_mustNotBeNil {
    @try {
        [[EMSDeviceInfoV3ClientInternal alloc] initWithRequestManager:nil
                                                       requestFactory:self.mockRequestFactory
                                                           deviceInfo:self.mockDeviceInfo
                                                       requestContext:self.mockRequestContext];
        XCTFail(@"Expected Exception when requestManager is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestManager");
    }
}

- (void)testInit_requestFactory_mustNotBeNil {
    @try {
        [[EMSDeviceInfoV3ClientInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       requestFactory:nil
                                                           deviceInfo:self.mockDeviceInfo
                                                       requestContext:self.mockRequestContext];
        XCTFail(@"Expected Exception when requestFactory is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestFactory");
    }
}

- (void)testInit_deviceInfo_mustNotBeNil {
    @try {
        [[EMSDeviceInfoV3ClientInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       requestFactory:self.mockRequestFactory
                                                           deviceInfo:nil
                                                       requestContext:self.mockRequestContext];
        XCTFail(@"Expected Exception when deviceInfo is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: deviceInfo");
    }
}

- (void)testInit_requestContext_mustNotBeNil {
    @try {
        [[EMSDeviceInfoV3ClientInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       requestFactory:self.mockRequestFactory
                                                           deviceInfo:self.mockDeviceInfo
                                                       requestContext:nil];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestContext");
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
    OCMStub(self.mockRequestContext.clientState).andReturn(@"testClientState");

    EMSDeviceInfo *deviceInfo = [[EMSDeviceInfo alloc] initWithSDKVersion:@"0.0.1"
                                                       notificationCenter:[UNUserNotificationCenter currentNotificationCenter]
                                                                  storage:[[EMSStorage alloc]
                                                                          initWithOperationQueue:[NSOperationQueue new]
                                                                                      suiteNames:self.suiteNames]
                                                        identifierManager:[ASIdentifierManager sharedManager]];

    _deviceInfoInternal = [[EMSDeviceInfoV3ClientInternal alloc] initWithRequestManager:self.mockRequestManager
                                                                         requestFactory:self.mockRequestFactory
                                                                             deviceInfo:deviceInfo
                                                                         requestContext:self.mockRequestContext];
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

- (void)testSendDeviceInfo_shouldSubmit_whenClientStateIsMissing {
    EMSCompletionBlock completionBlock = ^(NSError *error) {
    };
    OCMStub(self.mockRequestContext.clientState).andReturn(nil);

    EMSDeviceInfo *deviceInfo = [[EMSDeviceInfo alloc] initWithSDKVersion:@"0.0.1"
                                                       notificationCenter:[UNUserNotificationCenter currentNotificationCenter]
                                                                  storage:[[EMSStorage alloc] initWithOperationQueue:[NSOperationQueue new]
                                                                                                          suiteNames:self.suiteNames]
                                                        identifierManager:[ASIdentifierManager sharedManager]];
    _deviceInfoInternal = [[EMSDeviceInfoV3ClientInternal alloc] initWithRequestManager:self.mockRequestManager
                                                                         requestFactory:self.mockRequestFactory
                                                                             deviceInfo:deviceInfo
                                                                         requestContext:self.mockRequestContext];
    EMSRequestModel *requestModel = OCMClassMock([EMSRequestModel class]);

    OCMStub([self.mockRequestFactory createDeviceInfoRequestModel]).andReturn(requestModel);

    [self.deviceInfoInternal sendDeviceInfoWithCompletionBlock:completionBlock];

    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:completionBlock]);
}

@end
