//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSRandomProvider.h"

@interface EMSRandomProviderTest : XCTestCase

@end

@implementation EMSRandomProviderTest

- (void)testProvideDoubleUntil {
    EMSRandomProvider *randomProvider = [EMSRandomProvider new];
    NSNumber *result = [randomProvider provideDoubleUntil:@50];

    XCTAssertGreaterThanOrEqual([result doubleValue], [@0 doubleValue]);
    XCTAssertLessThan([result doubleValue], [@50 doubleValue]);
}

@end