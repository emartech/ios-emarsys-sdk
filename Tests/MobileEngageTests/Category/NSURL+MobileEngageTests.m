//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MEEndpoints.h"
#import "NSURL+MobileEngage.h"

@interface NSURL_MobileEngageTests : XCTestCase

@end

@implementation NSURL_MobileEngageTests

- (void)testIsV3_shouldReturnYes_when_URLClientUrl {
    NSURL *url = [[NSURL alloc] initWithString:CLIENT_URL(@"testApplicationCode")];

    XCTAssertTrue(url.isV3);
}

- (void)testIsV3_shouldReturnNo_when_URLIsNotV3 {
    NSURL *url = [[NSURL alloc] initWithString:@"https://www.emarsys.com"];

    XCTAssertFalse(url.isV3);
}

- (void)testIsV3_shouldReturnYes_when_URLEventUrl {
    NSURL *url = [[NSURL alloc] initWithString:EVENT_URL(@"testApplicationCode")];

    XCTAssertTrue(url.isV3);
}

@end
