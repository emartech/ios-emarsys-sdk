//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSDeviceInfoV3ClientInternal.h"
#import "EmarsysTestUtils.h"
#import "EMSDependencyInjection.h"
#import "EMSWaiter.h"
#import "MERequestContext.h"

@interface EMSDeviceInfoClientV3InternalIntegrationTests : XCTestCase

@end

@implementation EMSDeviceInfoClientV3InternalIntegrationTests

- (void)setUp {
    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                       withDependencyContainer:nil];
    [EmarsysTestUtils waitForSetPushToken];
    [EmarsysTestUtils waitForSetCustomer];
}

- (void)tearDown {
    [EmarsysTestUtils tearDownEmarsys];
}

- (void)testSendDeviceInfo {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
    [userDefaults removeObjectForKey:kDEVICE_INFO];
    [userDefaults synchronize];

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"wait for completion"];
    [EMSDependencyInjection.dependencyContainer.deviceInfoClient sendDeviceInfoWithCompletionBlock:^(NSError *error) {
        XCTAssertNil(error);
        [expectation fulfill];
    }];

    [EMSWaiter waitForExpectations:@[expectation]
                           timeout:30];
}

@end
