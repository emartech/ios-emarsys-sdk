//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSConfigInternal.h"
#import "MERequestContext.h"
#import "PRERequestContext.h"
#import "EMSContactClientInternal.h"
#import "NSError+EMSCore.h"
#import "EMSPushV3Internal.h"
#import "EMSDeviceInfo.h"
#import "EMSRequestManager.h"
#import "EMSEmarsysRequestFactory.h"
#import "EMSRemoteConfigResponseMapper.h"
#import "EMSEndpoint.h"
#import "EMSRemoteConfig.h"
#import "EMSCrypto.h"
#import "EMSDispatchWaiter.h"
#import "EMSDeviceInfoV3ClientInternal.h"
#import "MEExperimental.h"
#import "EMSInnerFeature.h"
#import "EmarsysTestUtils.h"
#import "EmarsysSDKVersion.h"
#import "XCTestCase+Helper.h"

@interface EMSConfigInternal (Tests)

- (void)fetchRemoteConfigWithSignatureData:(NSData *)signatureData
                           completionBlock:(_Nullable EMSCompletionBlock)completionBlock;

- (NSError *)sendDeviceInfo;

- (NSError *)sendPushToken:(NSData *)pushToken;

- (NSError *)clearPushToken;

@end

@interface EMSConfigInternalTests : XCTestCase

@property(nonatomic, strong) EMSConfigInternal *configInternal;
@property(nonatomic, strong) NSString *applicationCode;
@property(nonatomic, strong) NSString *merchantId;
@property(nonatomic, strong) NSNumber *contactFieldId;
@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) MERequestContext *mockMeRequestContext;
@property(nonatomic, strong) PRERequestContext *mockPreRequestContext;
@property(nonatomic, strong) EMSContactClientInternal *mockContactClient;
@property(nonatomic, strong) EMSDeviceInfo *mockDeviceInfo;
@property(nonatomic, strong) EMSPushV3Internal *mockPushInternal;
@property(nonatomic, strong) EMSEmarsysRequestFactory *mockEmarsysRequestFactory;
@property(nonatomic, strong) NSString *contactFieldValue;
@property(nonatomic, strong) NSData *deviceToken;
@property(nonatomic, strong) EMSRemoteConfigResponseMapper *mockResponseMapper;
@property(nonatomic, strong) EMSEndpoint *mockEndpoint;
@property(nonatomic, strong) EMSLogger *mockLogger;
@property(nonatomic, strong) EMSCrypto *mockCrypto;
@property(nonatomic, strong) EMSDispatchWaiter *waiter;
@property(nonatomic, strong) NSOperationQueue *queue;
@property(nonatomic, strong) EMSDeviceInfoV3ClientInternal *mockDeviceInfoClient;

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
    _mockContactClient = OCMClassMock([EMSContactClientInternal class]);
    _mockPushInternal = OCMClassMock([EMSPushV3Internal class]);
    _mockDeviceInfo = OCMClassMock([EMSDeviceInfo class]);
    _mockEmarsysRequestFactory = OCMClassMock([EMSEmarsysRequestFactory class]);
    _mockResponseMapper = OCMClassMock([EMSRemoteConfigResponseMapper class]);
    _mockEndpoint = OCMClassMock([EMSEndpoint class]);
    _mockLogger = OCMClassMock([EMSLogger class]);
    _mockCrypto = OCMClassMock([EMSCrypto class]);
    _mockDeviceInfoClient = OCMClassMock([EMSDeviceInfoV3ClientInternal class]);
    _waiter = [EMSDispatchWaiter new];
    _queue = [self createTestOperationQueue];

    OCMStub([self.mockMeRequestContext contactFieldValue]).andReturn(self.contactFieldValue);
    OCMStub([self.mockPushInternal deviceToken]).andReturn(self.deviceToken);
    OCMStub([self.mockDeviceInfoClient sendDeviceInfoWithCompletionBlock:[OCMArg invokeBlock]]);

    _configInternal = [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       meRequestContext:self.mockMeRequestContext
                                                      preRequestContext:self.mockPreRequestContext
                                                          contactClient:self.mockContactClient
                                                           pushInternal:self.mockPushInternal
                                                             deviceInfo:self.mockDeviceInfo
                                                  emarsysRequestFactory:self.mockEmarsysRequestFactory
                                             remoteConfigResponseMapper:self.mockResponseMapper
                                                               endpoint:self.mockEndpoint
                                                                 logger:self.mockLogger
                                                                 crypto:self.mockCrypto
                                                                  queue:self.queue
                                                                 waiter:self.waiter
                                                       deviceInfoClient:self.mockDeviceInfoClient];
}

- (void)tearDown {
    [self tearDownOperationQueue:self.queue];
    [EmarsysTestUtils tearDownEmarsys];
}

