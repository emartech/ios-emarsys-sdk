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
        [EMSRecommendationFilter excludeFilterWithField:nil
                                                isValue:@"testExpectation"];
        XCTFail(@"Expected Exception when field is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: field");
    }
}

- (void)testExcludeWithFieldIsExpectation_value_mustNotBeNil {
    @try {
        [EMSRecommendationFilter excludeFilterWithField:@"testField"
                                                isValue:nil];
        XCTFail(@"Expected Exception when value is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: value");
    }
}

- (void)testExcludeWithFieldIsExpectation {
    NSString *expectedType = @"EXCLUDE";
    NSString *expectedField = @"testField";
    NSString *expectedComparison = @"IS";
    NSArray<NSString *> *expectedExpectations = @[@"testExpectation"];

    EMSRecommendationFilter *result = [EMSRecommendationFilter excludeFilterWithField:@"testField"
                                                                              isValue:@"testExpectation"];

    XCTAssertEqualObjects(result.type, expectedType);
    XCTAssertEqualObjects(result.field, expectedField);
    XCTAssertEqualObjects(result.comparison, expectedComparison);
    XCTAssertEqualObjects(result.expectations, expectedExpectations);
}

- (void)testExcludeWithFieldInExpectations_field_mustNotBeNil {
    @try {
        [EMSRecommendationFilter excludeFilterWithField:nil
                                               inValues:@[@"testExpectation1", @"testExpectation2"]];
        XCTFail(@"Expected Exception when field is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: field");
    }
}

- (void)testExcludeWithFieldInExpectations_values_mustNotBeNil {
    @try {
        [EMSRecommendationFilter excludeFilterWithField:@"testField"
                                               inValues:nil];
        XCTFail(@"Expected Exception when values is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: values");
    }
}

- (void)testExcludeWithFieldInExpectations {
    NSString *expectedType = @"EXCLUDE";
    NSString *expectedField = @"testField";
    NSString *expectedComparison = @"IN";
    NSArray<NSString *> *expectedExpectations = @[@"testExpectation1", @"testExpectation2"];

    EMSRecommendationFilter *result = [EMSRecommendationFilter excludeFilterWithField:@"testField"
                                                                             inValues:@[@"testExpectation1", @"testExpectation2"]];

    XCTAssertEqualObjects(result.type, expectedType);
    XCTAssertEqualObjects(result.field, expectedField);
    XCTAssertEqualObjects(result.comparison, expectedComparison);
    XCTAssertEqualObjects(result.expectations, expectedExpectations);
}

- (void)testExcludeWithFieldHasExpectation_field_mustNotBeNil {
    @try {
        [EMSRecommendationFilter excludeFilterWithField:nil
                                               hasValue:@"testExpectation"];
        XCTFail(@"Expected Exception when field is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: field");
    }
}

- (void)testExcludeWithFieldHasExpectation_value_mustNotBeNil {
    @try {
        [EMSRecommendationFilter excludeFilterWithField:@"testField"
                                               hasValue:nil];
        XCTFail(@"Expected Exception when value is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: value");
    }
}

- (void)testExcludeWithFieldHasExpectation {
    NSString *expectedType = @"EXCLUDE";
    NSString *expectedField = @"testField";
    NSString *expectedComparison = @"HAS";
    NSArray<NSString *> *expectedExpectations = @[@"testExpectation"];

    EMSRecommendationFilter *result = [EMSRecommendationFilter excludeFilterWithField:@"testField"
                                                                             hasValue:@"testExpectation"];

    XCTAssertEqualObjects(result.type, expectedType);
    XCTAssertEqualObjects(result.field, expectedField);
    XCTAssertEqualObjects(result.comparison, expectedComparison);
    XCTAssertEqualObjects(result.expectations, expectedExpectations);
}

- (void)testExcludeWithFieldOverlapsExpectations_field_mustNotBeNil {
    @try {
        [EMSRecommendationFilter excludeFilterWithField:nil
                                         overlapsValues:@[@"testExpectation1", @"testExpectation2"]];
        XCTFail(@"Expected Exception when field is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: field");
    }
}

- (void)testExcludeWithFieldOverlapsExpectations_values_mustNotBeNil {
    @try {
        [EMSRecommendationFilter excludeFilterWithField:@"testField"
                                         overlapsValues:nil];
        XCTFail(@"Expected Exception when values is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: values");
    }
}

- (void)testExcludeWithFieldOverlapsExpectations {
    NSString *expectedType = @"EXCLUDE";
    NSString *expectedField = @"testField";
    NSString *expectedComparison = @"OVERLAPS";
    NSArray<NSString *> *expectedExpectations = @[@"testExpectation1", @"testExpectation2"];

    EMSRecommendationFilter *result = [EMSRecommendationFilter excludeFilterWithField:@"testField"
                                                                       overlapsValues:@[@"testExpectation1", @"testExpectation2"]];

    XCTAssertEqualObjects(result.type, expectedType);
    XCTAssertEqualObjects(result.field, expectedField);
    XCTAssertEqualObjects(result.comparison, expectedComparison);
    XCTAssertEqualObjects(result.expectations, expectedExpectations);
}

