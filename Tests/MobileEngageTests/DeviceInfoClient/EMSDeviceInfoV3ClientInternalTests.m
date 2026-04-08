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
#import "NSError+EMSCore.h"
#import "EMSUUIDProvider.h"
#import "XCTestCase+Helper.h"
#import "MEExperimental+Test.h"
#import "EMSInnerFeature.h"

@interface EMSDeviceInfoV3ClientInternalTests : XCTestCase

@property(nonatomic, strong) EMSDeviceInfoV3ClientInternal *deviceInfoInternal;
@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;
@property(nonatomic, strong) EMSDeviceInfo *mockDeviceInfo;
@property(nonatomic, strong) MERequestContext *mockRequestContext;
@property(nonatomic, strong) NSArray <NSString *> *suiteNames;
@property(nonatomic, strong) EMSUUIDProvider *uuidProvider;
@property(nonatomic, strong) NSOperationQueue *queue;

@end

@implementation EMSDeviceInfoV3ClientInternalTests

- (void)setUp {
    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    _mockDeviceInfo = OCMClassMock([EMSDeviceInfo class]);
    _mockRequestContext = OCMClassMock([MERequestContext class]);
    _uuidProvider = [EMSUUIDProvider new];
    _queue = [self createTestOperationQueue];
    
    _deviceInfoInternal = [[EMSDeviceInfoV3ClientInternal alloc] initWithRequestManager:self.mockRequestManager
                                                                         requestFactory:self.mockRequestFactory
                                                                             deviceInfo:self.mockDeviceInfo
                                                                         requestContext:self.mockRequestContext];
    
    _suiteNames = @[@"com.emarsys.core", @"com.emarsys.predict", @"com.emarsys.mobileengage"];
}

- (void)tearDown {
    [super tearDown];
    [MEExperimental reset];
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
    [MEExperimental enableFeature:EMSInnerFeature.mobileEngage];
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
    
    [self.deviceInfoInternal trackDeviceInfoWithCompletionBlock:completionBlock];
    
    NSDictionary *storedDeviceInfoDict = [userDefaults dictionaryForKey:kDEVICE_INFO];
    
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:completionBlock]);
    XCTAssertEqualObjects(storedDeviceInfoDict, expectedDeviceInfoDict);
}

- (void)testSendDeviceInfo_shouldNotSubmit_whenDeviceInfoHasNotChanged {
    OCMStub(self.mockRequestContext.clientState).andReturn(@"testClientState");
    
    EMSDeviceInfo *deviceInfo = [[EMSDeviceInfo alloc] initWithSDKVersion:@"0.0.1"
                                                       notificationCenter:[UNUserNotificationCenter currentNotificationCenter]
                                                                  storage:[[EMSStorage alloc] initWithSuiteNames:self.suiteNames
                                                                                                     accessGroup:nil
                                                                                                  operationQueue:self.queue]
                                                             uuidProvider:self.uuidProvider];
    
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
    
    __block NSError *returnedError = [NSError errorWithCode:-1400
                                       localizedDescription:@"testError"];
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];
    [self.deviceInfoInternal trackDeviceInfoWithCompletionBlock:^(NSError *error) {
        returnedError = error;
        [expectation fulfill];
    }];
    
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:5];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
}

- (void)testSendDeviceInfo_shouldSubmit_whenClientStateIsMissing {
    [MEExperimental enableFeature:EMSInnerFeature.mobileEngage];
    EMSCompletionBlock completionBlock = ^(NSError *error) {
    };
    OCMStub(self.mockRequestContext.clientState).andReturn(nil);
    
    EMSDeviceInfo *deviceInfo = [[EMSDeviceInfo alloc] initWithSDKVersion:@"0.0.1"
                                                       notificationCenter:[UNUserNotificationCenter currentNotificationCenter]
                                                                  storage:[[EMSStorage alloc] initWithSuiteNames:self.suiteNames
                                                                                                     accessGroup:nil
                                                                                                  operationQueue:self.queue]
                                                             uuidProvider:self.uuidProvider];
    _deviceInfoInternal = [[EMSDeviceInfoV3ClientInternal alloc] initWithRequestManager:self.mockRequestManager
                                                                         requestFactory:self.mockRequestFactory
                                                                             deviceInfo:deviceInfo
                                                                         requestContext:self.mockRequestContext];
    EMSRequestModel *requestModel = OCMClassMock([EMSRequestModel class]);
    
    OCMStub([self.mockRequestFactory createDeviceInfoRequestModel]).andReturn(requestModel);
    
    [self.deviceInfoInternal trackDeviceInfoWithCompletionBlock:completionBlock];
    
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:completionBlock]);
}

- (void)testTrackDeviceInfo_shouldCallSendDeviceInfo {
    EMSDeviceInfoV3ClientInternal *partialDeviceInfoClient = OCMPartialMock(self.deviceInfoInternal);
    
    EMSCompletionBlock completionBlock = ^(NSError *error) {
        
    };
    
    [partialDeviceInfoClient trackDeviceInfoWithCompletionBlock:completionBlock];
    
    OCMVerify([partialDeviceInfoClient sendDeviceInfoWithCompletionBlock:completionBlock]);
}

@end
