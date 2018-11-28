//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSWaiter.h"
#import "Kiwi.h"

@implementation EMSWaiter

+ (void)waitForExpectations:(NSArray<XCTestExpectation *> *)expectations {
    [EMSWaiter waitForExpectations:expectations
                           timeout:10];
}

+ (void)waitForExpectations:(NSArray<XCTestExpectation *> *)expectations timeout:(NSTimeInterval)seconds {
    XCTWaiterResult result = [XCTWaiter waitForExpectations:expectations timeout:seconds];
    [[theValue(result) should] equal:theValue(XCTWaiterResultCompleted)];
}

+ (void)waitForTimeout:(NSArray<XCTestExpectation *> *)expectations timeout:(NSTimeInterval)seconds {
    XCTWaiterResult result = [XCTWaiter waitForExpectations:expectations timeout:seconds];
    [[theValue(result) should] equal:theValue(XCTWaiterResultTimedOut)];
}


@end