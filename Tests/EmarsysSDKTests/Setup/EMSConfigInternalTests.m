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
#import "EMSUUIDProvider.h"
#import "EMSLogger.h"
#import "EMSCrypto.h"

@interface EMSConfigInternal (Tests)

- (void)callCompletionBlock:(EMSCompletionBlock)completionBlock
                  withError:(NSError *)error;

- (void)fetchRemoteConfigWithSignatureData:(NSData *)signatureData;

@end

@interface EMSConfigInternalTests : XCTestCase

@property(nonatomic, strong) EMSConfigInternal *configInternal;
@property(nonatomic, strong) NSString *applicationCode;
@property(nonatomic, strong) NSString *merchantId;
@property(nonatomic, strong) NSNumber *contactFieldId;
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
@property(nonatomic, strong) EMSLogger *mockLogger;
@property(nonatomic, strong) EMSCrypto *mockCrypto;

@end

@implementation EMSConfigInternalTests

- (void)setUp {
    _applicationCode = @"testApplicationCode";
    _merchantId = @"testMerchantId";
    _contactFieldId = @3;
    _contactFieldValue = @"testContactFieldValue";
    _deviceToken = [@"token" dataUsingEncoding:NSUTF8StringEncoding];

    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockMeRequestContext = OCMClassMock([MERequestContext class]);
    _mockPreRequestContext = OCMClassMock([PRERequestContext class]);
    _mockMobileEngage = OCMClassMock([EMSMobileEngageV3Internal class]);
    _mockPushInternal = OCMClassMock([EMSPushV3Internal class]);
    _mockDeviceInfo = OCMClassMock([EMSDeviceInfo class]);
    _mockEmarsysRequestFactory = OCMClassMock([EMSEmarsysRequestFactory class]);
    _mockResponseMapper = OCMClassMock([EMSRemoteConfigResponseMapper class]);
    _mockEndpoint = OCMClassMock([EMSEndpoint class]);
    _mockLogger = OCMClassMock([EMSLogger class]);
    _mockCrypto = OCMClassMock([EMSCrypto class]);

    OCMStub([self.mockMeRequestContext contactFieldValue]).andReturn(self.contactFieldValue);
    OCMStub([self.mockPushInternal deviceToken]).andReturn(self.deviceToken);

    _configInternal = [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       meRequestContext:self.mockMeRequestContext
                                                      preRequestContext:self.mockPreRequestContext
                                                           mobileEngage:self.mockMobileEngage
                                                           pushInternal:self.mockPushInternal
                                                             deviceInfo:self.mockDeviceInfo
                                                  emarsysRequestFactory:self.mockEmarsysRequestFactory
                                             remoteConfigResponseMapper:self.mockResponseMapper
                                                               endpoint:self.mockEndpoint
                                                                 logger:self.mockLogger
                                                                 crypto:self.mockCrypto];
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
                                                 endpoint:self.mockEndpoint
                                                   logger:self.mockLogger
                                                   crypto:self.mockCrypto];
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
                                                 endpoint:self.mockEndpoint
                                                   logger:self.mockLogger
                                                   crypto:self.mockCrypto];
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
                                                 endpoint:self.mockEndpoint
                                                   logger:self.mockLogger
                                                   crypto:self.mockCrypto];
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
                                                 endpoint:self.mockEndpoint
                                                   logger:self.mockLogger
                                                   crypto:self.mockCrypto];
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
                                                 endpoint:self.mockEndpoint
                                                   logger:self.mockLogger
                                                   crypto:self.mockCrypto];
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
                                                 endpoint:self.mockEndpoint
                                                   logger:self.mockLogger
                                                   crypto:self.mockCrypto];
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
                                                 endpoint:self.mockEndpoint
                                                   logger:self.mockLogger
                                                   crypto:self.mockCrypto];
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
                                                 endpoint:self.mockEndpoint
                                                   logger:self.mockLogger
                                                   crypto:self.mockCrypto];
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
                                                 endpoint:nil
                                                   logger:self.mockLogger
                                                   crypto:self.mockCrypto];
        XCTFail(@"Expected Exception when endpoint is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: endpoint");
    }
}

- (void)testInit_logger_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                         meRequestContext:self.mockMeRequestContext
                                        preRequestContext:self.mockPreRequestContext
                                             mobileEngage:self.mockMobileEngage
                                             pushInternal:self.mockPushInternal
                                               deviceInfo:self.mockDeviceInfo
                                    emarsysRequestFactory:self.mockEmarsysRequestFactory
                               remoteConfigResponseMapper:self.mockResponseMapper
                                                 endpoint:self.mockEndpoint
                                                   logger:nil
                                                   crypto:self.mockCrypto];
        XCTFail(@"Expected Exception when logger is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: logger");
    }
}

