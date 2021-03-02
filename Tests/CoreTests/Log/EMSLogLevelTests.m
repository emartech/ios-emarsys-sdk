//
//  Copyright © 2021 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSLogLevel.h"

@interface EMSLogLevelTests : XCTestCase

@end

@implementation EMSLogLevelTests

- (void)testLogLevel {
    XCTAssertEqualObjects(@"logleveltrace", [EMSLogLevel.trace.level lowercaseString]);
    XCTAssertEqualObjects(@"logleveldebug", [EMSLogLevel.debug.level lowercaseString]);
    XCTAssertEqualObjects(@"loglevelinfo", [EMSLogLevel.info.level lowercaseString]);
    XCTAssertEqualObjects(@"loglevelwarn", [EMSLogLevel.warn.level lowercaseString]);
    XCTAssertEqualObjects(@"loglevelerror", [EMSLogLevel.error.level lowercaseString]);
    XCTAssertEqualObjects(@"loglevelmetric", [EMSLogLevel.metric.level lowercaseString]);
}

@end
