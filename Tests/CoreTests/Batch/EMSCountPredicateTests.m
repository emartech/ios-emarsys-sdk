//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSCountPredicate.h"

@interface EMSCountPredicateTests : XCTestCase

@end

@implementation EMSCountPredicateTests

- (void)testInit_shouldNotAccept_nilThreshold {
    @try {
        [[EMSCountPredicate alloc] initWithThreshold:0];
        XCTFail(@"Expected Exception when threshold is less then 1!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: threshold > 0");
    }
}

- (void)testEvaluate_shouldNotAccept_nilValue {
    @try {
        EMSCountPredicate *predicate = [[EMSCountPredicate alloc] initWithThreshold:1];
        [predicate evaluate:nil];
        XCTFail(@"Expected Exception when value is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: value");
    }
}

- (void)testEvaluate_shouldReturnNO_when_thresholdIs1_valueIsEmpty {
    EMSCountPredicate *predicate = [[EMSCountPredicate alloc] initWithThreshold:1];

    BOOL result = [predicate evaluate:@[]];

    XCTAssertFalse(result);
}

- (void)testEvaluate_shouldReturnYES_when_thresholdIs1_valueHas1Element {
    EMSCountPredicate *predicate = [[EMSCountPredicate alloc] initWithThreshold:1];

    BOOL result = [predicate evaluate:@[[NSObject new]]];

    XCTAssertTrue(result);
}

- (void)testEvaluate_shouldReturnYES_when_thresholdIs3_valueHasMoreThan3Element {
    EMSCountPredicate *predicate = [[EMSCountPredicate alloc] initWithThreshold:3];

    BOOL result = [predicate evaluate:@[[NSObject new], [NSObject new], [NSObject new], [NSObject new], [NSObject new]]];

    XCTAssertTrue(result);
}


@end
