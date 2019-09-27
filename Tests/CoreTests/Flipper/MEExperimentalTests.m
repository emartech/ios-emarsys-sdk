//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MEExperimental.h"
#import "FakeFlipperFeature.h"
#import "MEExperimental+Test.h"

@interface MEExperimentalTests : XCTestCase

@end

@implementation MEExperimentalTests

- (void)testIsFeatureEnabled_enableFeature_reset {
    FakeFlipperFeature *feature = [FakeFlipperFeature new];

    XCTAssertFalse([MEExperimental isFeatureEnabled:feature]);

    [MEExperimental enableFeature:feature];

    XCTAssertTrue([MEExperimental isFeatureEnabled:feature]);

    [MEExperimental reset];

    XCTAssertFalse([MEExperimental isFeatureEnabled:feature]);
}

- (void)testIsFeatureEnabled_disableFeature {
    FakeFlipperFeature *feature = [FakeFlipperFeature new];

    XCTAssertFalse([MEExperimental isFeatureEnabled:feature]);

    [MEExperimental enableFeature:feature];

    XCTAssertTrue([MEExperimental isFeatureEnabled:feature]);

    [MEExperimental disableFeature:feature];

    XCTAssertFalse([MEExperimental isFeatureEnabled:feature]);
}

@end
