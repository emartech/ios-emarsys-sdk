//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSScheduler.h"
#import "EMSWaiter.h"
#import "EMSAgenda.h"

SPEC_BEGIN(EMSSchedulerTests)

        __block EMSScheduler *scheduler;
        __block NSOperationQueue *queue;
        __block NSTimeInterval leevay;
        __block NSTimeInterval delay;
        __block NSString *tag;

        beforeEach(^{
            queue = [NSOperationQueue new];
            [queue setName:@"SchedulerTestsOperationQueue"];
            [queue setMaxConcurrentOperationCount:1];
            leevay = 1.0;
            delay = 1.0;
            tag = @"tag";
            scheduler = [[EMSScheduler alloc] initWithOperationQueue:queue
                                                              leeway:leevay];
        });

        afterEach(^{
        });

        describe(@"initWithOperationQueue:leeway:", ^{

            it(@"operationQueue should not be nil", ^{
                @try {
                    [[EMSScheduler alloc] initWithOperationQueue:nil
                                                          leeway:1.0];
                    fail(@"Expected exception when operationQueue is nil");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: operationQueue"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"leeway should be greater than 0", ^{
                @try {
                    [[EMSScheduler alloc] initWithOperationQueue:[NSOperationQueue currentQueue]
                                                          leeway:0];
                    fail(@"Expected exception when leeway is <= 0");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: leeway > 0"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"scheduledAgendas should not be nil", ^{
                EMSScheduler *emsScheduler = [[EMSScheduler alloc] initWithOperationQueue:[NSOperationQueue currentQueue]
                                                                                   leeway:1.0];
                [[emsScheduler.scheduledAgendas shouldNot] beNil];
            });
        });

        describe(@"scheduleTriggerWithTag:handle:interval:triggerBlock:", ^{

            it(@"tag should not be nil", ^{
                @try {
                    [scheduler scheduleTriggerWithTag:nil
                                                delay:1.0
                                             interval:@1.0
                                         triggerBlock:^{
                                         }];
                    fail(@"Expected exception when tag is nil");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: tag"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"delay should be greater than 0", ^{
                @try {
                    [scheduler scheduleTriggerWithTag:@""
                                                delay:0.0
                                             interval:@1.0
                                         triggerBlock:^{
                                         }];
                    fail(@"Expected exception when delay is not greater than 0");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: delay > 0"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"interval should be greater than 0", ^{
                @try {
                    [scheduler scheduleTriggerWithTag:@""
                                                delay:1.0
                                             interval:@0.0
                                         triggerBlock:^{
                                         }];
                    fail(@"Expected exception when interval is not greater than 0");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: !interval || [interval doubleValue] > 0"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"triggerBlock should not be nil", ^{
                @try {
                    [scheduler scheduleTriggerWithTag:@""
                                                delay:1.0
                                             interval:@1.0
                                         triggerBlock:nil];
                    fail(@"Expected exception when triggerBlock is nil");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: triggerBlock"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should register agenda after scheduleTrigger called", ^{
                NSString *const expectedTag = @"tag1";
                const double expectedDelay = 42.0;
                NSNumber *const expectedInterval = @3.0;
                const EMSTriggerBlock expectedTriggerBlock = ^{
                };

                [scheduler scheduleTriggerWithTag:expectedTag
                                            delay:expectedDelay
                                         interval:expectedInterval
                                     triggerBlock:expectedTriggerBlock];

                EMSAgenda *agenda = scheduler.scheduledAgendas[expectedTag];
                [[agenda shouldNot] beNil];
                [[agenda.tag should] equal:expectedTag];
                [[theValue(agenda.delay) should] equal:theValue(expectedDelay)];
                [[theValue(agenda.interval) should] equal:theValue(expectedInterval)];
                [[agenda.triggerBlock should] equal:expectedTriggerBlock];
                [[theValue(agenda.dispatchTimer) shouldNot] beNil];
            });

            it(@"should register multiple agenda after scheduleTrigger called multiple times", ^{
                NSString *const expectedAgendaTag1 = @"tag1";
                const double expectedAgendaDelay1 = 42.0;
                NSNumber *const expectedAgendaInterval1 = @3.0;
                const EMSTriggerBlock expectedAgendaTriggerBlock1 = ^{
                };

                NSString *const expectedAgendaTag2 = @"tag2";
                const double expectedAgendaDelay2 = 24.0;
                NSNumber *const expectedAgendaInterval2 = nil;
                const EMSTriggerBlock expectedAgendaTriggerBlock2 = ^{
                };

                [scheduler scheduleTriggerWithTag:expectedAgendaTag1
                                            delay:expectedAgendaDelay1
                                         interval:expectedAgendaInterval1
                                     triggerBlock:expectedAgendaTriggerBlock1];

                [scheduler scheduleTriggerWithTag:expectedAgendaTag2
                                            delay:expectedAgendaDelay2
                                         interval:expectedAgendaInterval2
                                     triggerBlock:expectedAgendaTriggerBlock2];

                EMSAgenda *agenda1 = scheduler.scheduledAgendas[expectedAgendaTag1];
                [[agenda1 shouldNot] beNil];
                [[agenda1.tag should] equal:expectedAgendaTag1];
                [[theValue(agenda1.delay) should] equal:theValue(expectedAgendaDelay1)];
                [[theValue(agenda1.interval) should] equal:theValue(expectedAgendaInterval1)];
                [[agenda1.triggerBlock should] equal:expectedAgendaTriggerBlock1];
                [[theValue(agenda1.dispatchTimer) shouldNot] beNil];

                EMSAgenda *agenda2 = scheduler.scheduledAgendas[expectedAgendaTag2];
                [[agenda2 shouldNot] beNil];
                [[agenda2.tag should] equal:expectedAgendaTag2];
                [[theValue(agenda2.delay) should] equal:theValue(expectedAgendaDelay2)];
                [[theValue(agenda2.interval) should] equal:theValue(expectedAgendaInterval2)];
                [[agenda2.triggerBlock should] equal:expectedAgendaTriggerBlock2];
                [[theValue(agenda2.dispatchTimer) shouldNot] beNil];
            });

            it(@"should update agenda after trigger scheduled with an already scheduled tag", ^{
                NSString *const expectedAgendaTag1 = @"tag1";
                const double expectedAgendaDelay1 = 42.0;
                NSNumber *const expectedAgendaInterval1 = @3.0;
                const EMSTriggerBlock expectedAgendaTriggerBlock1 = ^{
                };

                NSString *const expectedAgendaTag2 = @"tag1";
                const double expectedAgendaDelay2 = 24.0;
                NSNumber *const expectedAgendaInterval2 = nil;
                const EMSTriggerBlock expectedAgendaTriggerBlock2 = ^{
                };

                [scheduler scheduleTriggerWithTag:expectedAgendaTag1
                                            delay:expectedAgendaDelay1
                                         interval:expectedAgendaInterval1
                                     triggerBlock:expectedAgendaTriggerBlock1];

                EMSAgenda *agenda1 = scheduler.scheduledAgendas[expectedAgendaTag1];
                [[agenda1 shouldNot] beNil];
                [[agenda1.tag should] equal:expectedAgendaTag1];
                [[theValue(agenda1.delay) should] equal:theValue(expectedAgendaDelay1)];
                [[theValue(agenda1.interval) should] equal:theValue(expectedAgendaInterval1)];
                [[agenda1.triggerBlock should] equal:expectedAgendaTriggerBlock1];
                [[theValue(agenda1.dispatchTimer) shouldNot] beNil];

                [scheduler scheduleTriggerWithTag:expectedAgendaTag2
                                            delay:expectedAgendaDelay2
                                         interval:expectedAgendaInterval2
                                     triggerBlock:expectedAgendaTriggerBlock2];

                [[theValue([scheduler.scheduledAgendas count]) should] equal:theValue(1)];

                EMSAgenda *agenda2 = scheduler.scheduledAgendas[expectedAgendaTag2];
                [[agenda2 shouldNot] beNil];
                [[agenda2.tag should] equal:expectedAgendaTag2];
                [[theValue(agenda2.delay) should] equal:theValue(expectedAgendaDelay2)];
                [[theValue(agenda2.interval) should] equal:theValue(expectedAgendaInterval2)];
                [[agenda2.triggerBlock should] equal:expectedAgendaTriggerBlock2];
                [[theValue(agenda2.dispatchTimer) shouldNot] beNil];
            });

            it(@"should invoke triggerBlock", ^{
                __block BOOL success = NO;

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForExpectation"];

                [scheduler scheduleTriggerWithTag:@"tag"
                                            delay:delay
                                         interval:nil
                                     triggerBlock:^{
                                         success = YES;
                                         [exp fulfill];
                                     }];

                [EMSWaiter waitForExpectations:@[exp]
                                       timeout:5.0];

                [[theValue(success) should] beYes];
            });

            it(@"should invoke triggerBlock multiple times", ^{
                __block int triggerCount = 0;

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForExpectation"];
                [exp setExpectedFulfillmentCount:3];

                [scheduler scheduleTriggerWithTag:@"tag"
                                            delay:delay
                                         interval:@1.0
                                     triggerBlock:^{
                                         triggerCount++;
                                         [exp fulfill];
                                     }];

                [EMSWaiter waitForExpectations:@[exp]
                                       timeout:10.0];

                [[theValue(triggerCount) should] equal:theValue(3)];
            });

            it(@"should invoke multiple triggerBlocks", ^{
                __block BOOL successTag1 = NO;
                __block BOOL successTag2 = NO;

                XCTestExpectation *exp1 = [[XCTestExpectation alloc] initWithDescription:@"waitForTrigger1"];
                XCTestExpectation *exp2 = [[XCTestExpectation alloc] initWithDescription:@"waitForTrigger2"];

                [scheduler scheduleTriggerWithTag:@"tag1"
                                            delay:delay
                                         interval:nil
                                     triggerBlock:^{
                                         successTag1 = YES;
                                         [exp1 fulfill];
                                     }];

                [scheduler scheduleTriggerWithTag:@"tag2"
                                            delay:delay
                                         interval:nil
                                     triggerBlock:^{
                                         successTag2 = YES;
                                         [exp2 fulfill];
                                     }];

                [EMSWaiter waitForExpectations:@[exp1, exp2]
                                       timeout:10.0];

                [[theValue(successTag1) should] beYes];
                [[theValue(successTag2) should] beYes];
            });

            it(@"should invoke multiple triggerBlocks multiple times", ^{
                __block int triggerCountTag1 = 0;
                __block int triggerCountTag2 = 0;

                XCTestExpectation *exp1 = [[XCTestExpectation alloc] initWithDescription:@"waitForTrigger1"];
                [exp1 setExpectedFulfillmentCount:3];
                XCTestExpectation *exp2 = [[XCTestExpectation alloc] initWithDescription:@"waitForTrigger2"];
                [exp2 setExpectedFulfillmentCount:3];

                [scheduler scheduleTriggerWithTag:@"tag1"
                                            delay:delay
                                         interval:@1.0
                                     triggerBlock:^{
                                         triggerCountTag1++;
                                         [exp1 fulfill];
                                     }];

                [scheduler scheduleTriggerWithTag:@"tag2"
                                            delay:delay
                                         interval:@2.0
                                     triggerBlock:^{
                                         triggerCountTag2++;
                                         [exp2 fulfill];
                                     }];

                [EMSWaiter waitForExpectations:@[exp1, exp2]
                                       timeout:10.0];

                [[theValue(triggerCountTag1) should] beGreaterThan:theValue(3)];
                [[theValue(triggerCountTag2) should] equal:theValue(3)];
            });

            it(@"should modify trigger if it was scheduled already", ^{
                __block int triggerCount = 0;

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForExpectation"];
                [exp setExpectedFulfillmentCount:5];

                [scheduler scheduleTriggerWithTag:@"tag"
                                            delay:delay
                                         interval:@1.0
                                     triggerBlock:^{
                                         triggerCount++;
                                         if (triggerCount == 2) {
                                             [scheduler scheduleTriggerWithTag:@"tag"
                                                                         delay:0.1
                                                                      interval:@2.0
                                                                  triggerBlock:^{
                                                                      triggerCount++;
                                                                      [exp fulfill];
                                                                  }];
                                         }
                                         [exp fulfill];
                                     }];

                [EMSWaiter waitForTimeout:@[exp]
                                  timeout:5.0];

                [[theValue(triggerCount) should] equal:theValue(4)];
            });

            it(@"should trigger the triggerBlock on the given operationQueue", ^{
                __block int triggerCount = 0;
                __block NSOperationQueue *returnedQueue;
                NSOperationQueue *testQueue = [NSOperationQueue currentQueue];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForExpectation"];
                [scheduler scheduleTriggerWithTag:@"tag"
                                            delay:delay
                                         interval:nil
                                     triggerBlock:^{
                                         triggerCount++;
                                         returnedQueue = [NSOperationQueue currentQueue];
                                         [exp fulfill];
                                     }];

                [EMSWaiter waitForExpectations:@[exp]
                                       timeout:10.0];

                [[theValue(triggerCount) should] equal:theValue(1)];
                [[returnedQueue shouldNot] equal:testQueue];
                [[returnedQueue should] equal:queue];
            });
        });

        describe(@"cancelTriggerWithTag:", ^{

            it(@"should not invoke triggerBlock after trigger has been cancelled", ^{
                __block int triggerCount = 0;

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForExpectation"];
                [exp setExpectedFulfillmentCount:3];

                [scheduler scheduleTriggerWithTag:@"tag"
                                            delay:delay
                                         interval:@1.0
                                     triggerBlock:^{
                                         triggerCount++;
                                         if (triggerCount == 2) {
                                             [scheduler cancelTriggerWithTag:@"tag"];
                                         }
                                         [exp fulfill];
                                     }];

                [EMSWaiter waitForTimeout:@[exp]
                                  timeout:5.0];

                [[theValue(triggerCount) should] equal:theValue(2)];
            });

            it(@"should remove agenda from scheduledAgendas after trigger has been cancelled", ^{
                [scheduler scheduleTriggerWithTag:@"tag"
                                            delay:delay
                                         interval:@1.0
                                     triggerBlock:^{
                                     }];

                [[theValue([scheduler.scheduledAgendas count]) should] equal:theValue(1)];

                [scheduler cancelTriggerWithTag:@"tag"];

                [[theValue([scheduler.scheduledAgendas count]) should] equal:theValue(0)];
            });
        });

SPEC_END
