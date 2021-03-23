//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XCTestCase+Retry.h"
#import "Emarsys.h"
#import "EmarsysTestUtils.h"

@interface EMSInboxV3IntegrationTests : XCTestCase

@property(nonatomic, strong) NSString *testMessageId;

@end

@implementation EMSInboxV3IntegrationTests

- (void)setUp {
    _testMessageId = [NSString stringWithFormat:@"%d", INT_MAX];

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
    [self retryWithRunnerBlock:^(XCTestExpectation *expectation) {
                [Emarsys.messageInbox fetchMessagesWithResultBlock:^(EMSInboxResult *inboxResult, NSError *error) {
                    returnedInboxResult = inboxResult;
                    returnedError = error;
                    [expectation fulfill];
                }];
            }
                assertionBlock:^(XCTWaiterResult waiterResult) {
                    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
                    XCTAssertNil(returnedError);
                    XCTAssertNotNil(returnedInboxResult);
                }
                    retryCount:3];
}

- (void)testAddTag {
    __block NSError *returnedError = nil;

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];
    [Emarsys.messageInbox addTag:@"testTag"
                      forMessage:self.testMessageId
                 completionBlock:^(NSError *error) {
                     returnedError = error;
                     [expectation fulfill];
                 }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
}

- (void)testRemoveTag {
    __block NSError *returnedError = nil;
    [self retryWithRunnerBlock:^(XCTestExpectation *expectation) {
                [Emarsys.messageInbox removeTag:@"testTag"
                                    fromMessage:self.testMessageId
                                completionBlock:^(NSError *error) {
                                    returnedError = error;
                                    [expectation fulfill];
                                }];
            }
                assertionBlock:^(XCTWaiterResult waiterResult) {
                    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
                    XCTAssertNil(returnedError);
                }
                    retryCount:5];
}

@end