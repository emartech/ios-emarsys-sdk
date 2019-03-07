//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSPushV3Internal.h"
#import "EMSRequestManager.h"
#import "EMSRequestFactory.h"
#import "NSData+MobileEngine.h"

@interface EMSPushV3InternalTests : XCTestCase

@property(nonatomic, strong) EMSPushV3Internal *push;
@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;

@end

@implementation EMSPushV3InternalTests

- (void)setUp {
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    _mockRequestManager = OCMClassMock([EMSRequestManager class]);

    _push = [[EMSPushV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                               requestManager:self.mockRequestManager];
}

- (void)testInit_requestFactory_mustNotBeNull {
    @try {
        [[EMSPushV3Internal alloc] initWithRequestFactory:nil
                                           requestManager:OCMClassMock([EMSRequestManager class])];
        XCTFail(@"Expected Exception when requestFactory is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestFactory");
    }
}

- (void)testInit_requestManager_mustNotBeNull {
    @try {
        [[EMSPushV3Internal alloc] initWithRequestFactory:OCMClassMock([EMSRequestFactory class])
                                           requestManager:nil];
        XCTFail(@"Expected Exception when requestManager is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestManager");
    }
}

- (void)testSetPushToken_requestFactory_calledWithProperPushToken {
    NSString *token = @"pushTokenString";

    [self.push setPushToken:[self pushTokenFromString:token]];

    OCMVerify([self.mockRequestFactory createPushTokenRequestModelWithPushToken:token]);
}

- (void)testSetPushToken_shouldNotCallRequestFactory_when_pushTokenIsNil {
    OCMReject([self.mockRequestFactory createPushTokenRequestModelWithPushToken:[OCMArg any]]);

    [self.push setPushToken:nil];
}

- (void)testSetPushToken_shouldNotCallRequestFactory_when_pushTokenStringIsNilOrEmpty {
    NSString *token = nil;

    OCMReject([self.mockRequestFactory createPushTokenRequestModelWithPushToken:token]);

    [self.push setPushToken:[self pushTokenFromString:token]];
}

- (void)testSetPushToken_shouldNotCallRequestManager_when_pushTokenIsNil {
    OCMReject([self.mockRequestManager submitRequestModel:[OCMArg any]
                                      withCompletionBlock:[OCMArg any]]);

    [self.push setPushToken:nil];
}

- (void)testSetPushToken {
    NSString *token = @"pushTokenString";
    id mockRequestModel = OCMClassMock([EMSRequestModel class]);

    OCMStub([self.mockRequestFactory createPushTokenRequestModelWithPushToken:token]).andReturn(mockRequestModel);

    [self.push setPushToken:[self pushTokenFromString:token]];

    OCMVerify([self.mockRequestManager submitRequestModel:mockRequestModel
                                      withCompletionBlock:[OCMArg any]]);
}

- (void)testSetPushTokenCompletionBlock_requestFactory_calledWithProperPushToken {
    NSString *token = @"pushTokenString";

    [self.push setPushToken:[self pushTokenFromString:token]
            completionBlock:nil];

    OCMVerify([self.mockRequestFactory createPushTokenRequestModelWithPushToken:token]);
}

- (void)testSetPushTokenCompletionBlock_shouldNotCallRequestFactory_when_pushTokenIsNil {
    OCMReject([self.mockRequestFactory createPushTokenRequestModelWithPushToken:[OCMArg any]]);

    [self.push setPushToken:nil
            completionBlock:nil];
}

- (void)testSetPushTokenCompletionBlock_shouldNotCallRequestFactory_when_pushTokenStringIsNilOrEmpty {
    NSString *token = nil;

    OCMReject([self.mockRequestFactory createPushTokenRequestModelWithPushToken:token]);

    [self.push setPushToken:[self pushTokenFromString:token]
            completionBlock:nil];
}

- (void)testSetPushTokenCompletionBlock_shouldNotCallRequestManager_when_pushTokenIsNil {
    OCMReject([self.mockRequestManager submitRequestModel:[OCMArg any]
                                      withCompletionBlock:[OCMArg any]]);

    [self.push setPushToken:nil
            completionBlock:nil];
}

- (void)testSetPushTokenCompletionBlock {
    NSString *token = @"pushTokenString";
    id mockRequestModel = OCMClassMock([EMSRequestModel class]);
    EMSCompletionBlock completionBlock = ^(NSError *error) {
    };

    OCMStub([self.mockRequestFactory createPushTokenRequestModelWithPushToken:token]).andReturn(mockRequestModel);

    [self.push setPushToken:[self pushTokenFromString:token]
            completionBlock:completionBlock];

    OCMVerify([self.mockRequestManager submitRequestModel:mockRequestModel
                                      withCompletionBlock:completionBlock]);
}

- (NSData *)pushTokenFromString:(NSString *)pushTokenString {
    NSData *mockData = OCMClassMock([NSData class]);
    OCMStub([mockData deviceTokenString]).andReturn(pushTokenString);
    return mockData;
}

@end
