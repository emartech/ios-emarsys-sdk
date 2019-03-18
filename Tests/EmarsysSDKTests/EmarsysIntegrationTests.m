//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EmarsysTestUtils.h"
#import "EMSWaiter.h"
#import "NSData+MobileEngine.h"

@interface EmarsysIntegrationTests : XCTestCase

@end

@implementation EmarsysIntegrationTests

- (void)setUp {
    [EmarsysTestUtils setupEmarsysWithFeatures:@[USER_CENTRIC_INBOX]
                       withDependencyContainer:nil];
}

- (void)tearDown {
    [EmarsysTestUtils tearDownEmarsys];
}

- (void)testSetContactWithContactFieldValue_when_valid_clientStateHasSet {
    [self doSetPushToken];

    [self doLogin];
}

- (void)testSetPushToken_when_valid_clientState_contactToken_HaveSet {
    [self doSetPushToken];

    [self doLogin];

    [self doSetPushToken];
}

- (void)doLogin {
    __block NSError *returnedError = [NSError new];
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];
    [Emarsys setContactWithContactFieldValue:@"test@test.com"
                             completionBlock:^(NSError *error) {
                                 returnedError = error;
                                 [expectation fulfill];
                             }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:300];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
}

- (void)doSetPushToken {
    NSData *deviceToken = OCMClassMock([NSData class]);
    OCMStub([deviceToken deviceTokenString]).andReturn(@"test_pushToken_for_iOS_integrationTest");

    __block NSError *returnedError = [NSError new];
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];
    [Emarsys.push setPushToken:deviceToken
               completionBlock:^(NSError *error) {
                   returnedError = error;
                   [expectation fulfill];
               }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:300];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
}

@end
