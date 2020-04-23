//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Emarsys.h"
#import "EmarsysTestUtils.h"
#import "NSError+EMSCore.h"
#import "EMSDependencyInjection.h"
#import "EMSLoggingMobileEngageInternal.h"
#import "EMSPredictInternal.h"
#import "EMSLoggingPredictInternal.h"
#import "MEExperimental.h"
#import "EMSInnerFeature.h"
#import "EMSConfigInternal.h"
#import "EMSEndpoint.h"
#import "MERequestContext.h"


@interface EmarsysConfigIntegrationTests : XCTestCase

@end

@implementation EmarsysConfigIntegrationTests

- (void)setUp {
    [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                [builder setMobileEngageApplicationCode:@"EMS11-C3FD3"];
                [builder setMerchantId:@"1428C8EE286EC34B"];
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

- (void)testConfig_changeApplicationCode_forInvalidApplicationCode {
    [EmarsysTestUtils waitForSetPushToken];
    [EmarsysTestUtils waitForSetCustomer];

    XCTAssertEqualObjects(Emarsys.config.applicationCode, @"EMS11-C3FD3");

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionBlock"];
    __block NSError *returnedError = [NSError errorWithCode:1400
                                       localizedDescription:@"testError"];
    [Emarsys.config changeApplicationCode:@"testInvalidApplicationCode"
                          completionBlock:^(NSError *error) {
                              returnedError = error;
                              [expectation fulfill];
                          }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:5];

    XCTAssertEqualObjects([EMSDependencyInjection.mobileEngage class], [EMSLoggingMobileEngageInternal class]);
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNotNil(returnedError);
}

- (void)testConfig_changeApplicationCode_whenApplicationCodeIsNil {
    [EmarsysTestUtils waitForSetPushToken];
    [EmarsysTestUtils waitForSetCustomer];

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionBlock"];
    __block NSError *returnedError = [NSError errorWithCode:1400
                                       localizedDescription:@"testError"];
    [Emarsys.config changeApplicationCode:nil
                          completionBlock:^(NSError *error) {
                              returnedError = error;
                              [expectation fulfill];
                          }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:5];

    XCTAssertEqualObjects([EMSDependencyInjection.mobileEngage class], [EMSLoggingMobileEngageInternal class]);
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNotNil(returnedError);
}

- (void)testConfig_changeMerchantId_whenNil {
    [EmarsysTestUtils waitForSetPushToken];
    [EmarsysTestUtils waitForSetCustomer];

    XCTAssertEqualObjects([Emarsys.predict class], [EMSPredictInternal class]);

    [Emarsys.config changeMerchantId:nil];

    XCTAssertEqualObjects([Emarsys.predict class], [EMSLoggingPredictInternal class]);
}

- (void)testConfig_changeMerchantId_whenHasValue {
    [EmarsysTestUtils waitForSetPushToken];
    [EmarsysTestUtils waitForSetCustomer];
    [MEExperimental disableFeature:EMSInnerFeature.predict];

    XCTAssertEqualObjects([Emarsys.predict class], [EMSLoggingPredictInternal class]);

    [Emarsys.config changeMerchantId:@"1428C8EE286EC34B"];

    XCTAssertEqualObjects([Emarsys.predict class], [EMSPredictInternal class]);
}

- (void)testRemoteConfig {
    EMSConfigInternal *config = EMSDependencyInjection.dependencyContainer.config;
    [EMSDependencyInjection.dependencyContainer.requestContext setApplicationCode:@"integrationTest"];
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionBlock"];

    [config refreshConfigFromRemoteConfig];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [expectation fulfill];
    });

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:5];

    EMSEndpoint *endpoint = EMSDependencyInjection.dependencyContainer.endpoint;

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(endpoint.eventServiceUrl, @"https://integration.mobile-events.eservice.emarsys.net");
    XCTAssertEqualObjects(endpoint.clientServiceUrl, @"https://integration.me-client.eservice.emarsys.net");
}

@end
