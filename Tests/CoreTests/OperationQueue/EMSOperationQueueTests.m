//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSOperationQueue.h"

@interface EMSOperationQueueTests : XCTestCase

@end

@implementation EMSOperationQueueTests

- (void)testAddOperationWithBlock_shouldBeResilient_toExceptions {
    EMSOperationQueue *operationQueue = [EMSOperationQueue new];
    [operationQueue setMaxConcurrentOperationCount:1];

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForExpectation"];

    [operationQueue addOperationWithBlock:^{
        @throw ([NSException exceptionWithName:@"TestException"
                                        reason:@"TestExceptionReason"
                                      userInfo:@{
                                          @"userInfoKey": @"userInfoValue"
                                      }]);
    }];

    [operationQueue addOperationWithBlock:^{
        [expectation fulfill];
    }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
}

@end
