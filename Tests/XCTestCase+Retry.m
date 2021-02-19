//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import "XCTestCase+Retry.h"

@implementation XCTestCase (Retry)

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

@end