- (void)testInit_crypto_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                         meRequestContext:self.mockMeRequestContext
                                        preRequestContext:self.mockPreRequestContext
                                             mobileEngage:self.mockMobileEngage
                                             pushInternal:self.mockPushInternal
                                               deviceInfo:self.mockDeviceInfo
                                    emarsysRequestFactory:self.mockEmarsysRequestFactory
                               remoteConfigResponseMapper:self.mockResponseMapper
                                                 endpoint:self.mockEndpoint
                                                   logger:self.mockLogger
                                                   crypto:nil];
        XCTFail(@"Expected Exception when crypto is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: crypto");
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
                                                               endpoint:self.mockEndpoint
                                                                 logger:self.mockLogger
                                                                 crypto:self.mockCrypto];

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
                                                               endpoint:self.mockEndpoint
                                                                 logger:self.mockLogger
                                                                 crypto:self.mockCrypto];

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
    OCMVerify([self.mockEndpoint reset]);
    OCMVerify([self.mockLogger reset]);

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
                                                               endpoint:self.mockEndpoint
                                                                 logger:self.mockLogger
                                                                 crypto:self.mockCrypto];

    OCMStub([strictMockPushInternal deviceToken]).andReturn(self.deviceToken);
    OCMStub([self.mockMeRequestContext applicationCode]).andReturn(self.applicationCode);
    OCMStub([strictMockMobileEngage clearContactWithCompletionBlock:([OCMArg invokeBlockWithArgs:inputError,
                                                                                                 nil])]);
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
    OCMVerify([self.mockEndpoint reset]);
    OCMVerify([self.mockLogger reset]);

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
                                                               endpoint:self.mockEndpoint
                                                                 logger:self.mockLogger
                                                                 crypto:self.mockCrypto];

    OCMStub([strictMockPushInternal deviceToken]).andReturn(self.deviceToken);
    OCMStub([strictMockMobileEngage clearContactWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([strictMockPushInternal setPushToken:self.deviceToken
                                 completionBlock:([OCMArg invokeBlockWithArgs:inputError,
                                                                              nil])]);
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

- (void)testChangeApplicationCode_setPushToken_shouldNotBeCalled_afterContactFieldIdChange {
    id mockMobileEngage = OCMClassMock([EMSMobileEngageV3Internal class]);
    OCMStub([mockMobileEngage clearContactWithCompletionBlock:[OCMArg invokeBlock]]);

    id strictMockPushInternal = OCMStrictClassMock([EMSPushV3Internal class]);
    OCMStub([strictMockPushInternal deviceToken]).andReturn(nil);

    NSNumber *newContactFieldId = @123;

    MERequestContext *meContext = [[MERequestContext alloc] initWithApplicationCode:self.applicationCode
                                                                     contactFieldId:@3
                                                                       uuidProvider:OCMClassMock([EMSUUIDProvider class])
                                                                  timestampProvider:OCMClassMock([EMSTimestampProvider class])
                                                                         deviceInfo:self.mockDeviceInfo];

    id mockMEContext = OCMPartialMock(meContext);

    __block NSError *returnedError = nil;

    OCMReject([mockMobileEngage setContactWithContactFieldValue:[OCMArg any]
                                                completionBlock:^(NSError *error) {
                                                }]);

    _configInternal = [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       meRequestContext:mockMEContext
                                                      preRequestContext:self.mockPreRequestContext
                                                           mobileEngage:mockMobileEngage
                                                           pushInternal:strictMockPushInternal
                                                             deviceInfo:self.mockDeviceInfo
                                                  emarsysRequestFactory:self.mockEmarsysRequestFactory
                                             remoteConfigResponseMapper:self.mockResponseMapper
                                                               endpoint:self.mockEndpoint
                                                                 logger:self.mockLogger
                                                                 crypto:self.mockCrypto];

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionHandler"];
    [self.configInternal changeApplicationCode:nil
                                contactFieldId:newContactFieldId
                               completionBlock:^(NSError *error) {
                                   returnedError = error;
                                   [expectation fulfill];
                               }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:5];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
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
                                                               endpoint:self.mockEndpoint
                                                                 logger:self.mockLogger
                                                                 crypto:self.mockCrypto];

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
                                                               endpoint:self.mockEndpoint
                                                                 logger:self.mockLogger
                                                                 crypto:self.mockCrypto];

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
                                                               endpoint:self.mockEndpoint
                                                                 logger:self.mockLogger
                                                                 crypto:self.mockCrypto];

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

