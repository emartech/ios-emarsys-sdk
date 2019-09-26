//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Emarsys.h"
#import "EmarsysTestUtils.h"
#import "NSError+EMSCore.h"

@interface EmarsysConfigIntegrationTests : XCTestCase

@end

@implementation EmarsysConfigIntegrationTests

- (void)setUp {
    [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
            [builder setMobileEngageApplicationCode:@"EMS11-C3FD3"];
            [builder setContactFieldId:@3];
        }]
                         dependencyContainer:nil];
}

- (void)tearDown {
    [EmarsysTestUtils tearDownEmarsys];
}

- (void)testConfig_changeApplicationCode_withPushToken {
    [EmarsysTestUtils waitForSetPushToken];
    [EmarsysTestUtils waitForSetCustomer];

    NSString *expectedApplicationCode = @"EMS4C-9A869";

    XCTAssertEqualObjects(Emarsys.config.applicationCode, @"EMS11-C3FD3");

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionBlock"];
    __block NSError *returnedError = [NSError errorWithCode:1400
                                       localizedDescription:@"testError"];
    [Emarsys.config changeApplicationCode:expectedApplicationCode
                          completionBlock:^(NSError *error) {
                              returnedError = error;
                              [expectation fulfill];
                          }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:5];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(Emarsys.config.applicationCode, expectedApplicationCode);
    XCTAssertNil(returnedError);
}

- (void)testConfig_changeApplicationCode_withoutPushToken {
    [EmarsysTestUtils waitForSetCustomer];

    NSString *expectedApplicationCode = @"EMS4C-9A869";

    XCTAssertEqualObjects(Emarsys.config.applicationCode, @"EMS11-C3FD3");

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionBlock"];
    __block NSError *returnedError = [NSError errorWithCode:1400
                                       localizedDescription:@"testError"];
    [Emarsys.config changeApplicationCode:expectedApplicationCode
                          completionBlock:^(NSError *error) {
                              returnedError = error;
                              [expectation fulfill];
                          }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:5];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(Emarsys.config.applicationCode, expectedApplicationCode);
    XCTAssertNil(returnedError);
}

@end
