//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "Emarsys.h"
#import "EMSSQLiteHelper.h"
#import "EMSDependencyContainer.h"
#import "MEExperimental.h"
#import "MERequestContext.h"
#import "MEExperimental+Test.h"

#define DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"MEDB.db"]

@interface Emarsys ()

+ (void)setDependencyContainer:(EMSDependencyContainer *)dependencyContainer;

+ (EMSSQLiteHelper *)sqliteHelper;

@end

SPEC_BEGIN(EmarsysIntegrationTests)

        beforeEach(^{
            [[NSFileManager defaultManager] removeItemAtPath:DB_PATH
                                                       error:nil];

            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
            [userDefaults removeObjectForKey:kMEID];
            [userDefaults removeObjectForKey:kMEID_SIGNATURE];
            [userDefaults removeObjectForKey:kEMSLastAppLoginPayload];
            [userDefaults synchronize];

            userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.emarsys.core"];
            [userDefaults setObject:@"IntegrationTests" forKey:@"kEMSHardwareIdKey"];
        });

        afterEach(^{
            [MEExperimental reset];
        });

        void (^setUpEmarsys)(NSArray<MEFlipperFeature> *features) = ^(NSArray<const NSString *> *features) {
            EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                [builder setMobileEngageApplicationCode:@"14C19-A121F"
                                    applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
                [builder setMerchantId:@"dummyMerchantId"];
                [builder setContactFieldId:@3];
                [builder setExperimentalFeatures:features];
            }];
            [Emarsys setupWithConfig:config];
        };

        void (^doLogin)() = ^{
            __block NSError *returnedErrorForSetCustomer = [NSError mock];

            XCTestExpectation *setCustomerExpectation = [[XCTestExpectation alloc] initWithDescription:@"setCustomer"];
            [Emarsys setCustomerWithId:@"test@test.com"
                       completionBlock:^(NSError *error) {
                           returnedErrorForSetCustomer = error;
                           [setCustomerExpectation fulfill];
                       }];

            XCTWaiterResult setCustomerResult = [XCTWaiter waitForExpectations:@[setCustomerExpectation]
                                                                       timeout:20];
            [[returnedErrorForSetCustomer should] beNil];
            [[theValue(setCustomerResult) should] equal:theValue(XCTWaiterResultCompleted)];
        };

        context(@"V3", ^{

            beforeEach(^{
                setUpEmarsys(@[INAPP_MESSAGING, USER_CENTRIC_INBOX]);
            });


            describe(@"setCustomerWithId:completionBlock:", ^{

                it(@"should invoke completion block when its done", ^{
                    doLogin();
                });

            });

            describe(@"clearCustomerWithCompletionBlock:", ^{
                it(@"should invoke completion block when its done", ^{
                    __block NSError *returnedError = [NSError mock];

                    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                    [Emarsys clearCustomerWithCompletionBlock:^(NSError *error) {
                        returnedError = error;
                        [expectation fulfill];
                    }];

                    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation]
                                                                    timeout:20];
                    [[returnedError should] beNil];
                    [[theValue(result) should] equal:theValue(XCTWaiterResultCompleted)];
                });
            });

            describe(@"trackCustomEventWithName:eventAttributes:completionBlock:", ^{
                it(@"should invoke completion block when its done", ^{
                    doLogin();

                    __block NSError *returnedErrorForTrackCustomEvent = [NSError mock];

                    XCTestExpectation *trackCustomEventExpectation = [[XCTestExpectation alloc] initWithDescription:@"trackCustomEvent"];
                    [Emarsys trackCustomEventWithName:@"eventName"
                                      eventAttributes:@{@"key": @"value"}
                                      completionBlock:^(NSError *error) {
                                          returnedErrorForTrackCustomEvent = error;
                                          [trackCustomEventExpectation fulfill];
                                      }];

                    XCTWaiterResult trackCustomEventResult = [XCTWaiter waitForExpectations:@[trackCustomEventExpectation]
                                                                                    timeout:20];
                    [[returnedErrorForTrackCustomEvent should] beNil];
                    [[theValue(trackCustomEventResult) should] equal:theValue(XCTWaiterResultCompleted)];
                });
            });

        });

        context(@"V2", ^{

            beforeEach(^{
                setUpEmarsys(@[]);
            });

            describe(@"setCustomerWithId:completionBlock:", ^{

                it(@"should invoke completion block when its done", ^{
                    doLogin();
                });

            });

            describe(@"clearCustomerWithCompletionBlock:", ^{
                it(@"should invoke completion block when its done", ^{
                    __block NSError *returnedError = [NSError mock];

                    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                    [Emarsys clearCustomerWithCompletionBlock:^(NSError *error) {
                        returnedError = error;
                        [expectation fulfill];
                    }];

                    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation]
                                                                    timeout:20];
                    [[returnedError should] beNil];
                    [[theValue(result) should] equal:theValue(XCTWaiterResultCompleted)];
                });
            });


            describe(@"trackCustomEventWithName:eventAttributes:completionBlock:", ^{
                it(@"should invoke completion block when its done", ^{
                    doLogin();

                    __block NSError *returnedErrorForTrackCustomEvent = [NSError mock];

                    XCTestExpectation *trackCustomEventExpectation = [[XCTestExpectation alloc] initWithDescription:@"trackCustomEvent"];
                    [Emarsys trackCustomEventWithName:@"eventName"
                                      eventAttributes:@{@"key": @"value"}
                                      completionBlock:^(NSError *error) {
                                          returnedErrorForTrackCustomEvent = error;
                                          [trackCustomEventExpectation fulfill];
                                      }];

                    XCTWaiterResult trackCustomEventResult = [XCTWaiter waitForExpectations:@[trackCustomEventExpectation]
                                                                                    timeout:20];
                    [[returnedErrorForTrackCustomEvent should] beNil];
                    [[theValue(trackCustomEventResult) should] equal:theValue(XCTWaiterResultCompleted)];
                });
            });

        });

SPEC_END
