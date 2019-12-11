//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSConfigInternal.h"
#import "MERequestContext.h"
#import "PRERequestContext.h"
#import "EMSMobileEngageV3Internal.h"
#import "NSError+EMSCore.h"
#import "EMSPushV3Internal.h"
#import "EMSDeviceInfo.h"
#import "EMSRequestManager.h"
#import "EMSEmarsysRequestFactory.h"
#import "EMSRemoteConfigResponseMapper.h"
#import "EMSEndpoint.h"
#import "FakeRequestManager.h"
#import "EMSResponseModel.h"
#import "EMSRemoteConfig.h"

@interface EMSConfigInternal (Tests)

- (void)callCompletionBlock:(EMSCompletionBlock)completionBlock
                  withError:(NSError *)error;

@end

@interface EMSConfigInternalTests : XCTestCase

@property(nonatomic, strong) EMSConfigInternal *configInternal;
@property(nonatomic, strong) NSString *applicationCode;
@property(nonatomic, strong) NSString *merchantId;
@property(nonatomic, strong) NSNumber *contactFieldId;
@property(nonatomic, strong) EMSConfig *testConfig;
@property(nonatomic, strong) NSArray<id <EMSFlipperFeature>> *features;
@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) MERequestContext *mockMeRequestContext;
@property(nonatomic, strong) PRERequestContext *mockPreRequestContext;
@property(nonatomic, strong) EMSMobileEngageV3Internal *mockMobileEngage;
@property(nonatomic, strong) EMSDeviceInfo *mockDeviceInfo;
@property(nonatomic, strong) EMSPushV3Internal *mockPushInternal;
@property(nonatomic, strong) EMSEmarsysRequestFactory *mockEmarsysRequestFactory;
@property(nonatomic, strong) NSString *contactFieldValue;
@property(nonatomic, strong) NSData *deviceToken;
@property(nonatomic, strong) EMSRemoteConfigResponseMapper *mockResponseMapper;
@property(nonatomic, strong) EMSEndpoint *mockEndpoint;

@end

@implementation EMSConfigInternalTests

- (void)setUp {
    _applicationCode = @"testApplicationCode";
    _merchantId = @"testMerchantId";
    _contactFieldId = @3;
    _contactFieldValue = @"testContactFieldValue";
    _deviceToken = [@"token" dataUsingEncoding:NSUTF8StringEncoding];
    id <EMSFlipperFeature> feature = OCMProtocolMock(@protocol(EMSFlipperFeature));
    _features = @[feature];

    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockMeRequestContext = OCMClassMock([MERequestContext class]);
    _mockPreRequestContext = OCMClassMock([PRERequestContext class]);
    _mockMobileEngage = OCMClassMock([EMSMobileEngageV3Internal class]);
    _mockPushInternal = OCMClassMock([EMSPushV3Internal class]);
    _mockDeviceInfo = OCMClassMock([EMSDeviceInfo class]);
    _mockEmarsysRequestFactory = OCMClassMock([EMSEmarsysRequestFactory class]);
    _mockResponseMapper = OCMClassMock([EMSRemoteConfigResponseMapper class]);
    _mockEndpoint = OCMClassMock([EMSEndpoint class]);

    OCMStub([self.mockMeRequestContext contactFieldValue]).andReturn(self.contactFieldValue);
    OCMStub([self.mockPushInternal deviceToken]).andReturn(self.deviceToken);

    _testConfig = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
        [builder setMobileEngageApplicationCode:self.applicationCode];
        [builder setMerchantId:self.merchantId];
        [builder setContactFieldId:self.contactFieldId];
        [builder setExperimentalFeatures:self.features];
    }];

    _configInternal = [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       meRequestContext:self.mockMeRequestContext
                                                      preRequestContext:self.mockPreRequestContext
                                                           mobileEngage:self.mockMobileEngage
                                                           pushInternal:self.mockPushInternal
                                                             deviceInfo:self.mockDeviceInfo
                                                  emarsysRequestFactory:self.mockEmarsysRequestFactory
                                             remoteConfigResponseMapper:self.mockResponseMapper
                                                               endpoint:self.mockEndpoint];
}

