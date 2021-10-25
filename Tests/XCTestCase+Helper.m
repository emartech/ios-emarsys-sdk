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
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [operationQueue setName:@"testOperationQueue"];
    [operationQueue setMaxConcurrentOperationCount:1];
    return operationQueue;
}

- (void)tearDownOperationQueue:(NSOperationQueue *)operationQueue {
    [operationQueue cancelAllOperations];
    [operationQueue waitUntilAllOperationsAreFinished];
    operationQueue = nil;
}

@end
