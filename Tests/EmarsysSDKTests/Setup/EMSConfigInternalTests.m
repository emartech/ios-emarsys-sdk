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

- (void)testApplicationCode {
    XCTAssertEqualObjects(self.applicationCode, self.configInternal.applicationCode);
}

- (void)testChangeApplicationCode {
    NSString *changedAppCode = @"changedApplicationCode";

    [self.configInternal changeApplicationCode:changedAppCode
                             completionHandler:^(NSError *error) {
                             }];

    XCTAssertEqualObjects(changedAppCode, self.configInternal.applicationCode);
}

- (void)testChangeApplicationCode_completionHandler_mustNotBeNil {
    @try {
        [self.configInternal changeApplicationCode:@"newApplicationCode"
                                 completionHandler:nil];
        XCTFail(@"Expected Exception when completionHandler is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: completionHandler");
    }
}

- (void)testChangeApplicationCode_clearContact {
    OCMStub([self.mockMobileEngage clearContactWithCompletionBlock:[OCMArg invokeBlock]]);

    __block NSError *returnedError = [NSError errorWithCode:1400
                                       localizedDescription:@"testError"];
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionHandler"];
    [self.configInternal changeApplicationCode:@"newApplicationCode"
                             completionHandler:^(NSError *error) {
                                 returnedError = error;
                                 [expectation fulfill];
                             }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:5];

    OCMVerify([self.mockMobileEngage clearContactWithCompletionBlock:[OCMArg any]]);

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
}

- (void)testChangeApplicationCode_shouldCallSetContact {
    OCMStub([self.mockMobileEngage setContactWithContactFieldValue:self.contactFieldValue
                                                   completionBlock:[OCMArg invokeBlock]]);

    __block NSError *returnedError = [NSError errorWithCode:1400
                                       localizedDescription:@"testError"];
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionHandler"];
    [self.configInternal changeApplicationCode:@"newApplicationCode"
                             completionHandler:^(NSError *error) {
                                 returnedError = error;
                                 [expectation fulfill];
                             }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:5];

    OCMVerify([self.mockMobileEngage setContactWithContactFieldValue:self.contactFieldValue
                                                     completionBlock:[OCMArg any]]);

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
}

- (void)testChangeApplicationCode_shouldCallSetPushToken {
    OCMStub([self.mockPushInternal setPushToken:self.deviceToken
                                completionBlock:[OCMArg invokeBlock]]);

    __block NSError *returnedError = [NSError errorWithCode:1400
                                       localizedDescription:@"testError"];
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionHandler"];
    [self.configInternal changeApplicationCode:@"newApplicationCode"
                             completionHandler:^(NSError *error) {
                                 returnedError = error;
                                 [expectation fulfill];
                             }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:5];

    OCMVerify([self.mockPushInternal setPushToken:self.deviceToken
                                  completionBlock:[OCMArg any]]);

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
}

- (void)testMerchantId {
    XCTAssertEqualObjects(self.merchantId, self.configInternal.merchantId);
}

- (void)testChangeMerchantId {
    NSString *newMerchantId = @"newMerchantId";

    [self.configInternal changeMerchantId:newMerchantId];

    XCTAssertEqualObjects(newMerchantId, self.configInternal.merchantId);
}

- (void)testContactFieldId {
    XCTAssertEqualObjects(self.contactFieldId, self.configInternal.contactFieldId);
}

- (void)testSetContactFieldId {
    NSNumber *newContactFieldId = @5;
    [self.configInternal setContactFieldId:newContactFieldId];

    XCTAssertEqualObjects(newContactFieldId, self.configInternal.contactFieldId);
}

- (void)testSetContactFieldId_contactFieldId_mustNotBeNil {
    @try {
        [self.configInternal setContactFieldId:nil];
        XCTFail(@"Expected Exception when contactFieldId is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: contactFieldId");
    }


}

@end