- (void)testInit_requestManager_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithRequestManager:nil
                                         meRequestContext:self.mockMeRequestContext
                                        preRequestContext:self.mockPreRequestContext
                                             mobileEngage:self.mockMobileEngage
                                             pushInternal:self.mockPushInternal
                                               deviceInfo:self.mockDeviceInfo
                                    emarsysRequestFactory:self.mockEmarsysRequestFactory
                               remoteConfigResponseMapper:self.mockResponseMapper
                                                 endpoint:self.mockEndpoint];
        XCTFail(@"Expected Exception when requestManager is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestManager");
    }
}

- (void)testInit_meRequestContext_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                         meRequestContext:nil
                                        preRequestContext:self.mockPreRequestContext
                                             mobileEngage:self.mockMobileEngage
                                             pushInternal:self.mockPushInternal
                                               deviceInfo:self.mockDeviceInfo
                                    emarsysRequestFactory:self.mockEmarsysRequestFactory
                               remoteConfigResponseMapper:self.mockResponseMapper
                                                 endpoint:self.mockEndpoint];
        XCTFail(@"Expected Exception when meRequestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: meRequestContext");
    }
}

- (void)testInit_mobileEngage_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                         meRequestContext:self.mockMeRequestContext
                                        preRequestContext:self.mockPreRequestContext
                                             mobileEngage:nil
                                             pushInternal:self.mockPushInternal
                                               deviceInfo:self.mockDeviceInfo
                                    emarsysRequestFactory:self.mockEmarsysRequestFactory
                               remoteConfigResponseMapper:self.mockResponseMapper
                                                 endpoint:self.mockEndpoint];
        XCTFail(@"Expected Exception when mobileEngage is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: mobileEngage");
    }
}

- (void)testInit_pushInternal_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                         meRequestContext:self.mockMeRequestContext
                                        preRequestContext:self.mockPreRequestContext
                                             mobileEngage:self.mockMobileEngage
                                             pushInternal:nil
                                               deviceInfo:self.mockDeviceInfo
                                    emarsysRequestFactory:self.mockEmarsysRequestFactory
                               remoteConfigResponseMapper:self.mockResponseMapper
                                                 endpoint:self.mockEndpoint];
        XCTFail(@"Expected Exception when pushInternal is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: pushInternal");
    }
}

- (void)testInit_preRequestContext_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                         meRequestContext:self.mockMeRequestContext
                                        preRequestContext:nil
                                             mobileEngage:self.mockMobileEngage
                                             pushInternal:self.mockPushInternal
                                               deviceInfo:self.mockDeviceInfo
                                    emarsysRequestFactory:self.mockEmarsysRequestFactory
                               remoteConfigResponseMapper:self.mockResponseMapper
                                                 endpoint:self.mockEndpoint];
        XCTFail(@"Expected Exception when preRequestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: preRequestContext");
    }
}

- (void)testInit_deviceInfo_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                         meRequestContext:self.mockMeRequestContext
                                        preRequestContext:self.mockPreRequestContext
                                             mobileEngage:self.mockMobileEngage
                                             pushInternal:self.mockPushInternal
                                               deviceInfo:nil
                                    emarsysRequestFactory:self.mockEmarsysRequestFactory
                               remoteConfigResponseMapper:self.mockResponseMapper
                                                 endpoint:self.mockEndpoint];
        XCTFail(@"Expected Exception when deviceInfo is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: deviceInfo");
    }
}

- (void)testInit_emarsysRequestFactory_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                         meRequestContext:self.mockMeRequestContext
                                        preRequestContext:self.mockPreRequestContext
                                             mobileEngage:self.mockMobileEngage
                                             pushInternal:self.mockPushInternal
                                               deviceInfo:self.mockDeviceInfo
                                    emarsysRequestFactory:nil
                               remoteConfigResponseMapper:self.mockResponseMapper
                                                 endpoint:self.mockEndpoint];
        XCTFail(@"Expected Exception when emarsysRequestFactory is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: emarsysRequestFactory");
    }
}

