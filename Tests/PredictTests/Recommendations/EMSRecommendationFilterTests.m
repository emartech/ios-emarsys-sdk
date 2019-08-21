//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSRecommendationFilter.h"

@interface EMSRecommendationFilterTests : XCTestCase

@end

@implementation EMSRecommendationFilterTests

- (void)testExcludeWithFieldIsExpectation_field_mustNotBeNil {
    @try {
        [EMSRecommendationFilter excludeWithField:nil
                                    isExpectation:@"testExpectation"];
        XCTFail(@"Expected Exception when field is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: field");
    }
}

- (void)testExcludeWithFieldIsExpectation_expectation_mustNotBeNil {
    @try {
        [EMSRecommendationFilter excludeWithField:@"testField"
                                    isExpectation:nil];
        XCTFail(@"Expected Exception when expectation is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: expectation");
    }
}

- (void)testExcludeWithFieldIsExpectation {
    NSString *expectedType = @"EXCLUDE";
    NSString *expectedField = @"testField";
    NSString *expectedComparison = @"IS";
    NSArray<NSString *> *expectedExpectations = @[@"testExpectation"];

    EMSRecommendationFilter *result = [EMSRecommendationFilter excludeWithField:@"testField"
                                                                  isExpectation:@"testExpectation"];

    XCTAssertEqualObjects(result.type, expectedType);
    XCTAssertEqualObjects(result.field, expectedField);
    XCTAssertEqualObjects(result.comparison, expectedComparison);
    XCTAssertEqualObjects(result.expectations, expectedExpectations);
}

- (void)testExcludeWithFieldInExpectations_field_mustNotBeNil {
    @try {
        [EMSRecommendationFilter excludeWithField:nil
                                   inExpectations:@[@"testExpectation1", @"testExpectation2"]];
        XCTFail(@"Expected Exception when field is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: field");
    }
}

- (void)testExcludeWithFieldInExpectations_expectations_mustNotBeNil {
    @try {
        [EMSRecommendationFilter excludeWithField:@"testField"
                                   inExpectations:nil];
        XCTFail(@"Expected Exception when expectations is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: expectations");
    }
}

- (void)testExcludeWithFieldInExpectations {
    NSString *expectedType = @"EXCLUDE";
    NSString *expectedField = @"testField";
    NSString *expectedComparison = @"IN";
    NSArray<NSString *> *expectedExpectations = @[@"testExpectation1", @"testExpectation2"];

    EMSRecommendationFilter *result = [EMSRecommendationFilter excludeWithField:@"testField"
                                                                 inExpectations:@[@"testExpectation1", @"testExpectation2"]];

    XCTAssertEqualObjects(result.type, expectedType);
    XCTAssertEqualObjects(result.field, expectedField);
    XCTAssertEqualObjects(result.comparison, expectedComparison);
    XCTAssertEqualObjects(result.expectations, expectedExpectations);
}

- (void)testExcludeWithFieldHasExpectation_field_mustNotBeNil {
    @try {
        [EMSRecommendationFilter excludeWithField:nil
                                   hasExpectation:@"testExpectation"];
        XCTFail(@"Expected Exception when field is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: field");
    }
}

- (void)testExcludeWithFieldHasExpectation_expectation_mustNotBeNil {
    @try {
        [EMSRecommendationFilter excludeWithField:@"testField"
                                   hasExpectation:nil];
        XCTFail(@"Expected Exception when expectation is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: expectation");
    }
}

- (void)testExcludeWithFieldHasExpectation {
    NSString *expectedType = @"EXCLUDE";
    NSString *expectedField = @"testField";
    NSString *expectedComparison = @"HAS";
    NSArray<NSString *> *expectedExpectations = @[@"testExpectation"];

    EMSRecommendationFilter *result = [EMSRecommendationFilter excludeWithField:@"testField"
                                                                 hasExpectation:@"testExpectation"];

    XCTAssertEqualObjects(result.type, expectedType);
    XCTAssertEqualObjects(result.field, expectedField);
    XCTAssertEqualObjects(result.comparison, expectedComparison);
    XCTAssertEqualObjects(result.expectations, expectedExpectations);
}

- (void)testExcludeWithFieldOverlapsExpectations_field_mustNotBeNil {
    @try {
        [EMSRecommendationFilter excludeWithField:nil
                             overlapsExpectations:@[@"testExpectation1", @"testExpectation2"]];
        XCTFail(@"Expected Exception when field is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: field");
    }
}

- (void)testExcludeWithFieldOverlapsExpectations_expectations_mustNotBeNil {
    @try {
        [EMSRecommendationFilter excludeWithField:@"testField"
                             overlapsExpectations:nil];
        XCTFail(@"Expected Exception when expectations is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: expectations");
    }
}

- (void)testExcludeWithFieldOverlapsExpectations {
    NSString *expectedType = @"EXCLUDE";
    NSString *expectedField = @"testField";
    NSString *expectedComparison = @"OVERLAPS";
    NSArray<NSString *> *expectedExpectations = @[@"testExpectation1", @"testExpectation2"];

    EMSRecommendationFilter *result = [EMSRecommendationFilter excludeWithField:@"testField"
                                                           overlapsExpectations:@[@"testExpectation1", @"testExpectation2"]];

    XCTAssertEqualObjects(result.type, expectedType);
    XCTAssertEqualObjects(result.field, expectedField);
    XCTAssertEqualObjects(result.comparison, expectedComparison);
    XCTAssertEqualObjects(result.expectations, expectedExpectations);
}