- (void)testInit_requestManager_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithRequestManager:nil
                                         meRequestContext:self.mockMeRequestContext
                                        preRequestContext:self.mockPreRequestContext
                                            contactClient:self.mockContactClient
                                             pushInternal:self.mockPushInternal
                                               deviceInfo:self.mockDeviceInfo
                                    emarsysRequestFactory:self.mockEmarsysRequestFactory
                               remoteConfigResponseMapper:self.mockResponseMapper
                                                 endpoint:self.mockEndpoint
                                                   logger:self.mockLogger
                                                   crypto:self.mockCrypto
                                                    queue:self.queue
                                                   waiter:self.waiter
                                         deviceInfoClient:self.mockDeviceInfoClient];
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
                                            contactClient:self.mockContactClient
                                             pushInternal:self.mockPushInternal
                                               deviceInfo:self.mockDeviceInfo
                                    emarsysRequestFactory:self.mockEmarsysRequestFactory
                               remoteConfigResponseMapper:self.mockResponseMapper
                                                 endpoint:self.mockEndpoint
                                                   logger:self.mockLogger
                                                   crypto:self.mockCrypto
                                                    queue:self.queue
                                                   waiter:self.waiter
                                         deviceInfoClient:self.mockDeviceInfoClient];
        XCTFail(@"Expected Exception when meRequestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: meRequestContext");
    }
}

- (void)testInit_contactClient_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                         meRequestContext:self.mockMeRequestContext
                                        preRequestContext:self.mockPreRequestContext
                                            contactClient:nil
                                             pushInternal:self.mockPushInternal
                                               deviceInfo:self.mockDeviceInfo
                                    emarsysRequestFactory:self.mockEmarsysRequestFactory
                               remoteConfigResponseMapper:self.mockResponseMapper
                                                 endpoint:self.mockEndpoint
                                                   logger:self.mockLogger
                                                   crypto:self.mockCrypto
                                                    queue:self.queue
                                                   waiter:self.waiter
                                         deviceInfoClient:self.mockDeviceInfoClient];
        XCTFail(@"Expected Exception when contactClient is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: contactClient");
    }
}

- (void)testInit_pushInternal_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                         meRequestContext:self.mockMeRequestContext
                                        preRequestContext:self.mockPreRequestContext
                                            contactClient:self.mockContactClient
                                             pushInternal:nil
                                               deviceInfo:self.mockDeviceInfo
                                    emarsysRequestFactory:self.mockEmarsysRequestFactory
                               remoteConfigResponseMapper:self.mockResponseMapper
                                                 endpoint:self.mockEndpoint
                                                   logger:self.mockLogger
                                                   crypto:self.mockCrypto
                                                    queue:self.queue
                                                   waiter:self.waiter
                                         deviceInfoClient:self.mockDeviceInfoClient];
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
                                            contactClient:self.mockContactClient
                                             pushInternal:self.mockPushInternal
                                               deviceInfo:self.mockDeviceInfo
                                    emarsysRequestFactory:self.mockEmarsysRequestFactory
                               remoteConfigResponseMapper:self.mockResponseMapper
                                                 endpoint:self.mockEndpoint
                                                   logger:self.mockLogger
                                                   crypto:self.mockCrypto
                                                    queue:self.queue
                                                   waiter:self.waiter
                                         deviceInfoClient:self.mockDeviceInfoClient];
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
                                            contactClient:self.mockContactClient
                                             pushInternal:self.mockPushInternal
                                               deviceInfo:nil
                                    emarsysRequestFactory:self.mockEmarsysRequestFactory
                               remoteConfigResponseMapper:self.mockResponseMapper
                                                 endpoint:self.mockEndpoint
                                                   logger:self.mockLogger
                                                   crypto:self.mockCrypto
                                                    queue:self.queue
                                                   waiter:self.waiter
                                         deviceInfoClient:self.mockDeviceInfoClient];
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
                                            contactClient:self.mockContactClient
                                             pushInternal:self.mockPushInternal
                                               deviceInfo:self.mockDeviceInfo
                                    emarsysRequestFactory:nil
                               remoteConfigResponseMapper:self.mockResponseMapper
                                                 endpoint:self.mockEndpoint
                                                   logger:self.mockLogger
                                                   crypto:self.mockCrypto
                                                    queue:self.queue
                                                   waiter:self.waiter
                                         deviceInfoClient:self.mockDeviceInfoClient];
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
                                            contactClient:self.mockContactClient
                                             pushInternal:self.mockPushInternal
                                               deviceInfo:self.mockDeviceInfo
                                    emarsysRequestFactory:self.mockEmarsysRequestFactory
                               remoteConfigResponseMapper:nil
                                                 endpoint:self.mockEndpoint
                                                   logger:self.mockLogger
                                                   crypto:self.mockCrypto
                                                    queue:self.queue
                                                   waiter:self.waiter
                                         deviceInfoClient:self.mockDeviceInfoClient];
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
                                            contactClient:self.mockContactClient
                                             pushInternal:self.mockPushInternal
                                               deviceInfo:self.mockDeviceInfo
                                    emarsysRequestFactory:self.mockEmarsysRequestFactory
                               remoteConfigResponseMapper:self.mockResponseMapper
                                                 endpoint:nil
                                                   logger:self.mockLogger
                                                   crypto:self.mockCrypto
                                                    queue:self.queue
                                                   waiter:self.waiter
                                         deviceInfoClient:self.mockDeviceInfoClient];
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
                                            contactClient:self.mockContactClient
                                             pushInternal:self.mockPushInternal
                                               deviceInfo:self.mockDeviceInfo
                                    emarsysRequestFactory:self.mockEmarsysRequestFactory
                               remoteConfigResponseMapper:self.mockResponseMapper
                                                 endpoint:self.mockEndpoint
                                                   logger:nil
                                                   crypto:self.mockCrypto
                                                    queue:self.queue
                                                   waiter:self.waiter
                                         deviceInfoClient:self.mockDeviceInfoClient];
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
                                            contactClient:self.mockContactClient
                                             pushInternal:self.mockPushInternal
                                               deviceInfo:self.mockDeviceInfo
                                    emarsysRequestFactory:self.mockEmarsysRequestFactory
                               remoteConfigResponseMapper:self.mockResponseMapper
                                                 endpoint:self.mockEndpoint
                                                   logger:self.mockLogger
                                                   crypto:nil
                                                    queue:self.queue
                                                   waiter:self.waiter
                                         deviceInfoClient:self.mockDeviceInfoClient];
        XCTFail(@"Expected Exception when crypto is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: crypto");
    }
}

