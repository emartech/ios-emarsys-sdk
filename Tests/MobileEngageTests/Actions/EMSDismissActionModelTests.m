//
//  Copyright © 2021 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSDismissActionModel.h"

@interface EMSDismissActionModelTests : XCTestCase

@end

@implementation EMSDismissActionModelTests


- (void)testInit_id_mustNotBeNil {
    @try {
        [[EMSDismissActionModel alloc] initWithId:nil
                                            title:@"testTitle"
                                             type:@"testType"];
        XCTFail(@"Expected Exception when id is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: id");
    }
}

- (void)testInit_title_mustNotBeNil {
    @try {
        [[EMSDismissActionModel alloc] initWithId:@"testId"
                                            title:nil
                                             type:@"testType"];
        XCTFail(@"Expected Exception when title is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: title");
    }
}

- (void)testInit_type_mustNotBeNil {
    @try {
        [[EMSDismissActionModel alloc] initWithId:@"testId"
                                            title:@"testTitle"
                                             type:nil];
        XCTFail(@"Expected Exception when type is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: type");
    }
}

@end
