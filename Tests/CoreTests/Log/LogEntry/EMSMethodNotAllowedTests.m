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
                                               sel:_cmd
                                        parameters:@{@"key": @"value"}];
        XCTFail(@"Expected exception when klass is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: klass");
    }
}

- (void)testInit_shouldNotAccept_nilSel {
    @try {
        [[EMSMethodNotAllowed alloc] initWithClass:[NSObject class]
                                               sel:nil
                                        parameters:@{@"key": @"value"}];
        XCTFail(@"Expected exception when sel is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: sel");
    }
}

- (void)testInitProto_shouldNotAccept_nilProtocol {
    @try {
        [[EMSMethodNotAllowed alloc] initWithProtocol:nil
                                                  sel:_cmd
                                           parameters:@{@"key": @"value"}];
        XCTFail(@"Expected exception when proto is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: proto");
    }
}

- (void)testInitProto_shouldNotAccept_nilSel {
    @try {
        [[EMSMethodNotAllowed alloc] initWithProtocol:@protocol(EMSLogEntryProtocol)
                                                  sel:nil
                                           parameters:@{@"key": @"value"}];
        XCTFail(@"Expected exception when sel is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: sel");
    }
}

- (void)testTopic {
    EMSMethodNotAllowed *methodNotAllowed = [[EMSMethodNotAllowed alloc] initWithClass:[NSObject class]
                                                                                   sel:_cmd
                                                                            parameters:nil];
    XCTAssertEqualObjects(methodNotAllowed.topic, @"log_method_not_allowed");
}

- (void)testData {
    NSDictionary *expectedDataDictionary = @{
        @"class_name": @"NSObject",
        @"method_name": @"testData",
        @"parameters": @{@"param1": @"value1"}
    };
    EMSMethodNotAllowed *methodNotAllowed = [[EMSMethodNotAllowed alloc] initWithClass:[NSObject class]
                                                                                   sel:_cmd
                                                                            parameters:@{@"param1": @"value1"}];
    XCTAssertEqualObjects(expectedDataDictionary, methodNotAllowed.data);
}

@end
