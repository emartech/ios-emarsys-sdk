//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "EMSWaiter.h"

@implementation EMSWaiter

+ (void)waitForExpectations:(NSArray<XCTestExpectation *> *)expectations timeout:(NSTimeInterval)seconds {
    (void) [XCTWaiter waitForExpectations:expectations timeout:seconds];
}


@end