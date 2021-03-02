//
//  Copyright © 2021 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSLogLevel.h"

@interface EMSLogLevelTests : XCTestCase

@end

@implementation EMSLogLevelTests

- (void)testLogLevel {
    XCTAssertEqualObjects(@"TRACE", EMSLogLevel.trace.level);
    XCTAssertEqualObjects(@"DEBUG", EMSLogLevel.debug.level);
    XCTAssertEqualObjects(@"INFO", EMSLogLevel.info.level);
    XCTAssertEqualObjects(@"WARN", EMSLogLevel.warn.level);
    XCTAssertEqualObjects(@"ERROR", EMSLogLevel.error.level);
    XCTAssertEqualObjects(@"BASIC", EMSLogLevel.basic.level);
}

@end
