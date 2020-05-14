#import <XCTest/XCTest.h>
#import "EmarsysTestUtils.h"

@interface EMSInAppProtocolTests : XCTestCase

@end

@implementation EMSInAppProtocolTests

- (void)setUp {
    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                       withDependencyContainer:nil];
}

- (void)tearDown {
    [EmarsysTestUtils tearDownEmarsys];
}

- (void)testPause {
    [Emarsys.inApp pause];

    XCTAssertTrue([Emarsys.inApp isPaused]);
}

- (void)testResume {
    [Emarsys.inApp resume];

    XCTAssertFalse([Emarsys.inApp isPaused]);
}

- (void)testIsPaused {
    XCTAssertFalse([Emarsys.inApp isPaused]);
}

@end