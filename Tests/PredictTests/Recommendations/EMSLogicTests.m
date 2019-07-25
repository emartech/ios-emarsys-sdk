//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSLogic.h"

@interface EMSLogicTests : XCTestCase

@end

@implementation EMSLogicTests

- (void)testSearch {
    EMSLogic *logic = EMSLogic.search;

    XCTAssertEqualObjects(logic.logic, @"SEARCH");
}

- (void)testSearchWithSearchTerm {
    EMSLogic *logic = [EMSLogic searchWithSearchTerm:@"searchTerm"];

    XCTAssertEqualObjects(logic.logic, @"SEARCH");
    XCTAssertEqualObjects(logic.data, @{@"q": @"searchTerm"});
}

@end