//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSConfigInternal.h"
#import "MERequestContext.h"
#import "EMSMobileEngageV3Internal.h"
#import "NSError+EMSCore.h"
#import "EMSPushV3Internal.h"

@interface EMSConfigInternalTests : XCTestCase

@property(nonatomic, strong) EMSConfigInternal *configInternal;
@property(nonatomic, strong) NSString *applicationCode;
@property(nonatomic, strong) NSString *merchantId;
@property(nonatomic, strong) NSNumber *contactFieldId;
@property(nonatomic, strong) EMSConfig *testConfig;
@property(nonatomic, strong) NSArray<id <EMSFlipperFeature>> *features;
@property(nonatomic, strong) MERequestContext *mockRequestContext;
@property(nonatomic, strong) EMSMobileEngageV3Internal *mockMobileEngage;
@property(nonatomic, strong) EMSPushV3Internal *mockPushInternal;
@property(nonatomic, strong) NSString *contactFieldValue;
@property(nonatomic, strong) NSData *deviceToken;

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

    _mockRequestContext = OCMClassMock([MERequestContext class]);
    _mockMobileEngage = OCMClassMock([EMSMobileEngageV3Internal class]);
    _mockPushInternal = OCMClassMock([EMSPushV3Internal class]);

    OCMStub([self.mockRequestContext contactFieldValue]).andReturn(self.contactFieldValue);
    OCMStub([self.mockPushInternal deviceToken]).andReturn(self.deviceToken);

    _testConfig = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
        [builder setMobileEngageApplicationCode:self.applicationCode];
        [builder setMerchantId:self.merchantId];
        [builder setContactFieldId:self.contactFieldId];
        [builder setExperimentalFeatures:self.features];
    }];

    _configInternal = [[EMSConfigInternal alloc] initWithConfig:self.testConfig
                                                 requestContext:self.mockRequestContext
                                                   mobileEngage:self.mockMobileEngage
                                                   pushInternal:self.mockPushInternal];
}

- (void)testInit_config_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithConfig:nil
                                   requestContext:self.mockRequestContext
                                     mobileEngage:self.mockMobileEngage
                                     pushInternal:self.mockPushInternal];
        XCTFail(@"Expected Exception when config is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: config");
    }
}

- (void)testInit_requestContext_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithConfig:self.testConfig
                                   requestContext:nil
                                     mobileEngage:self.mockMobileEngage
                                     pushInternal:self.mockPushInternal];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestContext");
    }
}

- (void)testInit_mobileEngage_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithConfig:self.testConfig
                                   requestContext:self.mockRequestContext
                                     mobileEngage:nil
                                     pushInternal:self.mockPushInternal];
        XCTFail(@"Expected Exception when mobileEngage is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: mobileEngage");
    }
}

- (void)testInit_pushInternal_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithConfig:self.testConfig
                                   requestContext:self.mockRequestContext
                                     mobileEngage:self.mockMobileEngage
                                     pushInternal:nil];
        XCTFail(@"Expected Exception when pushInternal is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: pushInternal");
    }
}

- (void)testChangeApplicationCode_completionHandler_isNil {
    id strictMockMobileEngage = OCMStrictClassMock([EMSMobileEngageV3Internal class]);
    id strictMockPushInternal = OCMStrictClassMock([EMSPushV3Internal class]);

    _configInternal = [[EMSConfigInternal alloc] initWithConfig:self.testConfig
                                                 requestContext:self.mockRequestContext
                                                   mobileEngage:strictMockMobileEngage
                                                   pushInternal:strictMockPushInternal];

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

    _configInternal = [[EMSConfigInternal alloc] initWithConfig:self.testConfig
                                                 requestContext:self.mockRequestContext
                                                   mobileEngage:strictMockMobileEngage
                                                   pushInternal:strictMockPushInternal];

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

    _configInternal = [[EMSConfigInternal alloc] initWithConfig:self.testConfig
                                                 requestContext:self.mockRequestContext
                                                   mobileEngage:strictMockMobileEngage
                                                   pushInternal:strictMockPushInternal];

    OCMStub([strictMockPushInternal deviceToken]).andReturn(self.deviceToken);
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

- (void)testChangeApplicationCode_clearContact_shouldCallCompletionBlockWithTimeoutError {
    __block NSError *returnedError = nil;

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionHandler"];
    [self.configInternal changeApplicationCode:@"newApplicationCode"
                               completionBlock:^(NSError *error) {
                                   returnedError = error;
                                   [expectation fulfill];
                               }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:6];

    OCMExpect([self.mockMobileEngage clearContactWithCompletionBlock:[OCMArg any]]);

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqual(returnedError.code, 1408);
    XCTAssertEqualObjects(returnedError.localizedDescription, @"Waiter timeout error.");
}


- (void)testChangeApplicationCode_setPushToken_shouldCallCompletionBlockWithError {
    id strictMockMobileEngage = OCMStrictClassMock([EMSMobileEngageV3Internal class]);
    id strictMockPushInternal = OCMStrictClassMock([EMSPushV3Internal class]);

    NSError *inputError = [NSError errorWithCode:1400
                                       localizedDescription:@"testError"];
    __block NSError *returnedError = nil;

    _configInternal = [[EMSConfigInternal alloc] initWithConfig:self.testConfig
                                                 requestContext:self.mockRequestContext
                                                   mobileEngage:strictMockMobileEngage
                                                   pushInternal:strictMockPushInternal];

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

- (void)testChangeApplicationCode_setPushToken_shouldCallCompletionBlockWithTimeoutError {
    __block NSError *returnedError = nil;
    
    OCMStub([self.mockMobileEngage clearContactWithCompletionBlock:[OCMArg invokeBlock]]);
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionHandler"];
    [self.configInternal changeApplicationCode:@"newApplicationCode"
                               completionBlock:^(NSError *error) {
                                   returnedError = error;
                                   [expectation fulfill];
                               }];
    
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:6];

    OCMExpect([self.mockPushInternal setPushToken:self.deviceToken completionBlock:[OCMArg any]]);

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqual(returnedError.code, 1408);
    XCTAssertEqualObjects(returnedError.localizedDescription, @"Waiter timeout error.");
}

- (void)testChangeApplicationCode_setContact_shouldCallCompletionBlockWithTimeoutError {
    __block NSError *returnedError = nil;
    
    OCMStub([self.mockMobileEngage clearContactWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([self.mockPushInternal setPushToken:self.deviceToken completionBlock:[OCMArg invokeBlock]]);
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionHandler"];
    [self.configInternal changeApplicationCode:@"newApplicationCode"
                               completionBlock:^(NSError *error) {
                                   returnedError = error;
                                   [expectation fulfill];
                               }];
    
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:6];

    OCMExpect([self.mockMobileEngage setContactWithContactFieldValue:self.contactFieldValue completionBlock:[OCMArg any]]);

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqual(returnedError.code, 1408);
    XCTAssertEqualObjects(returnedError.localizedDescription, @"Waiter timeout error.");
}

- (void)testMerchantId {
    XCTAssertEqualObjects(self.merchantId, self.configInternal.merchantId);
}

- (void)testChangeMerchantId {
    NSString *newMerchantId = @"newMerchantId";

    [self.configInternal changeMerchantId:newMerchantId];

    XCTAssertEqualObjects(newMerchantId, self.configInternal.merchantId);
}

@end