- (void)testInit_queue_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                         meRequestContext:self.mockMeRequestContext
                                        preRequestContext:self.mockPreRequestContext
                                            contactClient:self.mockContactClient
                                             pushInternal:self.mockPushInternal
                                               deviceInfo:self.mockDeviceInfo
                                    emarsysRequestFactory:self.mockEmarsysRequestFactory
                               remoteConfigResponseMapper:self.mockResponseMapper
                                                 endpoint:self.mockEndpoint
                                                   logger:self.mockLogger
                                                   crypto:self.mockCrypto
                                                    queue:nil
                                                   waiter:self.waiter
                                         deviceInfoClient:self.mockDeviceInfoClient];
        XCTFail(@"Expected Exception when queue is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: queue");
    }
}

- (void)testInit_waiter_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                         meRequestContext:self.mockMeRequestContext
                                        preRequestContext:self.mockPreRequestContext
                                            contactClient:self.mockContactClient
                                             pushInternal:self.mockPushInternal
                                               deviceInfo:self.mockDeviceInfo
                                    emarsysRequestFactory:self.mockEmarsysRequestFactory
                               remoteConfigResponseMapper:self.mockResponseMapper
                                                 endpoint:self.mockEndpoint
                                                   logger:self.mockLogger
                                                   crypto:self.mockCrypto
                                                    queue:self.queue
                                                   waiter:nil
                                         deviceInfoClient:self.mockDeviceInfoClient];
        XCTFail(@"Expected Exception when waiter is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: waiter");
    }
}


- (void)testInit_deviceInfoClient_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                         meRequestContext:self.mockMeRequestContext
                                        preRequestContext:self.mockPreRequestContext
                                            contactClient:self.mockContactClient
                                             pushInternal:self.mockPushInternal
                                               deviceInfo:self.mockDeviceInfo
                                    emarsysRequestFactory:self.mockEmarsysRequestFactory
                               remoteConfigResponseMapper:self.mockResponseMapper
                                                 endpoint:self.mockEndpoint
                                                   logger:self.mockLogger
                                                   crypto:self.mockCrypto
                                                    queue:self.queue
                                                   waiter:self.waiter
                                         deviceInfoClient:nil];
        XCTFail(@"Expected Exception when deviceInfoClient is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: deviceInfoClient");
    }
}

