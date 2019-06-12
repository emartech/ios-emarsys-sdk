//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSMethodNotAllowed.h"

@interface EMSMethodNotAllowedTests : XCTestCase

@end

@implementation EMSMethodNotAllowedTests

- (void)testInit_shouldNotAccept_nilClass {
    @try {
        [[EMSMethodNotAllowed alloc] initWithClass:nil
                                        methodName:@"methodName"
                                        parameters:@{@"key": @"value"}];
        XCTFail(@"Expected exception when klass is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: klass");
    }
}

- (void)testInit_shouldNotAccept_nilMethodName {
    @try {
        [[EMSMethodNotAllowed alloc] initWithClass:[NSObject class]
                                        methodName:nil
                                        parameters:@{@"key": @"value"}];
        XCTFail(@"Expected exception when methodName is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: methodName");
    }
}

- (void)testTopic {
    EMSMethodNotAllowed *methodNotAllowed = [[EMSMethodNotAllowed alloc] initWithClass:[NSObject class]
                                                                            methodName:@"methodName"
                                                                            parameters:nil];
    XCTAssertEqualObjects(methodNotAllowed.topic, @"log_method_not_allowed");
}

- (void)testData {
    NSDictionary *expectedDataDictionary = @{
        @"class_name": @"NSObject",
        @"method_name": @"methodName",
        @"parameters": @{@"param1": @"value1"}
    };
    EMSMethodNotAllowed *methodNotAllowed = [[EMSMethodNotAllowed alloc] initWithClass:[NSObject class]
                                                                            methodName:@"methodName"
                                                                            parameters:@{@"param1": @"value1"}];
    XCTAssertEqualObjects(expectedDataDictionary, methodNotAllowed.data);
}

@end
