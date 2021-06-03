//
//  Copyright © 2021 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSOpenExternalUrlActionModel.h"

@interface EMSOpenExternalUrlActionModelTests : XCTestCase

@end

@implementation EMSOpenExternalUrlActionModelTests

- (void)testInit_id_mustNotBeNil {
    @try {
        [[EMSOpenExternalUrlActionModel alloc] initWithId:nil
                                                    title:@"testTitle"
                                                     type:@"testType"
                                                      url:[[NSURL alloc] initWithString:@"https://www.test.url"]];
        XCTFail(@"Expected Exception when id is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: id");
    }
}

- (void)testInit_title_mustNotBeNil {
    @try {
        [[EMSOpenExternalUrlActionModel alloc] initWithId:@"testId"
                                                    title:nil
                                                     type:@"testType"
                                                      url:[[NSURL alloc] initWithString:@"https://www.test.url"]];
        XCTFail(@"Expected Exception when title is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: title");
    }
}

- (void)testInit_type_mustNotBeNil {
    @try {
        [[EMSOpenExternalUrlActionModel alloc] initWithId:@"testId"
                                                    title:@"testTitle"
                                                     type:nil
                                                      url:[[NSURL alloc] initWithString:@"https://www.test.url"]];
        XCTFail(@"Expected Exception when type is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: type");
    }
}

- (void)testInit_url_mustNotBeNil {
    @try {
        [[EMSOpenExternalUrlActionModel alloc] initWithId:@"testId"
                                                    title:@"testTitle"
                                                     type:@"testType"
                                                      url:nil];
        XCTFail(@"Expected Exception when url is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: url");
    }
}

@end
