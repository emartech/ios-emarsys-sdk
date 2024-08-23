//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import "XCTestCase+Helper.h"

@implementation XCTestCase (Helper)

- (void)retryWithRunnerBlock:(void (^)(XCTestExpectation *expectation))runnerBlock
              assertionBlock:(void (^)(XCTWaiterResult waiterResult))assertionBlock
                  retryCount:(NSInteger)retryCount {
    BOOL shouldRetry = NO;
    NSException *errorToThrow = nil;
    NSInteger runningCount = 0;
    do {
        errorToThrow = nil;
        @try {
            XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForRunnerBlock"];
            if (runnerBlock) {
                runnerBlock(expectation);
            }
            XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                                  timeout:5];
            if (assertionBlock) {
                assertionBlock(waiterResult);
            }
        } @catch (NSException *exception) {
            errorToThrow = exception;
        }
        if (errorToThrow && runningCount < retryCount) {
            shouldRetry = YES;
        }
        runningCount += 1;
    } while (shouldRetry);
    if (errorToThrow) {
        @throw(errorToThrow);
    }
}

- (NSOperationQueue *)createTestOperationQueue {
    NSString *queueName = [NSString stringWithFormat:@"EMSTestOperationQueue - %@", [NSUUID UUID].UUIDString];
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [operationQueue setName:queueName];
    [operationQueue setMaxConcurrentOperationCount:1];
    return operationQueue;
}

- (void)waitATickOnOperationQueue:(NSOperationQueue *)operationQueue {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForOperationBlock"];
    [operationQueue addOperationWithBlock:^{
        [expectation fulfill];
    }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2.0];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
}

@end
