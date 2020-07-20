//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSEventHandlerProtocolBlockConverter.h"

@interface EMSEventHandlerProtocolBlockConverterTests : XCTestCase

@end

@implementation EMSEventHandlerProtocolBlockConverterTests

- (void)testInit {
    XCTAssertNotNil([EMSEventHandlerProtocolBlockConverter new].eventHandler);
}

@end
