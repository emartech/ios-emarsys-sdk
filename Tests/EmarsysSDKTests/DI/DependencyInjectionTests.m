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
#import "EMSLoggingDeepLinkInternal.h"
#import "EMSDeepLinkInternal.h"
#import "EMSLoggingInbox.h"
#import "MEInbox.h"
#import "MEUserNotificationDelegate.h"
#import "EMSLoggingUserNotificationDelegate.h"
#import "MEInApp.h"
#import "EMSLoggingInApp.h"
#import "EMSLoggingPredictInternal.h"
#import "EMSPredictInternal.h"

@interface EMSDependencyInjection ()

+ (void)setDependencyContainer:(EMSDependencyContainer *)dependencyContainer;

@end

SPEC_BEGIN(DependencyInjectionTests)

        beforeEach(^{
            [EMSDependencyInjection setDependencyContainer:nil];
        });

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
            afterEach(^{
                [EmarsysTestUtils tearDownEmarsys];
            });

            it(@"should return with logging instance when mobileEngage is not enabled", ^{
                [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                    }]
                                     dependencyContainer:nil];

                [[((NSObject *) EMSDependencyInjection.mobileEngage) should] beKindOfClass:[EMSLoggingMobileEngageInternal class]];
            });

            it(@"should return mobileEngage when it's enabled", ^{
                [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        [builder setMobileEngageApplicationCode:@"EMS11-C3FD3"];
                    }]
                                     dependencyContainer:nil];

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

                [[((NSObject *) EMSDependencyInjection.push) should] beKindOfClass:[EMSLoggingPushInternal class]];
            });

            it(@"should return real instance when mobileEngage is enabled", ^{
                [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        [builder setMobileEngageApplicationCode:@"EMS11-C3FD3"];
                    }]
                                     dependencyContainer:nil];

                [[((NSObject *) EMSDependencyInjection.push) should] beKindOfClass:[EMSPushV3Internal class]];
            });
        });

        describe(@"deepLink", ^{
            afterEach(^{
                [EmarsysTestUtils tearDownEmarsys];
            });

            it(@"should return with logging instance when mobileEngage is not enabled", ^{
                [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                    }]
                                     dependencyContainer:nil];

                [[((NSObject *) EMSDependencyInjection.deepLink) should] beKindOfClass:[EMSLoggingDeepLinkInternal class]];
            });

            it(@"should return real instance when mobileEngage is enabled", ^{
                [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        [builder setMobileEngageApplicationCode:@"EMS11-C3FD3"];
                    }]
                                     dependencyContainer:nil];

                [[((NSObject *) EMSDependencyInjection.deepLink) should] beKindOfClass:[EMSDeepLinkInternal class]];
            });
        });

        describe(@"inbox", ^{
            afterEach(^{
                [EmarsysTestUtils tearDownEmarsys];
            });

            it(@"should return with logging instance when mobileEngage is not enabled", ^{
                [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                    }]
                                     dependencyContainer:nil];

                [[((NSObject *) EMSDependencyInjection.inbox) should] beKindOfClass:[EMSLoggingInbox class]];
            });

            it(@"should return real instance when mobileEngage is enabled", ^{
                [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        [builder setMobileEngageApplicationCode:@"EMS11-C3FD3"];
                    }]
                                     dependencyContainer:nil];

                [[((NSObject *) EMSDependencyInjection.inbox) should] beKindOfClass:[MEInbox class]];
            });
        });

        describe(@"notificationCenterDelegate", ^{
            afterEach(^{
                [EmarsysTestUtils tearDownEmarsys];
            });

            it(@"should return with logging instance when mobileEngage is not enabled", ^{
                [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                    }]
                                     dependencyContainer:nil];

                [[((NSObject *) EMSDependencyInjection.notificationCenterDelegate) should] beKindOfClass:[EMSLoggingUserNotificationDelegate class]];
            });

            it(@"should return real instance when mobileEngage is enabled", ^{
                [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        [builder setMobileEngageApplicationCode:@"EMS11-C3FD3"];
                    }]
                                     dependencyContainer:nil];

                [[((NSObject *) EMSDependencyInjection.notificationCenterDelegate) should] beKindOfClass:[MEUserNotificationDelegate class]];
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

                [[((NSObject *) EMSDependencyInjection.iam) should] beKindOfClass:[EMSLoggingInApp class]];
            });

            it(@"should return real instance when mobileEngage is enabled", ^{
                [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        [builder setMobileEngageApplicationCode:@"EMS11-C3FD3"];
                    }]
                                     dependencyContainer:nil];

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

                [[((NSObject *) EMSDependencyInjection.predict) should] beKindOfClass:[EMSLoggingPredictInternal class]];
            });

            it(@"should return real instance when predict is enabled", ^{
                [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        [builder setContactFieldId:@3];
                        [builder setMerchantId:@"1428C8EE286EC34B"];
                    }]
                                     dependencyContainer:nil];

                [[((NSObject *) EMSDependencyInjection.predict) should] beKindOfClass:[EMSPredictInternal class]];
            });
        });

SPEC_END