- (void)testChangeApplicationCode_completionHandler_isNil {
    id strictMockContactClient = OCMStrictClassMock([EMSContactClientInternal class]);
    id strictMockPushInternal = OCMStrictClassMock([EMSPushV3Internal class]);

    OCMStub([self.mockMeRequestContext applicationCode]).andReturn(@"oldAppCode");
    OCMStub([self.mockMeRequestContext hasContactIdentification]).andReturn((YES));

    _configInternal = [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       meRequestContext:self.mockMeRequestContext
                                                      preRequestContext:self.mockPreRequestContext
                                                          contactClient:strictMockContactClient
                                                           pushInternal:strictMockPushInternal
                                                             deviceInfo:self.mockDeviceInfo
                                                  emarsysRequestFactory:self.mockEmarsysRequestFactory
                                             remoteConfigResponseMapper:self.mockResponseMapper
                                                               endpoint:self.mockEndpoint
                                                                 logger:self.mockLogger
                                                                 crypto:self.mockCrypto
                                                                  queue:self.queue
                                                                 waiter:self.waiter
                                                       deviceInfoClient:self.mockDeviceInfoClient];

    OCMStub([strictMockPushInternal deviceToken]).andReturn(self.deviceToken);
    OCMStub([strictMockContactClient clearContactWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([strictMockPushInternal clearPushTokenWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([strictMockPushInternal setPushToken:self.deviceToken
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
                                                          timeout:10];

    OCMVerify([strictMockContactClient clearContactWithCompletionBlock:[OCMArg any]]);
    OCMVerify([strictMockPushInternal clearPushTokenWithCompletionBlock:[OCMArg any]]);
    OCMVerify([strictMockPushInternal setPushToken:self.deviceToken
                                   completionBlock:[OCMArg any]]);

    OCMVerify([strictMockContactClient clearContactWithCompletionBlock:[OCMArg any]]);
    OCMVerify([strictMockPushInternal setPushToken:self.deviceToken
                                   completionBlock:[OCMArg any]]);

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
}

- (void)testChangeApplicationCode {
    id strictMockContactClient = OCMStrictClassMock([EMSContactClientInternal class]);
    id strictMockPushInternal = OCMStrictClassMock([EMSPushV3Internal class]);
    id strictMockMeRequestContext = OCMStrictClassMock([MERequestContext class]);
    id strictMockDeviceInfoClient = OCMStrictClassMock([EMSDeviceInfoV3ClientInternal class]);

    _configInternal = [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       meRequestContext:strictMockMeRequestContext
                                                      preRequestContext:self.mockPreRequestContext
                                                          contactClient:strictMockContactClient
                                                           pushInternal:strictMockPushInternal
                                                             deviceInfo:self.mockDeviceInfo
                                                  emarsysRequestFactory:self.mockEmarsysRequestFactory
                                             remoteConfigResponseMapper:self.mockResponseMapper
                                                               endpoint:self.mockEndpoint
                                                                 logger:self.mockLogger
                                                                 crypto:self.mockCrypto
                                                                  queue:self.queue
                                                                 waiter:self.waiter
                                                       deviceInfoClient:strictMockDeviceInfoClient];
    EMSConfigInternal *partialMockConfigInternal = OCMPartialMock(self.configInternal);

    OCMStub([strictMockPushInternal deviceToken]).andReturn(self.deviceToken);
    OCMStub([strictMockPushInternal clearDeviceTokenStorage]);
    OCMStub([strictMockPushInternal setPushToken:self.deviceToken
                                 completionBlock:[OCMArg invokeBlock]]);
    OCMStub([strictMockPushInternal clearPushTokenWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([strictMockContactClient clearContactWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([strictMockDeviceInfoClient sendDeviceInfoWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([strictMockMeRequestContext applicationCode]).andReturn(@"theOldAppCode");
    OCMStub([strictMockMeRequestContext contactFieldId]).andReturn(@3);
    OCMStub([strictMockMeRequestContext hasContactIdentification]).andReturn(NO);
    OCMStub([strictMockMeRequestContext setApplicationCode:[OCMArg any]]);
    OCMStub([(MERequestContext *) strictMockMeRequestContext setContactFieldId:self.contactFieldId]);

    __block NSError *returnedError = [NSError errorWithCode:1400
                                       localizedDescription:@"testError"];

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionHandler"];
    [partialMockConfigInternal changeApplicationCode:@"newApplicationCode"
                                     completionBlock:^(NSError *error) {
                                         returnedError = error;
                                         [expectation fulfill];
                                     }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];

    OCMVerify([strictMockPushInternal clearPushTokenWithCompletionBlock:[OCMArg any]]);
    OCMVerify([strictMockMeRequestContext setApplicationCode:@"newApplicationCode"]);
    OCMVerify([strictMockDeviceInfoClient sendDeviceInfoWithCompletionBlock:[OCMArg any]]);
    OCMVerify([strictMockPushInternal setPushToken:self.deviceToken
                                   completionBlock:[OCMArg any]]);
    OCMVerify([strictMockContactClient clearContactWithCompletionBlock:[OCMArg any]]);

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
}

- (void)testChangeApplicationCode_clearContact_shouldCallCompletionBlockWithError_onMainQueue {
    id strictMockContactClient = OCMStrictClassMock([EMSContactClientInternal class]);
    id strictMockPushInternal = OCMStrictClassMock([EMSPushV3Internal class]);
    __block NSOperationQueue *returnedQueue = nil;

    OCMStub([self.mockMeRequestContext applicationCode]).andReturn(@"oldAppCode");
    OCMStub([self.mockMeRequestContext hasContactIdentification]).andReturn((YES));

    NSError *inputError = [NSError errorWithCode:1400
                            localizedDescription:@"testError"];
    __block NSError *returnedError = nil;

    _configInternal = [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       meRequestContext:self.mockMeRequestContext
                                                      preRequestContext:self.mockPreRequestContext
                                                          contactClient:strictMockContactClient
                                                           pushInternal:strictMockPushInternal
                                                             deviceInfo:self.mockDeviceInfo
                                                  emarsysRequestFactory:self.mockEmarsysRequestFactory
                                             remoteConfigResponseMapper:self.mockResponseMapper
                                                               endpoint:self.mockEndpoint
                                                                 logger:self.mockLogger
                                                                 crypto:self.mockCrypto
                                                                  queue:self.queue
                                                                 waiter:self.waiter
                                                       deviceInfoClient:self.mockDeviceInfoClient];

    OCMStub([strictMockPushInternal deviceToken]).andReturn(self.deviceToken);
    OCMStub([strictMockPushInternal clearPushTokenWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([self.mockMeRequestContext applicationCode]).andReturn(self.applicationCode);
    OCMStub([self.mockMeRequestContext hasContactIdentification]).andReturn(YES);
    OCMStub([strictMockContactClient clearContactWithCompletionBlock:([OCMArg invokeBlockWithArgs:inputError,
                                                                                                 nil])]);
    OCMStub([strictMockContactClient setContactWithContactFieldId:self.contactFieldId
                                               contactFieldValue:self.contactFieldValue
                                                 completionBlock:[OCMArg invokeBlock]]);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionHandler"];
    [self.configInternal changeApplicationCode:@"newApplicationCode"
                               completionBlock:^(NSError *error) {
                                   returnedError = error;
                                   returnedQueue = [NSOperationQueue currentQueue];
                                   [expectation fulfill];
                               }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];

    OCMVerify([strictMockPushInternal clearPushTokenWithCompletionBlock:[OCMArg any]]);
    OCMReject([strictMockContactClient clearContactWithCompletionBlock:[OCMArg any]]);
    OCMReject([strictMockContactClient setContactWithContactFieldId:self.contactFieldId
                                                 contactFieldValue:self.contactFieldValue
                                                   completionBlock:[OCMArg any]]);

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqual(returnedError, inputError);
    XCTAssertEqualObjects(returnedQueue, NSOperationQueue.mainQueue);
}

- (void)testChangeApplicationCode_shouldNotCallClearContact_whenSendDeviceInfoReturnsError {
    NSError *error = [NSError errorWithCode:-1000 localizedDescription:@"testError"];

    OCMStub([self.mockMeRequestContext applicationCode]).andReturn(@"oldAppCode");

    OCMReject([self.mockContactClient clearContactWithCompletionBlock:[OCMArg any]]);

    _configInternal = [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       meRequestContext:self.mockMeRequestContext
                                                      preRequestContext:self.mockPreRequestContext
                                                        contactClient:self.mockContactClient
                                                           pushInternal:OCMClassMock([EMSPushV3Internal class])
                                                             deviceInfo:self.mockDeviceInfo
                                                  emarsysRequestFactory:self.mockEmarsysRequestFactory
                                             remoteConfigResponseMapper:self.mockResponseMapper
                                                               endpoint:self.mockEndpoint
                                                                 logger:self.mockLogger
                                                                 crypto:self.mockCrypto
                                                                  queue:self.queue
                                                                 waiter:self.waiter
                                                       deviceInfoClient:self.mockDeviceInfoClient];

    EMSConfigInternal *partialMockConfigInternal = OCMPartialMock(self.configInternal);
    OCMStub([partialMockConfigInternal sendDeviceInfo]).andReturn(error);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionHandler"];
    [partialMockConfigInternal changeApplicationCode:@"newApplicationCode"
                                     completionBlock:^(NSError *error) {
                                         [expectation fulfill];
                                     }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:20];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
}

- (void)testChangeApplicationCode_shouldNotCallClearContact_whenSendPushTokenReturnsError {
    NSError *error = [NSError errorWithCode:-1000 localizedDescription:@"testError"];

    OCMStub([self.mockMeRequestContext applicationCode]).andReturn(@"oldAppCode");

    OCMReject([self.mockContactClient clearContactWithCompletionBlock:[OCMArg any]]);

    _configInternal = [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       meRequestContext:self.mockMeRequestContext
                                                      preRequestContext:self.mockPreRequestContext
                                                          contactClient:self.mockContactClient
                                                           pushInternal:self.mockPushInternal
                                                             deviceInfo:self.mockDeviceInfo
                                                  emarsysRequestFactory:self.mockEmarsysRequestFactory
                                             remoteConfigResponseMapper:self.mockResponseMapper
                                                               endpoint:self.mockEndpoint
                                                                 logger:self.mockLogger
                                                                 crypto:self.mockCrypto
                                                                  queue:self.queue
                                                                 waiter:self.waiter
                                                       deviceInfoClient:self.mockDeviceInfoClient];

    EMSConfigInternal *partialMockConfigInternal = OCMPartialMock(self.configInternal);
    OCMStub([partialMockConfigInternal sendPushToken:self.deviceToken]).andReturn(error);
    OCMStub([partialMockConfigInternal clearPushToken]).andReturn(nil);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionHandler"];
    [partialMockConfigInternal changeApplicationCode:@"newApplicationCode"
                                     completionBlock:^(NSError *error) {
                                         [expectation fulfill];
                                     }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:20];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
}

- (void)testChangeApplicationCode_setPushToken_shouldCallCompletionBlockWithError {
    id strictMockContactClient = OCMStrictClassMock([EMSContactClientInternal class]);
    id strictMockPushInternal = OCMStrictClassMock([EMSPushV3Internal class]);

    OCMStub([self.mockMeRequestContext applicationCode]).andReturn(@"oldAppCode");
    OCMStub([self.mockMeRequestContext hasContactIdentification]).andReturn((YES));

    NSError *inputError = [NSError errorWithCode:1400
                            localizedDescription:@"testError"];
    __block NSError *returnedError = nil;

    _configInternal = [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       meRequestContext:self.mockMeRequestContext
                                                      preRequestContext:self.mockPreRequestContext
                                                          contactClient:strictMockContactClient
                                                           pushInternal:strictMockPushInternal
                                                             deviceInfo:self.mockDeviceInfo
                                                  emarsysRequestFactory:self.mockEmarsysRequestFactory
                                             remoteConfigResponseMapper:self.mockResponseMapper
                                                               endpoint:self.mockEndpoint
                                                                 logger:self.mockLogger
                                                                 crypto:self.mockCrypto
                                                                  queue:self.queue
                                                                 waiter:self.waiter
                                                       deviceInfoClient:self.mockDeviceInfoClient];

    OCMStub([self.mockMeRequestContext applicationCode]).andReturn(self.applicationCode);
    OCMStub([strictMockPushInternal deviceToken]).andReturn(self.deviceToken);
    OCMStub([strictMockContactClient clearContactWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([strictMockPushInternal clearPushTokenWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([strictMockPushInternal setPushToken:self.deviceToken
                                 completionBlock:([OCMArg invokeBlockWithArgs:inputError,
                                                                              nil])]);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionHandler"];
    [self.configInternal changeApplicationCode:@"newApplicationCode"
                               completionBlock:^(NSError *error) {
                                   returnedError = error;
                                   [expectation fulfill];
                               }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];

    OCMVerify([strictMockContactClient clearContactWithCompletionBlock:[OCMArg any]]);

    OCMVerify([strictMockPushInternal setPushToken:self.deviceToken
                                   completionBlock:[OCMArg any]]);
    OCMReject([strictMockContactClient setContactWithContactFieldId:self.contactFieldId
                                                 contactFieldValue:self.contactFieldValue
                                                   completionBlock:[OCMArg any]]);

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqual(returnedError, inputError);
}

- (void)testChangeApplicationCode_setPushToken_shouldNotBeCalled_afterContactFieldIdChange {
    id mockContactClient = OCMClassMock([EMSContactClientInternal class]);
    OCMStub([mockContactClient clearContactWithCompletionBlock:[OCMArg invokeBlock]]);

    id strictMockPushInternal = OCMStrictClassMock([EMSPushV3Internal class]);
    OCMStub([strictMockPushInternal deviceToken]).andReturn(nil);
    OCMStub([strictMockPushInternal clearPushTokenWithCompletionBlock:[OCMArg invokeBlock]]);

    MERequestContext *meContext = [[MERequestContext alloc] initWithApplicationCode:self.applicationCode
                                                                       uuidProvider:OCMClassMock([EMSUUIDProvider class])
                                                                  timestampProvider:OCMClassMock([EMSTimestampProvider class])
                                                                         deviceInfo:self.mockDeviceInfo
                                                                            storage:OCMClassMock([EMSStorage class])];

    id mockMEContext = OCMPartialMock(meContext);

    __block NSError *returnedError = nil;

    OCMReject([mockContactClient setContactWithContactFieldId:[OCMArg any]
                                           contactFieldValue:[OCMArg any]
                                             completionBlock:^(NSError *error) {
                                             }]);

    _configInternal = [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       meRequestContext:mockMEContext
                                                      preRequestContext:self.mockPreRequestContext
                                                          contactClient:mockContactClient
                                                           pushInternal:strictMockPushInternal
                                                             deviceInfo:self.mockDeviceInfo
                                                  emarsysRequestFactory:self.mockEmarsysRequestFactory
                                             remoteConfigResponseMapper:self.mockResponseMapper
                                                               endpoint:self.mockEndpoint
                                                                 logger:self.mockLogger
                                                                 crypto:self.mockCrypto
                                                                  queue:self.queue
                                                                 waiter:self.waiter
                                                       deviceInfoClient:self.mockDeviceInfoClient];

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionHandler"];
    [self.configInternal changeApplicationCode:nil
                               completionBlock:^(NSError *error) {
                                   returnedError = error;
                                   [expectation fulfill];
                               }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
}

- (void)testChangeApplicationCode_setPushToken_shouldNotBeCalled_whenPushTokenIsNil {
    id strictMockContactClient = OCMStrictClassMock([EMSContactClientInternal class]);
    id strictMockPushInternal = OCMStrictClassMock([EMSPushV3Internal class]);

    OCMStub([self.mockMeRequestContext applicationCode]).andReturn(@"oldAppCode");
    OCMStub([self.mockMeRequestContext hasContactIdentification]).andReturn((YES));

    __block NSError *returnedError = nil;

    _configInternal = [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       meRequestContext:self.mockMeRequestContext
                                                      preRequestContext:self.mockPreRequestContext
                                                          contactClient:strictMockContactClient
                                                           pushInternal:strictMockPushInternal
                                                             deviceInfo:self.mockDeviceInfo
                                                  emarsysRequestFactory:self.mockEmarsysRequestFactory
                                             remoteConfigResponseMapper:self.mockResponseMapper
                                                               endpoint:self.mockEndpoint
                                                                 logger:self.mockLogger
                                                                 crypto:self.mockCrypto
                                                                  queue:self.queue
                                                                 waiter:self.waiter
                                                       deviceInfoClient:self.mockDeviceInfoClient];

    OCMStub([strictMockPushInternal deviceToken]).andReturn(nil);
    OCMStub([strictMockContactClient clearContactWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([strictMockContactClient setContactWithContactFieldId:self.contactFieldId
                                               contactFieldValue:self.contactFieldValue
                                                 completionBlock:[OCMArg invokeBlock]]);
    OCMStub([strictMockPushInternal clearPushTokenWithCompletionBlock:[OCMArg invokeBlock]]);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionHandler"];
    [self.configInternal changeApplicationCode:@"newApplicationCode"
                               completionBlock:^(NSError *error) {
                                   returnedError = error;
                                   [expectation fulfill];
                               }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];

    OCMVerify([strictMockContactClient clearContactWithCompletionBlock:[OCMArg any]]);

    OCMReject([strictMockPushInternal setPushToken:self.deviceToken
                                   completionBlock:[OCMArg any]]);

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
}

- (void)testChangeApplicationCode_shouldCallSetPushTokenImmediately_whenApplicationCodeIsNil {
    id strictMockContactClient = OCMStrictClassMock([EMSContactClientInternal class]);
    id mockPushInternal = OCMClassMock([EMSPushV3Internal class]);

    OCMStub([self.mockMeRequestContext applicationCode]).andReturn(@"oldAppCode");
    OCMStub([self.mockMeRequestContext hasContactIdentification]).andReturn((YES));

    __block NSError *returnedError = nil;

    _configInternal = [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       meRequestContext:self.mockMeRequestContext
                                                      preRequestContext:self.mockPreRequestContext
                                                          contactClient:strictMockContactClient
                                                           pushInternal:mockPushInternal
                                                             deviceInfo:self.mockDeviceInfo
                                                  emarsysRequestFactory:self.mockEmarsysRequestFactory
                                             remoteConfigResponseMapper:self.mockResponseMapper
                                                               endpoint:self.mockEndpoint
                                                                 logger:self.mockLogger
                                                                 crypto:self.mockCrypto
                                                                  queue:self.queue
                                                                 waiter:self.waiter
                                                       deviceInfoClient:self.mockDeviceInfoClient];

    OCMStub([self.mockMeRequestContext applicationCode]).andReturn(nil);
    OCMStub([mockPushInternal deviceToken]).andReturn(self.deviceToken);
    OCMStub([mockPushInternal setPushToken:self.deviceToken
                           completionBlock:[OCMArg invokeBlock]]);
    OCMStub([mockPushInternal clearPushTokenWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([strictMockContactClient clearContactWithCompletionBlock:[OCMArg invokeBlock]]);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionHandler"];
    [self.configInternal changeApplicationCode:@"newApplicationCode"
                               completionBlock:^(NSError *error) {
                                   returnedError = error;
                                   [expectation fulfill];
                               }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];

    OCMReject([strictMockContactClient clearContactWithCompletionBlock:[OCMArg any]]);

    OCMVerify([mockPushInternal setPushToken:self.deviceToken
                             completionBlock:[OCMArg any]]);

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
}

- (void)testChangeApplicationCode_shouldCallSetContactImmediately_whenPushTokenIsNil {
    id strictMockContactClient = OCMStrictClassMock([EMSContactClientInternal class]);
    id mockPushInternal = OCMClassMock([EMSPushV3Internal class]);

    __block NSError *returnedError = nil;

    _configInternal = [[EMSConfigInternal alloc] initWithRequestManager:self.mockRequestManager
                                                       meRequestContext:self.mockMeRequestContext
                                                      preRequestContext:self.mockPreRequestContext
                                                          contactClient:strictMockContactClient
                                                           pushInternal:mockPushInternal
                                                             deviceInfo:self.mockDeviceInfo
                                                  emarsysRequestFactory:self.mockEmarsysRequestFactory
                                             remoteConfigResponseMapper:self.mockResponseMapper
                                                               endpoint:self.mockEndpoint
                                                                 logger:self.mockLogger
                                                                 crypto:self.mockCrypto
                                                                  queue:self.queue
                                                                 waiter:self.waiter
                                                       deviceInfoClient:self.mockDeviceInfoClient];

    OCMStub([self.mockMeRequestContext applicationCode]).andReturn(nil);
    OCMStub([mockPushInternal deviceToken]).andReturn(nil);
    OCMStub([mockPushInternal clearPushTokenWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([strictMockContactClient clearContactWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([strictMockContactClient setContactWithContactFieldId:self.contactFieldId
                                               contactFieldValue:self.contactFieldValue
                                                 completionBlock:[OCMArg invokeBlock]]);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionHandler"];
    [self.configInternal changeApplicationCode:@"newApplicationCode"
                               completionBlock:^(NSError *error) {
                                   returnedError = error;
                                   [expectation fulfill];
                               }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];

    OCMReject([strictMockContactClient clearContactWithCompletionBlock:[OCMArg any]]);

    OCMReject([mockPushInternal setPushToken:self.deviceToken
                             completionBlock:[OCMArg any]]);
    OCMExpect([strictMockContactClient setContactWithContactFieldId:self.contactFieldId
                                                 contactFieldValue:self.contactFieldValue
                                                   completionBlock:[OCMArg any]]);

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
}

- (void)testChangeMerchantIdCompletionBlock {
    NSString *newMerchantId = @"newMerchantId";

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];
    [self.configInternal changeMerchantId:newMerchantId
                          completionBlock:^(NSError *error) {
                              [expectation fulfill];
                          }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];

    OCMVerify([self.mockPreRequestContext setMerchantId:newMerchantId]);

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
}

- (void)testChangeMerchantId_shouldNotRefresh {
    EMSConfigInternal *partialMockConfigInternal = OCMPartialMock(self.configInternal);

    OCMReject([partialMockConfigInternal refreshConfigFromRemoteConfigWithCompletionBlock:[OCMArg any]]);

    [partialMockConfigInternal changeMerchantId:@"testMerchantId"];
}

- (void)testChangeMerchantId_shouldSetMerchantId_inPRERequestContext {
    NSString *newMerchantId = @"newMerchantId";

    [self.configInternal changeMerchantId:newMerchantId];

    OCMVerify([self.mockPreRequestContext setMerchantId:newMerchantId]);
}

- (void)testChangeMerchantId_shouldResetRemoteConfig {
    NSString *newMerchantId = @"newMerchantId";

    [self.configInternal changeMerchantId:newMerchantId];
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

- (void)testRefreshConfigFromRemoteConfig_shouldNotDoAnything_whenApplicationCodeIsNil {
    OCMReject([self.mockEmarsysRequestFactory createRemoteConfigSignatureRequestModel]);
    OCMReject([self.mockRequestManager submitRequestModelNow:[OCMArg any]
                                                successBlock:[OCMArg any]
                                                  errorBlock:[OCMArg any]]);

    __block BOOL completionBlockInvoked = NO;

    [self.configInternal refreshConfigFromRemoteConfigWithCompletionBlock:^(NSError *error) {
        completionBlockInvoked = YES;
    }];

    XCTAssertTrue(completionBlockInvoked);
}

- (void)testRefreshConfigFromRemoteConfig_signature_error {
    OCMStub([self.mockMeRequestContext applicationCode]).andReturn(@"testApplicationCode");

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

    __block BOOL completionBlockInvoked = NO;

    [self.configInternal refreshConfigFromRemoteConfigWithCompletionBlock:^(NSError *error) {
        completionBlockInvoked = YES;
    }];

    XCTAssertTrue(completionBlockInvoked);
    OCMVerify([self.mockEndpoint reset]);
    OCMVerify([self.mockLogger reset]);
}

- (void)testRefreshConfigFromRemoteConfig_signature_success {
    OCMStub([self.mockMeRequestContext applicationCode]).andReturn(@"testApplicationCode");
    OCMStub([self.mockCrypto verifyContent:[OCMArg any]
                             withSignature:[OCMArg any]]).andReturn(YES);

    NSData *signatureData = [NSData new];

    EMSResponseModel *mockResponse = OCMClassMock([EMSResponseModel class]);
    OCMStub([mockResponse statusCode]).andReturn(@200);
    OCMStub([mockResponse body]).andReturn(signatureData);

    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([mockRequestModel requestId]).andReturn(@"testRequestId");

    OCMStub([self.mockEmarsysRequestFactory createRemoteConfigSignatureRequestModel]).andReturn(mockRequestModel);
    OCMStub([self.mockEmarsysRequestFactory createRemoteConfigRequestModel]).andReturn(mockRequestModel);
    OCMStub([self.mockRequestManager submitRequestModelNow:mockRequestModel
                                              successBlock:([OCMArg invokeBlockWithArgs:@"testRequestId",
                                                                                        mockResponse,
                                                                                        nil])
                                                errorBlock:[OCMArg any]]);
    EMSConfigInternal *partialMockConfigInternal = OCMPartialMock(self.configInternal);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"expectation"];

    __block BOOL completionBlockInvoked = NO;
    EMSCompletionBlock completionBlock = ^(NSError *error) {
        completionBlockInvoked = YES;
        [expectation fulfill];
    };

    [partialMockConfigInternal refreshConfigFromRemoteConfigWithCompletionBlock:completionBlock];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2];

    OCMVerify([partialMockConfigInternal fetchRemoteConfigWithSignatureData:signatureData
                                                            completionBlock:completionBlock]);
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertTrue(completionBlockInvoked);
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

    [self.configInternal fetchRemoteConfigWithSignatureData:signatureData
                                            completionBlock:nil];

    OCMVerify([self.mockEndpoint reset]);
    OCMVerify([self.mockLogger reset]);
}

- (void)testRefreshConfigFromRemoteConfig_success_verified {
    EMSRemoteConfig *config = OCMClassMock([EMSRemoteConfig class]);
    OCMStub([config features]).andReturn(@{@"mobile_engage": @NO});
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
    [MEExperimental enableFeature:EMSInnerFeature.mobileEngage];

    [self.configInternal fetchRemoteConfigWithSignatureData:signatureData
                                            completionBlock:nil];

    OCMVerify([self.mockCrypto verifyContent:contentData
                               withSignature:signatureData]);
    OCMVerify([self.mockEndpoint updateUrlsWithRemoteConfig:config]);
    OCMVerify([self.mockLogger updateWithRemoteConfig:config]);
    XCTAssertFalse([MEExperimental isFeatureEnabled:EMSInnerFeature.mobileEngage]);
}

- (void)testRefreshConfigFromRemoteConfig_success_verified_overrideEventServiceV4 {
    [MEExperimental enableFeature:EMSInnerFeature.eventServiceV4];

    EMSRemoteConfig *config = OCMClassMock([EMSRemoteConfig class]);
    OCMStub([config features]).andReturn(@{@"event_service_v4": @NO});
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

    [self.configInternal fetchRemoteConfigWithSignatureData:signatureData
                                            completionBlock:nil];

    OCMVerify([self.mockCrypto verifyContent:contentData
                               withSignature:signatureData]);
    OCMVerify([self.mockEndpoint updateUrlsWithRemoteConfig:config]);
    OCMVerify([self.mockLogger updateWithRemoteConfig:config]);
    XCTAssertFalse([MEExperimental isFeatureEnabled:EMSInnerFeature.eventServiceV4]);
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

    [self.configInternal fetchRemoteConfigWithSignatureData:signatureData
                                            completionBlock:nil];

    OCMVerify([self.mockCrypto verifyContent:contentData
                               withSignature:signatureData]);
    OCMVerify([self.mockEndpoint reset]);
    OCMVerify([self.mockLogger reset]);
}

- (void)testSdkVersion {
    XCTAssertEqualObjects([self.configInternal sdkVersion], EMARSYS_SDK_VERSION);
}


@end
