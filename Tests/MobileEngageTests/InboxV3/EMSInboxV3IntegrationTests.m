//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Emarsys.h"
#import "EmarsysTestUtils.h"

@interface EMSInboxV3IntegrationTests : XCTestCase

@end

@implementation EMSInboxV3IntegrationTests

- (void)setUp {
    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                       withDependencyContainer:nil];
    [EmarsysTestUtils waitForSetCustomer];
    [EmarsysTestUtils waitForSetPushToken];
}

- (void)tearDown {
    [EmarsysTestUtils tearDownEmarsys];
}

- (void)testFetchMessages {
    __block EMSInboxResult *returnedInboxResult = nil;
    __block NSError *returnedError = nil;

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    [Emarsys.messageInbox fetchMessagesWithResultBlock:^(EMSInboxResult *inboxResult, NSError *error) {
        returnedInboxResult = inboxResult;
        returnedError = error;
        [expectation fulfill];
    }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
    XCTAssertNotNil(returnedInboxResult);
}

- (void)testAddTag {
    __block NSError *returnedError = nil;

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];
    [Emarsys.messageInbox addTag:@"testTag"
                      forMessage:@"testMessageId"
                 completionBlock:^(NSError *error) {
                     returnedError = error;
                     [expectation fulfill];
                 }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
}

- (void)testRemoveTag {
    __block NSError *returnedError = nil;

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];
    [Emarsys.messageInbox removeTag:@"testTag"
                        fromMessage:@"testMessageId"
                    completionBlock:^(NSError *error) {
                        returnedError = error;
                        [expectation fulfill];
                    }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
}

@end