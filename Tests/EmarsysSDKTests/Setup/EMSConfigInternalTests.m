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

@interface EMSConfigInternalTests : XCTestCase

@property(nonatomic, strong) EMSConfigInternal *configInternal;
@property(nonatomic, strong) NSString *applicationCode;
@property(nonatomic, strong) NSString *merchantId;
@property(nonatomic, strong) NSNumber *contactFieldId;
@property(nonatomic, strong) EMSConfig *testConfig;
@property(nonatomic, strong) NSArray<id <EMSFlipperFeature>> *features;
@property(nonatomic, strong) MERequestContext *mockMeRequestContext;
@property(nonatomic, strong) PRERequestContext *mockPreRequestContext;
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

    _mockMeRequestContext = OCMClassMock([MERequestContext class]);
    _mockPreRequestContext = OCMClassMock([PRERequestContext class]);
    _mockMobileEngage = OCMClassMock([EMSMobileEngageV3Internal class]);
    _mockPushInternal = OCMClassMock([EMSPushV3Internal class]);

    OCMStub([self.mockMeRequestContext contactFieldValue]).andReturn(self.contactFieldValue);
    OCMStub([self.mockPushInternal deviceToken]).andReturn(self.deviceToken);

    _testConfig = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
        [builder setMobileEngageApplicationCode:self.applicationCode];
        [builder setMerchantId:self.merchantId];
        [builder setContactFieldId:self.contactFieldId];
        [builder setExperimentalFeatures:self.features];
    }];

    _configInternal = [[EMSConfigInternal alloc] initWithMeRequestContext:self.mockMeRequestContext
                                                        preRequestContext:self.mockPreRequestContext
                                                             mobileEngage:self.mockMobileEngage
                                                             pushInternal:self.mockPushInternal];
}

- (void)testInit_meRequestContext_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithMeRequestContext:nil
                                          preRequestContext:self.mockPreRequestContext
                                               mobileEngage:self.mockMobileEngage
                                               pushInternal:self.mockPushInternal];
        XCTFail(@"Expected Exception when meRequestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: meRequestContext");
    }
}

- (void)testInit_mobileEngage_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithMeRequestContext:self.mockMeRequestContext
                                          preRequestContext:self.mockPreRequestContext
                                               mobileEngage:nil
                                               pushInternal:self.mockPushInternal];
        XCTFail(@"Expected Exception when mobileEngage is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: mobileEngage");
    }
}

- (void)testInit_pushInternal_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithMeRequestContext:self.mockMeRequestContext
                                          preRequestContext:self.mockPreRequestContext
                                               mobileEngage:self.mockMobileEngage
                                               pushInternal:nil];
        XCTFail(@"Expected Exception when pushInternal is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: pushInternal");
    }
}

- (void)testInit_preRequestContext_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithMeRequestContext:self.mockMeRequestContext
                                          preRequestContext:nil
                                               mobileEngage:self.mockMobileEngage
                                               pushInternal:self.mockPushInternal];
        XCTFail(@"Expected Exception when preRequestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: preRequestContext");
    }
}

- (void)testChangeApplicationCode_completionHandler_isNil {
    id strictMockMobileEngage = OCMStrictClassMock([EMSMobileEngageV3Internal class]);
    id strictMockPushInternal = OCMStrictClassMock([EMSPushV3Internal class]);

    _configInternal = [[EMSConfigInternal alloc] initWithMeRequestContext:self.mockMeRequestContext
                                                        preRequestContext:self.mockPreRequestContext
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

    _configInternal = [[EMSConfigInternal alloc] initWithMeRequestContext:self.mockMeRequestContext
                                                        preRequestContext:self.mockPreRequestContext
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

    _configInternal = [[EMSConfigInternal alloc] initWithMeRequestContext:self.mockMeRequestContext
                                                        preRequestContext:self.mockPreRequestContext
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

- (void)testChangeApplicationCode_setPushToken_shouldCallCompletionBlockWithError {
    id strictMockMobileEngage = OCMStrictClassMock([EMSMobileEngageV3Internal class]);
    id strictMockPushInternal = OCMStrictClassMock([EMSPushV3Internal class]);

    NSError *inputError = [NSError errorWithCode:1400
                                       localizedDescription:@"testError"];
    __block NSError *returnedError = nil;

    _configInternal = [[EMSConfigInternal alloc] initWithMeRequestContext:self.mockMeRequestContext
                                                        preRequestContext:self.mockPreRequestContext
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

- (void)testChangeApplicationCode_setPushToken_shouldNotBeCalled_whenPushTokenIsNil {
    id strictMockMobileEngage = OCMStrictClassMock([EMSMobileEngageV3Internal class]);
    id strictMockPushInternal = OCMStrictClassMock([EMSPushV3Internal class]);

    __block NSError *returnedError = nil;

    _configInternal = [[EMSConfigInternal alloc] initWithMeRequestContext:self.mockMeRequestContext
                                                        preRequestContext:self.mockPreRequestContext
                                                             mobileEngage:strictMockMobileEngage
                                                             pushInternal:strictMockPushInternal];

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

- (void)testChangeMerchantId_shouldSetMerchantId_inPRERequestContext {
    NSString *newMerchantId = @"newMerchantId";

    [self.configInternal changeMerchantId:newMerchantId];

    OCMExpect([self.mockPreRequestContext setMerchantId:newMerchantId]);
}

@end
