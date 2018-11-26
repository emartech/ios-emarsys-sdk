//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "Emarsys.h"
#import "EMSSQLiteHelper.h"
#import "EMSDependencyContainer.h"
#import "EmarsysTestUtils.h"

#define TIMEOUT 10

@interface Emarsys ()

+ (void)setDependencyContainer:(EMSDependencyContainer *)dependencyContainer;

+ (EMSSQLiteHelper *)sqliteHelper;

+ (EMSDependencyContainer *)dependencyContainer;

@end

SPEC_BEGIN(EmarsysIntegrationTests)

        afterEach(^{
            [EmarsysTestUtils tearDownEmarsys];
        });

        void (^doLogin)() = ^{
            __block NSError *returnedErrorForSetCustomer = [NSError mock];

            XCTestExpectation *setCustomerExpectation = [[XCTestExpectation alloc] initWithDescription:@"setCustomer"];
            [Emarsys setCustomerWithId:@"test@test.com"
                       completionBlock:^(NSError *error) {
                           returnedErrorForSetCustomer = error;
                           [setCustomerExpectation fulfill];
                       }];

            XCTWaiterResult setCustomerResult = [XCTWaiter waitForExpectations:@[setCustomerExpectation]
                                                                       timeout:TIMEOUT];
            [[returnedErrorForSetCustomer should] beNil];
            [[theValue(setCustomerResult) should] equal:theValue(XCTWaiterResultCompleted)];
        };

        context(@"V3", ^{

            beforeEach(^{
                [EmarsysTestUtils setupEmarsysWithFeatures:@[USER_CENTRIC_INBOX]
                                   withDependencyContainer:nil];
            });

            describe(@"setAnonymousCustomerWithCompletionBlock:", ^{

                it(@"should invoke completion block when its done", ^{
                    __block NSError *returnedError = [NSError mock];

                    XCTestExpectation *setCustomerExpectation = [[XCTestExpectation alloc] initWithDescription:@"setCustomer"];
                    [Emarsys setAnonymousCustomerWithCompletionBlock:^(NSError *error) {
                        returnedError = error;
                        [setCustomerExpectation fulfill];
                    }];

                    XCTWaiterResult setCustomerResult = [XCTWaiter waitForExpectations:@[setCustomerExpectation]
                                                                               timeout:TIMEOUT];
                    [[returnedError should] beNil];
                    [[theValue(setCustomerResult) should] equal:theValue(XCTWaiterResultCompleted)];

                });

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
                                                                    timeout:TIMEOUT];
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
                                                                                    timeout:TIMEOUT];
                    [[returnedErrorForTrackCustomEvent should] beNil];
                    [[theValue(trackCustomEventResult) should] equal:theValue(XCTWaiterResultCompleted)];
                });
            });

            describe(@"trackMessageOpenWithUserInfo:completionBlock:", ^{
                it(@"should invoke completion block when its done", ^{
                    doLogin();

                    __block NSError *returnedError = [NSError mock];
                    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"trackMessageOpen"];
                    [Emarsys.push trackMessageOpenWithUserInfo:@{@"u": @"{\"sid\":\"dd8_zXfDdndBNEQi\"}"}
                                               completionBlock:^(NSError *error) {
                                                   returnedError = error;
                                                   [expectation fulfill];
                                               }];

                    XCTWaiterResult trackMessageOpenResult = [XCTWaiter waitForExpectations:@[expectation]
                                                                                    timeout:TIMEOUT];
                    [[returnedError should] beNil];
                    [[theValue(trackMessageOpenResult) should] equal:theValue(XCTWaiterResultCompleted)];
                });
            });

        });

SPEC_END
