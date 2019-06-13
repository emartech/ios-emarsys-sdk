//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSConfig.h"

@interface EMSConfigTests : XCTestCase

@end

@implementation EMSConfigTests

- (void)testMakeWithBuilder_builderBlock_mustNotBeNil {
    @try {
        [EMSConfig makeWithBuilder:nil];
        XCTFail(@"Expected Exception when builderBlock is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: builderBlock");
    }
}

@end
