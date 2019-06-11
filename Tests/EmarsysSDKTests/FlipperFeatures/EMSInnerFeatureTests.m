//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSInnerFeature.h"

@interface EMSInnerFeatureTests : XCTestCase

@end

@implementation EMSInnerFeatureTests

- (void)testMobileEngage {
    XCTAssertEqualObjects(EMSInnerFeature.mobileEngage.name, @"InnerFeatureMobileEngage");
}

- (void)testPredict {
    XCTAssertEqualObjects(EMSInnerFeature.predict.name, @"InnerFeaturePredict");
}

- (void)testPredict_lazyInit {
    XCTAssertEqual(EMSInnerFeature.predict, EMSInnerFeature.predict);
}

- (void)testMobileEngage_lazyInit {
    XCTAssertEqual(EMSInnerFeature.mobileEngage, EMSInnerFeature.mobileEngage);
}

@end
