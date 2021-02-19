//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

@interface XCTestCase (Retry)

- (void)retryWithRunnerBlock:(void (^)(XCTestExpectation *expectation))runnerBlock
              assertionBlock:(void (^)(XCTWaiterResult waiterResult))assertionBlock
                  retryCount:(NSInteger)retryCount;

@end