- (void)testIncludeWithFieldIsExpectation_field_mustNotBeNil {
    @try {
        [EMSRecommendationFilter includeFilterWithField:nil
                                                isValue:@"testExpectation"];
        XCTFail(@"Expected Exception when field is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: field");
    }
}

- (void)testIncludeWithFieldIsExpectation_value_mustNotBeNil {
    @try {
        [EMSRecommendationFilter includeFilterWithField:@"testField"
                                                isValue:nil];
        XCTFail(@"Expected Exception when value is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: value");
    }
}

- (void)testIncludeWithFieldIsExpectation {
    NSString *expectedType = @"INCLUDE";
    NSString *expectedField = @"testField";
    NSString *expectedComparison = @"IS";
    NSArray<NSString *> *expectedExpectations = @[@"testExpectation"];

    EMSRecommendationFilter *result = [EMSRecommendationFilter includeFilterWithField:@"testField"
                                                                              isValue:@"testExpectation"];

    XCTAssertEqualObjects(result.type, expectedType);
    XCTAssertEqualObjects(result.field, expectedField);
    XCTAssertEqualObjects(result.comparison, expectedComparison);
    XCTAssertEqualObjects(result.expectations, expectedExpectations);
}

- (void)testIncludeWithFieldInExpectations_field_mustNotBeNil {
    @try {
        [EMSRecommendationFilter includeFilterWithField:nil
                                               inValues:@[@"testExpectation1", @"testExpectation2"]];
        XCTFail(@"Expected Exception when field is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: field");
    }
}

- (void)testIncludeWithFieldInExpectations_values_mustNotBeNil {
    @try {
        [EMSRecommendationFilter includeFilterWithField:@"testField"
                                               inValues:nil];
        XCTFail(@"Expected Exception when values is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: values");
    }
}

- (void)testIncludeWithFieldInExpectations {
    NSString *expectedType = @"INCLUDE";
    NSString *expectedField = @"testField";
    NSString *expectedComparison = @"IN";
    NSArray<NSString *> *expectedExpectations = @[@"testExpectation1", @"testExpectation2"];

    EMSRecommendationFilter *result = [EMSRecommendationFilter includeFilterWithField:@"testField"
                                                                             inValues:@[@"testExpectation1", @"testExpectation2"]];

    XCTAssertEqualObjects(result.type, expectedType);
    XCTAssertEqualObjects(result.field, expectedField);
    XCTAssertEqualObjects(result.comparison, expectedComparison);
    XCTAssertEqualObjects(result.expectations, expectedExpectations);
}

- (void)testIncludeWithFieldHasExpectation_field_mustNotBeNil {
    @try {
        [EMSRecommendationFilter includeFilterWithField:nil
                                               hasValue:@"testExpectation"];
        XCTFail(@"Expected Exception when field is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: field");
    }
}

- (void)testIncludeWithFieldHasExpectation_value_mustNotBeNil {
    @try {
        [EMSRecommendationFilter includeFilterWithField:@"testField"
                                               hasValue:nil];
        XCTFail(@"Expected Exception when value is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: value");
    }
}

- (void)testIncludeWithFieldHasExpectations {
    NSString *expectedType = @"INCLUDE";
    NSString *expectedField = @"testField";
    NSString *expectedComparison = @"HAS";
    NSArray<NSString *> *expectedExpectations = @[@"testExpectation1"];

    EMSRecommendationFilter *result = [EMSRecommendationFilter includeFilterWithField:@"testField"
                                                                             hasValue:@"testExpectation1"];

    XCTAssertEqualObjects(result.type, expectedType);
    XCTAssertEqualObjects(result.field, expectedField);
    XCTAssertEqualObjects(result.comparison, expectedComparison);
    XCTAssertEqualObjects(result.expectations, expectedExpectations);
}

- (void)testIncludeWithFieldOverlapsExpectations_field_mustNotBeNil {
    @try {
        [EMSRecommendationFilter includeFilterWithField:nil
                                         overlapsValues:@[@"testExpectation1", @"testExpectation2"]];
        XCTFail(@"Expected Exception when field is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: field");
    }
}

- (void)testIncludeWithFieldOverlapsExpectation_values_mustNotBeNil {
    @try {
        [EMSRecommendationFilter includeFilterWithField:@"testField"
                                         overlapsValues:nil];
        XCTFail(@"Expected Exception when values is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: values");
    }
}

- (void)testIncludeWithFieldOverlapsExpectations {
    NSString *expectedType = @"INCLUDE";
    NSString *expectedField = @"testField";
    NSString *expectedComparison = @"OVERLAPS";
    NSArray<NSString *> *expectedExpectations = @[@"testExpectation1", @"testExpectation2"];

    EMSRecommendationFilter *result = [EMSRecommendationFilter includeFilterWithField:@"testField"
                                                                       overlapsValues:@[@"testExpectation1", @"testExpectation2"]];

    XCTAssertEqualObjects(result.type, expectedType);
    XCTAssertEqualObjects(result.field, expectedField);
    XCTAssertEqualObjects(result.comparison, expectedComparison);
    XCTAssertEqualObjects(result.expectations, expectedExpectations);
}

@end