- (void)testIncludeWithFieldIsExpectation_field_mustNotBeNil {
    @try {
        [EMSRecommendationFilter includeWithField:nil
                                    isExpectation:@"testExpectation"];
        XCTFail(@"Expected Exception when field is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: field");
    }
}

- (void)testIncludeWithFieldIsExpectation_expectation_mustNotBeNil {
    @try {
        [EMSRecommendationFilter includeWithField:@"testField"
                                    isExpectation:nil];
        XCTFail(@"Expected Exception when expectation is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: expectation");
    }
}

- (void)testIncludeWithFieldIsExpectation {
    NSString *expectedType = @"INCLUDE";
    NSString *expectedField = @"testField";
    NSString *expectedComparison = @"IS";
    NSArray<NSString *> *expectedExpectations = @[@"testExpectation"];

    EMSRecommendationFilter *result = [EMSRecommendationFilter includeWithField:@"testField"
                                                                  isExpectation:@"testExpectation"];

    XCTAssertEqualObjects(result.type, expectedType);
    XCTAssertEqualObjects(result.field, expectedField);
    XCTAssertEqualObjects(result.comparison, expectedComparison);
    XCTAssertEqualObjects(result.expectations, expectedExpectations);
}

- (void)testIncludeWithFieldInExpectations_field_mustNotBeNil {
    @try {
        [EMSRecommendationFilter includeWithField:nil
                                   inExpectations:@[@"testExpectation1", @"testExpectation2"]];
        XCTFail(@"Expected Exception when field is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: field");
    }
}

- (void)testIncludeWithFieldInExpectations_expectations_mustNotBeNil {
    @try {
        [EMSRecommendationFilter includeWithField:@"testField"
                                   inExpectations:nil];
        XCTFail(@"Expected Exception when expectations is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: expectations");
    }
}

- (void)testIncludeWithFieldInExpectations {
    NSString *expectedType = @"INCLUDE";
    NSString *expectedField = @"testField";
    NSString *expectedComparison = @"IN";
    NSArray<NSString *> *expectedExpectations = @[@"testExpectation1", @"testExpectation2"];

    EMSRecommendationFilter *result = [EMSRecommendationFilter includeWithField:@"testField"
                                                                 inExpectations:@[@"testExpectation1", @"testExpectation2"]];

    XCTAssertEqualObjects(result.type, expectedType);
    XCTAssertEqualObjects(result.field, expectedField);
    XCTAssertEqualObjects(result.comparison, expectedComparison);
    XCTAssertEqualObjects(result.expectations, expectedExpectations);
}

- (void)testIncludeWithFieldHasExpectation_field_mustNotBeNil {
    @try {
        [EMSRecommendationFilter includeWithField:nil
                                   hasExpectation:@"testExpectation"];
        XCTFail(@"Expected Exception when field is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: field");
    }
}

- (void)testIncludeWithFieldHasExpectation_expectation_mustNotBeNil {
    @try {
        [EMSRecommendationFilter includeWithField:@"testField"
                                   hasExpectation:nil];
        XCTFail(@"Expected Exception when expectation is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: expectation");
    }
}

- (void)testIncludeWithFieldHasExpectations {
    NSString *expectedType = @"INCLUDE";
    NSString *expectedField = @"testField";
    NSString *expectedComparison = @"HAS";
    NSArray<NSString *> *expectedExpectations = @[@"testExpectation1"];

    EMSRecommendationFilter *result = [EMSRecommendationFilter includeWithField:@"testField"
                                                                 hasExpectation:@"testExpectation1"];

    XCTAssertEqualObjects(result.type, expectedType);
    XCTAssertEqualObjects(result.field, expectedField);
    XCTAssertEqualObjects(result.comparison, expectedComparison);
    XCTAssertEqualObjects(result.expectations, expectedExpectations);
}

- (void)testIncludeWithFieldOverlapsExpectations_field_mustNotBeNil {
    @try {
        [EMSRecommendationFilter includeWithField:nil
                             overlapsExpectations:@[@"testExpectation1", @"testExpectation2"]];
        XCTFail(@"Expected Exception when field is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: field");
    }
}

- (void)testIncludeWithFieldOverlapsExpectation_expectations_mustNotBeNil {
    @try {
        [EMSRecommendationFilter includeWithField:@"testField"
                             overlapsExpectations:nil];
        XCTFail(@"Expected Exception when expectations is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: expectations");
    }
}

- (void)testIncludeWithFieldOverlapsExpectations {
    NSString *expectedType = @"INCLUDE";
    NSString *expectedField = @"testField";
    NSString *expectedComparison = @"OVERLAPS";
    NSArray<NSString *> *expectedExpectations = @[@"testExpectation1", @"testExpectation2"];

    EMSRecommendationFilter *result = [EMSRecommendationFilter includeWithField:@"testField"
                                                           overlapsExpectations:@[@"testExpectation1", @"testExpectation2"]];

    XCTAssertEqualObjects(result.type, expectedType);
    XCTAssertEqualObjects(result.field, expectedField);
    XCTAssertEqualObjects(result.comparison, expectedComparison);
    XCTAssertEqualObjects(result.expectations, expectedExpectations);
}

@end