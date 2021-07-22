#import "Kiwi.h"
#import "MEIAMTriggerAppEvent.h"
#import "EMSWaiter.h"

SPEC_BEGIN(MEIAMTriggerAppEventTests)

        beforeEach(^{
        });

        describe(@"commandName", ^{

            it(@"should return 'triggerAppEvent'", ^{
                [[[MEIAMTriggerAppEvent commandName] should] equal:@"triggerAppEvent"];
            });

        });

        describe(@"handleMessage:resultBlock:", ^{

            it(@"should pass the eventName and payload to the given eventHandler's handleEvent:payload: method", ^{
                NSString *eventName = @"nameOfTheEvent";
                NSDictionary <NSString *, NSObject *> *payload = @{
                        @"payloadKey1": @{
                                @"payloadKey2": @"payloadValue"
                        }
                };
                NSDictionary *scriptMessage = @{
                        @"id": @1,
                        @"name": eventName,
                        @"payload": payload
                };

                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];
                __block NSString *resultName = nil;
                __block NSDictionary *resultPayload = nil;

                MEIAMTriggerAppEvent *appEvent = [[MEIAMTriggerAppEvent alloc] initWithEventHandler:^(NSString *eventName, NSDictionary<NSString *, id> *payload) {
                    resultName = eventName;
                    resultPayload = payload;
                    [expectation fulfill];
                }];

                [appEvent handleMessage:scriptMessage
                            resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                            }];
                XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                                      timeout:15];

                XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
                XCTAssertEqualObjects(resultName, eventName);
                XCTAssertEqualObjects(resultPayload, payload);
            });

            it(@"should return false if there is no name", ^{
                MEIAMTriggerAppEvent *appEvent = [MEIAMTriggerAppEvent new];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                __block NSDictionary<NSString *, NSObject *> *returnedResult;

                [appEvent handleMessage:@{@"id": @"999"}
                            resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                                returnedResult = result;
                                [exp fulfill];
                            }];
                [EMSWaiter waitForExpectations:@[exp]
                                       timeout:30];

                [[returnedResult should] equal:@{@"success": @NO, @"id": @"999", @"errors": @[@"Missing 'name' key with type: NSString."]}];

            });

            it(@"should receive success in resultBlock", ^{
                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                XCTestExpectation *exp2 = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];

                MEIAMTriggerAppEvent *appEvent =
                        [[MEIAMTriggerAppEvent alloc] initWithEventHandler:^(NSString *eventName, NSDictionary<NSString *, id> *payload) {
                            [exp2 fulfill];
                        }];

                __block NSDictionary<NSString *, NSObject *> *returnedResult;
                [appEvent handleMessage:@{@"name": @"name", @"id": @"123"}
                            resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                                returnedResult = result;
                                [exp fulfill];
                            }];
                [EMSWaiter waitForExpectations:@[exp, exp2]
                                       timeout:30];

                [[returnedResult should] equal:@{@"success": @YES, @"id": @"123"}];
            });

            it(@"should receive failure in resultBlock, when there is no name", ^{
                MEIAMTriggerAppEvent *appEvent = [MEIAMTriggerAppEvent new];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                __block NSDictionary<NSString *, NSObject *> *returnedResult;
                [appEvent handleMessage:@{@"id": @"123"}
                            resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                                returnedResult = result;
                                [exp fulfill];
                            }];
                [EMSWaiter waitForExpectations:@[exp]
                                       timeout:30];

                [[returnedResult should] equal:@{@"success": @NO, @"id": @"123", @"errors": @[@"Missing 'name' key with type: NSString."]}];
            });

            it(@"should receive failure in resultBlock, when name is wrong type", ^{
                MEIAMTriggerAppEvent *appEvent = [MEIAMTriggerAppEvent new];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                __block NSDictionary<NSString *, NSObject *> *returnedResult;
                NSArray *nameValue = @[];
                [appEvent handleMessage:@{@"id": @"123", @"name": nameValue}
                            resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                                returnedResult = result;
                                [exp fulfill];
                            }];
                [EMSWaiter waitForExpectations:@[exp]
                                       timeout:30];

                [[returnedResult should] equal:@{
                        @"success": @NO,
                        @"id": @"123",
                        @"errors": @[[NSString stringWithFormat:@"Type mismatch for key 'name', expected type: NSString, but was: %@.",
                                                                NSStringFromClass([nameValue class])]]}];
            });

            it(@"should call the given eventHandler's handleEvent:payload: method on main thread", ^{
                NSString *eventName = @"nameOfTheEvent";
                NSDictionary <NSString *, NSObject *> *payload = @{
                        @"payloadKey1": @{
                                @"payloadKey2": @"payloadValue"
                        }
                };
                NSDictionary *scriptMessage = @{
                        @"id": @1,
                        @"name": eventName,
                        @"payload": payload
                };

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];
                XCTestExpectation *exp2 = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];

                __block NSOperationQueue *returnedQueue = nil;

                MEIAMTriggerAppEvent *appEvent =
                        [[MEIAMTriggerAppEvent alloc] initWithEventHandler:^(NSString *eventName, NSDictionary<NSString *, id> *payload) {
                            returnedQueue = [NSOperationQueue currentQueue];
                            [exp fulfill];
                        }];

                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [appEvent handleMessage:scriptMessage
                                resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                                    [exp2 fulfill];
                                }];
                });

                XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[exp, exp2]
                                                                      timeout:15];

                XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
                XCTAssertEqualObjects(returnedQueue, [NSOperationQueue mainQueue]);
            });

        });

SPEC_END