- (void)testInit_remoteConfigResponseMapper_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                         meRequestContext:self.mockMeRequestContext
                                        preRequestContext:self.mockPreRequestContext
                                             mobileEngage:self.mockMobileEngage
                                             pushInternal:self.mockPushInternal
                                               deviceInfo:self.mockDeviceInfo
                                    emarsysRequestFactory:self.mockEmarsysRequestFactory
                               remoteConfigResponseMapper:nil
                                                 endpoint:self.mockEndpoint];
        XCTFail(@"Expected Exception when remoteConfigResponseMapper is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: remoteConfigResponseMapper");
    }
}

- (void)testInit_endpoint_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                         meRequestContext:self.mockMeRequestContext
                                        preRequestContext:self.mockPreRequestContext
                                             mobileEngage:self.mockMobileEngage
                                             pushInternal:self.mockPushInternal
                                               deviceInfo:self.mockDeviceInfo
                                    emarsysRequestFactory:self.mockEmarsysRequestFactory
                               remoteConfigResponseMapper:self.mockResponseMapper
                                                 endpoint:nil];
        XCTFail(@"Expected Exception when endpoint is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: endpoint");
    }
}

- (void)testChangeApplicationCode_completionHandler_isNil {
    id strictMockMobileEngage = OCMStrictClassMock([EMSMobileEngageV3Internal class]);
    id strictMockPushInternal = OCMStrictClassMock([EMSPushV3Internal class]);

    _configInternal = [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       meRequestContext:self.mockMeRequestContext
                                                      preRequestContext:self.mockPreRequestContext
                                                           mobileEngage:strictMockMobileEngage
                                                           pushInternal:strictMockPushInternal
                                                             deviceInfo:self.mockDeviceInfo
                                                  emarsysRequestFactory:self.mockEmarsysRequestFactory
                                             remoteConfigResponseMapper:self.mockResponseMapper
                                                               endpoint:self.mockEndpoint];

    OCMStub([strictMockPushInternal deviceToken]).andReturn(self.deviceToken);
    OCMStub([strictMockMobileEngage clearContactWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([strictMockPushInternal setPushToken:self.deviceToken
                                 completionBlock:[OCMArg invokeBlock]]);
    OCMStub([strictMockMobileEngage setContactWithContactFieldValue:self.contactFieldValue
                                                    completionBlock:[OCMArg invokeBlock]]);

    __block NSError *returnedError = [NSError errorWithCode:1400
                                       localizedDescription:@"testError"];

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionHandler"];
    [self.configInternal changeApplicationCode:@"newApplicationCode"
                               completionBlock:nil];
    [self.configInternal changeApplicationCode:@"newApplicationCode"
                               completionBlock:^(NSError *error) {
                                   returnedError = error;
                                   [expectation fulfill];
                               }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:5];

    [strictMockMobileEngage setExpectationOrderMatters:YES];
    OCMExpect([strictMockMobileEngage clearContactWithCompletionBlock:[OCMArg any]]);
    [strictMockPushInternal setExpectationOrderMatters:YES];
    OCMExpect([strictMockPushInternal setPushToken:self.deviceToken
                                   completionBlock:[OCMArg any]]);
    OCMExpect([strictMockMobileEngage setContactWithContactFieldValue:self.contactFieldValue
                                                      completionBlock:[OCMArg any]]);

    OCMExpect([strictMockMobileEngage clearContactWithCompletionBlock:[OCMArg any]]);
    OCMExpect([strictMockPushInternal setPushToken:self.deviceToken
                                   completionBlock:[OCMArg any]]);
    OCMExpect([strictMockMobileEngage setContactWithContactFieldValue:self.contactFieldValue
                                                      completionBlock:[OCMArg any]]);

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
}

- (void)testChangeApplicationCode_shouldCallMethodsInOrder {
    id strictMockMobileEngage = OCMStrictClassMock([EMSMobileEngageV3Internal class]);
    id strictMockPushInternal = OCMStrictClassMock([EMSPushV3Internal class]);

    _configInternal = [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       meRequestContext:self.mockMeRequestContext
                                                      preRequestContext:self.mockPreRequestContext
                                                           mobileEngage:strictMockMobileEngage
                                                           pushInternal:strictMockPushInternal
                                                             deviceInfo:self.mockDeviceInfo
                                                  emarsysRequestFactory:self.mockEmarsysRequestFactory
                                             remoteConfigResponseMapper:self.mockResponseMapper
                                                               endpoint:self.mockEndpoint];

    OCMStub([strictMockPushInternal deviceToken]).andReturn(self.deviceToken);
    OCMStub([strictMockMobileEngage clearContactWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([strictMockPushInternal setPushToken:self.deviceToken
                                 completionBlock:[OCMArg invokeBlock]]);
    OCMStub([strictMockMobileEngage setContactWithContactFieldValue:self.contactFieldValue
                                                    completionBlock:[OCMArg invokeBlock]]);

    __block NSError *returnedError = [NSError errorWithCode:1400
                                       localizedDescription:@"testError"];

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionHandler"];
    [self.configInternal changeApplicationCode:@"newApplicationCode"
                               completionBlock:^(NSError *error) {
                                   returnedError = error;
                                   [expectation fulfill];
                               }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:5];

    [strictMockMobileEngage setExpectationOrderMatters:YES];
    OCMExpect([strictMockMobileEngage clearContactWithCompletionBlock:[OCMArg any]]);
    [strictMockPushInternal setExpectationOrderMatters:YES];
    OCMExpect([strictMockPushInternal setPushToken:self.deviceToken
                                   completionBlock:[OCMArg any]]);
    OCMExpect([strictMockMobileEngage setContactWithContactFieldValue:self.contactFieldValue
                                                      completionBlock:[OCMArg any]]);

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
}

- (void)testChangeApplicationCode_clearContact_shouldCallCompletionBlockWithError {
    id strictMockMobileEngage = OCMStrictClassMock([EMSMobileEngageV3Internal class]);
    id strictMockPushInternal = OCMStrictClassMock([EMSPushV3Internal class]);

    NSError *inputError = [NSError errorWithCode:1400
                            localizedDescription:@"testError"];
    __block NSError *returnedError = nil;

    _configInternal = [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       meRequestContext:self.mockMeRequestContext
                                                      preRequestContext:self.mockPreRequestContext
                                                           mobileEngage:strictMockMobileEngage
                                                           pushInternal:strictMockPushInternal
                                                             deviceInfo:self.mockDeviceInfo
                                                  emarsysRequestFactory:self.mockEmarsysRequestFactory
                                             remoteConfigResponseMapper:self.mockResponseMapper
                                                               endpoint:self.mockEndpoint];

    OCMStub([strictMockPushInternal deviceToken]).andReturn(self.deviceToken);
    OCMStub([self.mockMeRequestContext applicationCode]).andReturn(self.applicationCode);
    OCMStub([strictMockMobileEngage clearContactWithCompletionBlock:([OCMArg invokeBlockWithArgs:inputError, nil])]);
    OCMStub([strictMockPushInternal setPushToken:self.deviceToken
                                 completionBlock:[OCMArg invokeBlock]]);
    OCMStub([strictMockMobileEngage setContactWithContactFieldValue:self.contactFieldValue
                                                    completionBlock:[OCMArg invokeBlock]]);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionHandler"];
    [self.configInternal changeApplicationCode:@"newApplicationCode"
                               completionBlock:^(NSError *error) {
                                   returnedError = error;
                                   [expectation fulfill];
                               }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:5];

    OCMExpect([strictMockMobileEngage clearContactWithCompletionBlock:[OCMArg any]]);

    OCMReject([strictMockPushInternal setPushToken:self.deviceToken
                                   completionBlock:[OCMArg any]]);
    OCMReject([strictMockMobileEngage setContactWithContactFieldValue:self.contactFieldValue
                                                      completionBlock:[OCMArg any]]);

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqual(returnedError, inputError);
}

- (void)testChangeApplicationCode_setPushToken_shouldCallCompletionBlockWithError {
    id strictMockMobileEngage = OCMStrictClassMock([EMSMobileEngageV3Internal class]);
    id strictMockPushInternal = OCMStrictClassMock([EMSPushV3Internal class]);

    NSError *inputError = [NSError errorWithCode:1400
                            localizedDescription:@"testError"];
    __block NSError *returnedError = nil;

    _configInternal = [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       meRequestContext:self.mockMeRequestContext
                                                      preRequestContext:self.mockPreRequestContext
                                                           mobileEngage:strictMockMobileEngage
                                                           pushInternal:strictMockPushInternal
                                                             deviceInfo:self.mockDeviceInfo
                                                  emarsysRequestFactory:self.mockEmarsysRequestFactory
                                             remoteConfigResponseMapper:self.mockResponseMapper
                                                               endpoint:self.mockEndpoint];

    OCMStub([strictMockPushInternal deviceToken]).andReturn(self.deviceToken);
    OCMStub([strictMockMobileEngage clearContactWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([strictMockPushInternal setPushToken:self.deviceToken
                                 completionBlock:([OCMArg invokeBlockWithArgs:inputError, nil])]);
    OCMStub([strictMockMobileEngage setContactWithContactFieldValue:self.contactFieldValue
                                                    completionBlock:[OCMArg invokeBlock]]);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionHandler"];
    [self.configInternal changeApplicationCode:@"newApplicationCode"
                               completionBlock:^(NSError *error) {
                                   returnedError = error;
                                   [expectation fulfill];
                               }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:5];

    OCMExpect([strictMockMobileEngage clearContactWithCompletionBlock:[OCMArg any]]);

    OCMExpect([strictMockPushInternal setPushToken:self.deviceToken
                                   completionBlock:[OCMArg any]]);
    OCMReject([strictMockMobileEngage setContactWithContactFieldValue:self.contactFieldValue
                                                      completionBlock:[OCMArg any]]);

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqual(returnedError, inputError);
}

- (void)testChangeApplicationCode_setPushToken_shouldNotBeCalled_whenPushTokenIsNil {
    id strictMockMobileEngage = OCMStrictClassMock([EMSMobileEngageV3Internal class]);
    id strictMockPushInternal = OCMStrictClassMock([EMSPushV3Internal class]);

    __block NSError *returnedError = nil;

    _configInternal = [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       meRequestContext:self.mockMeRequestContext
                                                      preRequestContext:self.mockPreRequestContext
                                                           mobileEngage:strictMockMobileEngage
                                                           pushInternal:strictMockPushInternal
                                                             deviceInfo:self.mockDeviceInfo
                                                  emarsysRequestFactory:self.mockEmarsysRequestFactory
                                             remoteConfigResponseMapper:self.mockResponseMapper
                                                               endpoint:self.mockEndpoint];

    OCMStub([strictMockPushInternal deviceToken]).andReturn(nil);
    OCMStub([strictMockMobileEngage clearContactWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([strictMockMobileEngage setContactWithContactFieldValue:self.contactFieldValue
                                                    completionBlock:[OCMArg invokeBlock]]);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionHandler"];
    [self.configInternal changeApplicationCode:@"newApplicationCode"
                               completionBlock:^(NSError *error) {
                                   returnedError = error;
                                   [expectation fulfill];
                               }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:5];

    OCMExpect([strictMockMobileEngage clearContactWithCompletionBlock:[OCMArg any]]);

    OCMReject([strictMockPushInternal setPushToken:self.deviceToken
                                   completionBlock:[OCMArg any]]);
    OCMExpect([strictMockMobileEngage setContactWithContactFieldValue:self.contactFieldValue
                                                      completionBlock:[OCMArg any]]);

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
}

- (void)testChangeApplicationCode_shouldCallSetPushTokenImmediately_whenApplicationCodeIsNil {
    id strictMockMobileEngage = OCMStrictClassMock([EMSMobileEngageV3Internal class]);
    id mockPushInternal = OCMClassMock([EMSPushV3Internal class]);

    __block NSError *returnedError = nil;

    _configInternal = [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       meRequestContext:self.mockMeRequestContext
                                                      preRequestContext:self.mockPreRequestContext
                                                           mobileEngage:strictMockMobileEngage
                                                           pushInternal:mockPushInternal
                                                             deviceInfo:self.mockDeviceInfo
                                                  emarsysRequestFactory:self.mockEmarsysRequestFactory
                                             remoteConfigResponseMapper:self.mockResponseMapper
                                                               endpoint:self.mockEndpoint];

    OCMStub([self.mockMeRequestContext applicationCode]).andReturn(nil);
    OCMStub([mockPushInternal deviceToken]).andReturn(self.deviceToken);
    OCMStub([mockPushInternal setPushToken:self.deviceToken
                           completionBlock:[OCMArg invokeBlock]]);
    OCMStub([strictMockMobileEngage clearContactWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([strictMockMobileEngage setContactWithContactFieldValue:self.contactFieldValue
                                                    completionBlock:[OCMArg invokeBlock]]);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionHandler"];
    [self.configInternal changeApplicationCode:@"newApplicationCode"
                               completionBlock:^(NSError *error) {
                                   returnedError = error;
                                   [expectation fulfill];
                               }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:5];

    OCMReject([strictMockMobileEngage clearContactWithCompletionBlock:[OCMArg any]]);

    OCMExpect([mockPushInternal setPushToken:self.deviceToken
                             completionBlock:[OCMArg any]]);
    OCMExpect([strictMockMobileEngage setContactWithContactFieldValue:self.contactFieldValue
                                                      completionBlock:[OCMArg any]]);

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
}

- (void)testChangeApplicationCode_shouldCallSetContactImmediately_whenPushTokenIsNil {
    id strictMockMobileEngage = OCMStrictClassMock([EMSMobileEngageV3Internal class]);
    id mockPushInternal = OCMClassMock([EMSPushV3Internal class]);

    __block NSError *returnedError = nil;

    _configInternal = [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       meRequestContext:self.mockMeRequestContext
                                                      preRequestContext:self.mockPreRequestContext
                                                           mobileEngage:strictMockMobileEngage
                                                           pushInternal:mockPushInternal
                                                             deviceInfo:self.mockDeviceInfo
                                                  emarsysRequestFactory:self.mockEmarsysRequestFactory
                                             remoteConfigResponseMapper:self.mockResponseMapper
                                                               endpoint:self.mockEndpoint];

    OCMStub([self.mockMeRequestContext applicationCode]).andReturn(nil);
    OCMStub([mockPushInternal deviceToken]).andReturn(nil);
    OCMStub([strictMockMobileEngage clearContactWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([strictMockMobileEngage setContactWithContactFieldValue:self.contactFieldValue
                                                    completionBlock:[OCMArg invokeBlock]]);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionHandler"];
    [self.configInternal changeApplicationCode:@"newApplicationCode"
                               completionBlock:^(NSError *error) {
                                   returnedError = error;
                                   [expectation fulfill];
                               }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:5];

    OCMReject([strictMockMobileEngage clearContactWithCompletionBlock:[OCMArg any]]);

    OCMReject([mockPushInternal setPushToken:self.deviceToken
                             completionBlock:[OCMArg any]]);
    OCMExpect([strictMockMobileEngage setContactWithContactFieldValue:self.contactFieldValue
                                                      completionBlock:[OCMArg any]]);

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
}

- (void)testCallCompletionBlockWithError_whenThereIsNoError {
    EMSConfigInternal *partialMockConfigInternal = OCMPartialMock(self.configInternal);
    OCMReject([partialMockConfigInternal refreshConfigFromRemoteConfig]);

    [partialMockConfigInternal callCompletionBlock:^(NSError *error) {
        }
                                         withError:nil];
}

- (void)testCallCompletionBlockWithError_whenThereIsError {
    EMSConfigInternal *partialMockConfigInternal = OCMPartialMock(self.configInternal);
    NSError *error = [NSError errorWithCode:1401
                       localizedDescription:@"testError"];

    OCMReject([partialMockConfigInternal refreshConfigFromRemoteConfig]);

    [partialMockConfigInternal callCompletionBlock:^(NSError *error) {
        }
                                         withError:error];
}

- (void)testChangeMerchantId_shouldRefresh {
    EMSConfigInternal *partialMockConfigInternal = OCMPartialMock(self.configInternal);

    OCMReject([partialMockConfigInternal refreshConfigFromRemoteConfig]);

    [partialMockConfigInternal changeMerchantId:@"testMerchantId"];
}

- (void)testChangeMerchantId_shouldSetMerchantId_inPRERequestContext {
    NSString *newMerchantId = @"newMerchantId";

    [self.configInternal changeMerchantId:newMerchantId];

    OCMExpect([self.mockPreRequestContext setMerchantId:newMerchantId]);
}

- (void)testHardwareId {
    OCMStub([self.mockDeviceInfo hardwareId]).andReturn(@"testHardwareId");

    NSString *result = [self.configInternal hardwareId];

    XCTAssertEqualObjects(result, @"testHardwareId");
}

- (void)testLanguageCode {
    OCMStub([self.mockDeviceInfo languageCode]).andReturn(@"testLanguageCode");

    NSString *result = [self.configInternal languageCode];

    XCTAssertEqualObjects(result, @"testLanguageCode");
}

- (void)testPushSettings {
    NSDictionary *pushSettings = @{@"test": @"pushSettings"};

    OCMStub([self.mockDeviceInfo pushSettings]).andReturn(pushSettings);

    NSDictionary *result = [self.configInternal pushSettings];

    XCTAssertEqualObjects(result, pushSettings);
}

- (void)testRefreshConfig {
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);

    OCMStub([self.mockEmarsysRequestFactory createRemoteConfigRequestModel]).andReturn(mockRequestModel);

    [self.configInternal refreshConfigFromRemoteConfig];

    OCMVerify([self.mockRequestManager submitRequestModelNow:mockRequestModel
                                                successBlock:[OCMArg any]
                                                  errorBlock:[OCMArg any]]);
}

- (void)testRefreshConfig_errorBlock {
    NSError *error = [NSError errorWithCode:1401
                       localizedDescription:@"testError"];
    FakeRequestManager *fakeRequestManager = [self setupFakeRequestManagerForFetchRemoteConfig];

    fakeRequestManager.errorBlock(@"testRequestId", error);

    OCMVerify([self.mockEndpoint reset]);
}

- (void)testRefreshConfig_successBlock {
    EMSResponseModel *mockResponse = OCMClassMock([EMSResponseModel class]);
    OCMStub([mockResponse statusCode]).andReturn(@200);

    FakeRequestManager *fakeRequestManager = [self setupFakeRequestManagerForFetchRemoteConfig];

    fakeRequestManager.successBlock(@"testRequestId", mockResponse);

    OCMVerify([self.mockResponseMapper map:mockResponse]);
}

- (void)testRefreshConfig_successBlock_callsEndpointUpdate_withNewConfig {
    EMSRemoteConfig *config = OCMClassMock([EMSRemoteConfig class]);
    EMSResponseModel *mockResponse = OCMClassMock([EMSResponseModel class]);
    OCMStub([mockResponse statusCode]).andReturn(@200);
    OCMStub([self.mockResponseMapper map:mockResponse]).andReturn(config);

    FakeRequestManager *fakeRequestManager = [self setupFakeRequestManagerForFetchRemoteConfig];

    fakeRequestManager.successBlock(@"testRequestId", mockResponse);

    OCMVerify([self.mockEndpoint updateUrlsWithRemoteConfig:config]);
}

- (FakeRequestManager *)setupFakeRequestManagerForFetchRemoteConfig {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];
    FakeRequestManager *fakeRequestManager = [[FakeRequestManager alloc] initWithSubmitNowCompletionBlock:^{
        [expectation fulfill];
    }];
    EMSConfigInternal *configInternal = [[EMSConfigInternal alloc] initWithRequestManager:fakeRequestManager
                                                                         meRequestContext:self.mockMeRequestContext
                                                                        preRequestContext:self.mockPreRequestContext
                                                                             mobileEngage:self.mockMobileEngage
                                                                             pushInternal:self.mockPushInternal
                                                                               deviceInfo:self.mockDeviceInfo
                                                                    emarsysRequestFactory:self.mockEmarsysRequestFactory
                                                               remoteConfigResponseMapper:self.mockResponseMapper
                                                                                 endpoint:self.mockEndpoint];
    [configInternal refreshConfigFromRemoteConfig];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:5];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    return fakeRequestManager;
}

@end
