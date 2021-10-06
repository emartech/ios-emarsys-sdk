//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSWaiter.h"
#import <XCTest/XCTest.h>

@implementation EMSWaiter

+ (void)waitForExpectations:(NSArray<XCTestExpectation *> *)expectations {
    [EMSWaiter waitForExpectations:expectations
                           timeout:10];
}

+ (void)waitForExpectations:(NSArray<XCTestExpectation *> *)expectations timeout:(NSTimeInterval)seconds {
    XCTWaiterResult result = [XCTWaiter waitForExpectations:expectations timeout:seconds];
    XCTAssertEqual(result, XCTWaiterResultCompleted);
}

+ (void)waitForTimeout:(NSArray<XCTestExpectation *> *)expectations timeout:(NSTimeInterval)seconds {
    XCTWaiterResult result = [XCTWaiter waitForExpectations:expectations timeout:seconds];
    XCTAssertEqual(result, XCTWaiterResultTimedOut);
}

@end
