//
//  Copyright © 2021 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSAppEventActionModel.h"

@interface EMSAppEventActionModelTests : XCTestCase

@end

@implementation EMSAppEventActionModelTests

- (void)testInit_id_mustNotBeNil {
    @try {
        [[EMSAppEventActionModel alloc] initWithId:nil
                                             title:@"testTitle"
                                              type:@"testType"
                                              name:@"testName"
                                           payload:nil];
        XCTFail(@"Expected Exception when id is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: id");
    }
}

- (void)testInit_title_mustNotBeNil {
    @try {
        [[EMSAppEventActionModel alloc] initWithId:@"testId"
                                             title:nil
                                              type:@"testType"
                                              name:@"testName"
                                           payload:nil];
        XCTFail(@"Expected Exception when title is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: title");
    }
}

- (void)testInit_type_mustNotBeNil {
    @try {
        [[EMSAppEventActionModel alloc] initWithId:@"testId"
                                             title:@"testTitle"
                                              type:nil
                                              name:@"testName"
                                           payload:nil];
        XCTFail(@"Expected Exception when type is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: type");
    }
}

- (void)testInit_name_mustNotBeNil {
    @try {
        [[EMSAppEventActionModel alloc] initWithId:@"testId"
                                             title:@"testTitle"
                                              type:@"testType"
                                              name:nil
                                           payload:nil];
        XCTFail(@"Expected Exception when name is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: name");
    }
}

@end
