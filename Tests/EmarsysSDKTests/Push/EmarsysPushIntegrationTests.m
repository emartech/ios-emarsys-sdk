//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "Emarsys.h"
#import "EmarsysTestUtils.h"
#import "NSData+MobileEngine.h"
#import "NSError+EMSCore.h"

@interface EmarsysPushIntegrationTests : XCTestCase

@end

@implementation EmarsysPushIntegrationTests

- (void)setUp {
    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                       withDependencyContainer:nil];
}

- (void)tearDown {
    [EmarsysTestUtils tearDownEmarsys];
}

- (void)testSetPushToken {
    NSData *deviceToken = [@"<1234abcd 1234abcd 1234abcd 1234abcd 1234abcd 1234abcd 1234abcd 1234abcd>" dataUsingEncoding:NSUTF8StringEncoding];

    __block NSError *returnedError = [NSError errorWithCode:-1400
                                       localizedDescription:@"testErrorForSetPushtoken"];
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];
    [Emarsys.push setPushToken:deviceToken
               completionBlock:^(NSError *error) {
                   returnedError = error;
                   [expectation fulfill];
               }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
}

@end