- (void)testChangeMerchantId_shouldResetRemoteConfig {
    NSString *newMerchantId = @"newMerchantId";

    [self.configInternal changeMerchantId:newMerchantId];

    OCMVerify([self.mockLogger reset]);
    OCMVerify([self.mockEndpoint reset]);
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

- (void)testRefreshConfigFromRemoteConfig_signature_error {
    NSError *error = [NSError errorWithCode:1401
                       localizedDescription:@"testError"];

    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([mockRequestModel requestId]).andReturn(@"testRequestId");

    OCMStub([self.mockEmarsysRequestFactory createRemoteConfigSignatureRequestModel]).andReturn(mockRequestModel);
    OCMStub([self.mockRequestManager submitRequestModelNow:mockRequestModel
                                              successBlock:[OCMArg any]
                                                errorBlock:([OCMArg invokeBlockWithArgs:@"testRequestId",
                                                                                        error,
                                                                                        nil])]);

    [self.configInternal refreshConfigFromRemoteConfig];

    OCMVerify([self.mockEndpoint reset]);
    OCMVerify([self.mockLogger reset]);
}

- (void)testRefreshConfigFromRemoteConfig_signature_success {
    NSData *signatureData = [NSData new];

    EMSResponseModel *mockResponse = OCMClassMock([EMSResponseModel class]);
    OCMStub([mockResponse statusCode]).andReturn(@200);
    OCMStub([mockResponse body]).andReturn(signatureData);

    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([mockRequestModel requestId]).andReturn(@"testRequestId");

    OCMStub([self.mockEmarsysRequestFactory createRemoteConfigSignatureRequestModel]).andReturn(mockRequestModel);
    OCMStub([self.mockRequestManager submitRequestModelNow:mockRequestModel
                                              successBlock:([OCMArg invokeBlockWithArgs:@"testRequestId",
                                                                                        mockResponse,
                                                                                        nil])
                                                errorBlock:[OCMArg any]]);
    EMSConfigInternal *partialMockConfigInternal = OCMPartialMock(self.configInternal);

    [partialMockConfigInternal refreshConfigFromRemoteConfig];

    OCMVerify([partialMockConfigInternal fetchRemoteConfigWithSignatureData:signatureData]);
}

- (void)testRefreshConfigFromRemoteConfig_error {
    NSData *signatureData = [NSData new];

    NSError *error = [NSError errorWithCode:1401
                       localizedDescription:@"testError"];

    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([mockRequestModel requestId]).andReturn(@"testRequestId");

    OCMStub([self.mockEmarsysRequestFactory createRemoteConfigRequestModel]).andReturn(mockRequestModel);
    OCMStub([self.mockRequestManager submitRequestModelNow:mockRequestModel
                                              successBlock:[OCMArg any]
                                                errorBlock:([OCMArg invokeBlockWithArgs:@"testRequestId",
                                                                                        error,
                                                                                        nil])]);

    [self.configInternal fetchRemoteConfigWithSignatureData:signatureData];

    OCMVerify([self.mockEndpoint reset]);
    OCMVerify([self.mockLogger reset]);
}

- (void)testRefreshConfigFromRemoteConfig_success_verified {
    EMSRemoteConfig *config = OCMClassMock([EMSRemoteConfig class]);
    NSData *signatureData = [NSData new];
    NSData *contentData = [NSData new];

    EMSResponseModel *mockResponse = OCMClassMock([EMSResponseModel class]);
    OCMStub([mockResponse statusCode]).andReturn(@200);
    OCMStub([mockResponse body]).andReturn(contentData);

    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([mockRequestModel requestId]).andReturn(@"testRequestId");

    OCMStub([self.mockEmarsysRequestFactory createRemoteConfigRequestModel]).andReturn(mockRequestModel);
    OCMStub([self.mockRequestManager submitRequestModelNow:mockRequestModel
                                              successBlock:([OCMArg invokeBlockWithArgs:@"testRequestId",
                                                                                        mockResponse,
                                                                                        nil])
                                                errorBlock:[OCMArg any]]);
    OCMStub([self.mockResponseMapper map:mockResponse]).andReturn(config);
    OCMStub([self.mockCrypto verifyContent:contentData
                             withSignature:signatureData]).andReturn(YES);

    [self.configInternal fetchRemoteConfigWithSignatureData:signatureData];

    OCMVerify([self.mockCrypto verifyContent:contentData
                               withSignature:signatureData]);
    OCMVerify([self.mockEndpoint updateUrlsWithRemoteConfig:config]);
    OCMVerify([self.mockLogger updateWithRemoteConfig:config]);
}

- (void)testRefreshConfigFromRemoteConfig_success_notVerified {
    NSData *signatureData = [NSData new];
    NSData *contentData = [NSData new];

    EMSResponseModel *mockResponse = OCMClassMock([EMSResponseModel class]);
    OCMStub([mockResponse statusCode]).andReturn(@200);
    OCMStub([mockResponse body]).andReturn(contentData);

    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([mockRequestModel requestId]).andReturn(@"testRequestId");

    OCMStub([self.mockEmarsysRequestFactory createRemoteConfigRequestModel]).andReturn(mockRequestModel);
    OCMStub([self.mockRequestManager submitRequestModelNow:mockRequestModel
                                              successBlock:([OCMArg invokeBlockWithArgs:@"testRequestId",
                                                                                        mockResponse,
                                                                                        nil])
                                                errorBlock:[OCMArg any]]);
    OCMStub([self.mockCrypto verifyContent:contentData
                             withSignature:signatureData]).andReturn(NO);

    [self.configInternal fetchRemoteConfigWithSignatureData:signatureData];

    OCMVerify([self.mockCrypto verifyContent:contentData
                               withSignature:signatureData]);
    OCMVerify([self.mockEndpoint reset]);
    OCMVerify([self.mockLogger reset]);
}

@end
