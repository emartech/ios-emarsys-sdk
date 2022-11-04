//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSDependencyContainer.h"
#import "EMSDependencyInjection.h"
#import "EmarsysTestUtils.h"
#import "EMSLoggingMobileEngageInternal.h"
#import "EMSMobileEngageV3Internal.h"
#import "EMSPushV3Internal.h"
#import "EMSLoggingPushInternal.h"
#import "EMSDeepLinkInternal.h"
#import "EMSLoggingInApp.h"
#import "EMSLoggingPredictInternal.h"
#import "EMSPredictInternal.h"
#import "EMSLoggingGeofenceInternal.h"
#import "EMSGeofenceInternal.h"
#import "EMSLoggingInboxV3.h"
#import "EMSInboxV3.h"

@interface EMSDependencyInjection ()

+ (void)setDependencyContainer:(EMSDependencyContainer *)dependencyContainer;

@end

SPEC_BEGIN(EMSDependencyInjectionTests)

        beforeEach(^{
            [EMSDependencyInjection setDependencyContainer:nil];
        });

        void (^waitForSetup)() = ^void() {
            XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForSetup"];
            [EMSDependencyInjection.dependencyContainer.publicApiOperationQueue addOperationWithBlock:^{
                [expectation fulfill];
            }];
            XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                                  timeout:10];
            XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
        };

        describe(@"setupWithDependencyContainer:", ^{

            it(@"should set the given dependencyContainer", ^{
                EMSDependencyContainer *dependencyContainer = [EMSDependencyContainer mock];

                [EMSDependencyInjection setupWithDependencyContainer:dependencyContainer];

                [[(NSObject <EMSDependencyContainerProtocol> *) EMSDependencyInjection.dependencyContainer should] equal:dependencyContainer];
            });

            it(@"should not override previously set dependencyContainer", ^{
                EMSDependencyContainer *dependencyContainer1 = [EMSDependencyContainer mock];
                EMSDependencyContainer *dependencyContainer2 = [EMSDependencyContainer mock];

                [EMSDependencyInjection setupWithDependencyContainer:dependencyContainer1];
                [EMSDependencyInjection setupWithDependencyContainer:dependencyContainer2];

                [[(NSObject <EMSDependencyContainerProtocol> *) EMSDependencyInjection.dependencyContainer should] equal:dependencyContainer1];
            });
        });

        describe(@"tearDown", ^{

            it(@"should set the dependencyContainer to nil", ^{
                [EMSDependencyInjection setupWithDependencyContainer:[EMSDependencyContainer mock]];

                [EMSDependencyInjection tearDown];

                [[(NSObject <EMSDependencyContainerProtocol> *) EMSDependencyInjection.dependencyContainer should] beNil];
            });
        });

        describe(@"mobileEngage", ^{

            beforeEach(^{
                [EmarsysTestUtils tearDownEmarsys];
            });

            afterEach(^{
                [EmarsysTestUtils tearDownEmarsys];
            });

            it(@"should return with logging instance when mobileEngage is not enabled", ^{
                [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        }]
                                     dependencyContainer:nil];

                waitForSetup();

                [[((NSObject *) EMSDependencyInjection.mobileEngage) should] beKindOfClass:[EMSLoggingMobileEngageInternal class]];
            });

            it(@"should return mobileEngage when it's enabled", ^{
                [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                            [builder setMobileEngageApplicationCode:@"EMS11-C3FD3"];
                        }]
                                     dependencyContainer:nil];

                waitForSetup();

                [[((NSObject *) EMSDependencyInjection.mobileEngage) should] beKindOfClass:[EMSMobileEngageV3Internal class]];
            });
        });

        describe(@"push", ^{
            afterEach(^{
                [EmarsysTestUtils tearDownEmarsys];
            });

            it(@"should return with logging instance when mobileEngage is not enabled", ^{
                [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        }]
                                     dependencyContainer:nil];

                waitForSetup();

                [[((NSObject *) EMSDependencyInjection.push) should] beKindOfClass:[EMSLoggingPushInternal class]];
            });

            it(@"should return real instance when mobileEngage is enabled", ^{
                [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                            [builder setMobileEngageApplicationCode:@"EMS11-C3FD3"];
                        }]
                                     dependencyContainer:nil];

                waitForSetup();

                [[((NSObject *) EMSDependencyInjection.push) should] beKindOfClass:[EMSPushV3Internal class]];
            });
        });

        describe(@"deepLink", ^{
            afterEach(^{
                [EmarsysTestUtils tearDownEmarsys];
            });
            
            it(@"should return real instance when mobileEngage is enabled", ^{
                [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                            [builder setMobileEngageApplicationCode:@"EMS11-C3FD3"];
                        }]
                                     dependencyContainer:nil];

                waitForSetup();

                [[((NSObject *) EMSDependencyInjection.deepLink) should] beKindOfClass:[EMSDeepLinkInternal class]];
            });
        });

        describe(@"iam", ^{
            afterEach(^{
                [EmarsysTestUtils tearDownEmarsys];
            });

            it(@"should return with logging instance when mobileEngage is not enabled", ^{
                [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        }]
                                     dependencyContainer:nil];

                waitForSetup();

                [[((NSObject *) EMSDependencyInjection.iam) should] beKindOfClass:[EMSLoggingInApp class]];
            });

            it(@"should return real instance when mobileEngage is enabled", ^{
                [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                            [builder setMobileEngageApplicationCode:@"EMS11-C3FD3"];
                        }]
                                     dependencyContainer:nil];

                waitForSetup();

                [[((NSObject *) EMSDependencyInjection.iam) should] beKindOfClass:[MEInApp class]];
            });
        });

        describe(@"predict", ^{
            afterEach(^{
                [EmarsysTestUtils tearDownEmarsys];
            });

            it(@"should return with logging instance when predict is not enabled", ^{
                [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        }]
                                     dependencyContainer:nil];

                waitForSetup();

                [[((NSObject *) EMSDependencyInjection.predict) should] beKindOfClass:[EMSLoggingPredictInternal class]];
            });

            it(@"should return real instance when predict is enabled", ^{
                [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                            [builder setMerchantId:@"1428C8EE286EC34B"];
                        }]
                                     dependencyContainer:nil];

                waitForSetup();

                [[((NSObject *) EMSDependencyInjection.predict) should] beKindOfClass:[EMSPredictInternal class]];
            });
        });

        describe(@"geofence", ^{
            afterEach(^{
                [EmarsysTestUtils tearDownEmarsys];
            });

            it(@"should return with logging instance when mobileEngage is not enabled", ^{
                [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        }]
                                     dependencyContainer:nil];

                waitForSetup();

                [[((NSObject *) EMSDependencyInjection.geofence) should] beKindOfClass:[EMSLoggingGeofenceInternal class]];
            });

            it(@"should return real instance when mobileEngage is enabled", ^{
                [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                            [builder setMerchantId:@"1428C8EE286EC34B"];
                            [builder setMobileEngageApplicationCode:@"EMS11-C3FD3"];
                        }]
                                     dependencyContainer:nil];

                waitForSetup();

                [[((NSObject *) EMSDependencyInjection.geofence) should] beKindOfClass:[EMSGeofenceInternal class]];
            });
        });

        describe(@"messageInbox", ^{
            afterEach(^{
                [EmarsysTestUtils tearDownEmarsys];
            });

            it(@"should return with logging instance when mobileEngage is not enabled", ^{
                [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        }]
                                     dependencyContainer:nil];

                waitForSetup();

                [[((NSObject *) EMSDependencyInjection.messageInbox) should] beKindOfClass:[EMSLoggingInboxV3 class]];
            });

            it(@"should return real instance when mobileEngage is enabled", ^{
                [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                            [builder setMerchantId:@"1428C8EE286EC34B"];
                            [builder setMobileEngageApplicationCode:@"EMS11-C3FD3"];
                        }]
                                     dependencyContainer:nil];

                waitForSetup();

                [[((NSObject *) EMSDependencyInjection.messageInbox) should] beKindOfClass:[EMSInboxV3 class]];
            });
        });

SPEC_END
