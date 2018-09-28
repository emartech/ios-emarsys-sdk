#import "Kiwi.h"
#import "MEIAMTriggerMEEvent.h"
#import "EMSWaiter.h"
#import "Emarsys.h"

SPEC_BEGIN(MEIAMTriggerMEEventTests)

        beforeEach(^{
        });

        describe(@"commandName", ^{

            it(@"should return 'triggerMEEvent'", ^{
                [[[MEIAMTriggerMEEvent commandName] should] equal:@"triggerMEEvent"];
            });

        });

        describe(@"handleMessage:resultBlock:", ^{

            it(@"should return false if there is no name", ^{
                MEIAMTriggerMEEvent *appEvent = [MEIAMTriggerMEEvent new];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                __block NSDictionary<NSString *, NSObject *> *returnedResult;

                [appEvent handleMessage:@{@"id": @"999"}
                            resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                                returnedResult = result;
                                [exp fulfill];
                            }];
                [EMSWaiter waitForExpectations:@[exp] timeout:30];
                [[returnedResult should] equal:@{@"success": @NO, @"id": @"999", @"errors": @[@"Missing 'name' key with type: NSString."]}];
            });

            it(@"should return false if there name is wrong type", ^{
                MEIAMTriggerMEEvent *appEvent = [MEIAMTriggerMEEvent new];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                __block NSDictionary<NSString *, NSObject *> *returnedResult;

                NSDictionary *nameValue = @{};
                [appEvent handleMessage:@{@"id": @"999", @"name": nameValue}
                            resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                                returnedResult = result;
                                [exp fulfill];
                            }];
                [EMSWaiter waitForExpectations:@[exp] timeout:30];
                [[returnedResult should] equal:@{
                        @"success": @NO,
                        @"id": @"999",
                        @"errors": @[[NSString stringWithFormat:@"Type mismatch for key 'name', expected type: NSString, but was: %@.", NSStringFromClass([nameValue class])]]}];
            });

            it(@"should call the trackCustomEvent method on the MobileEngage and return with the ME eventId in the resultBlock", ^{
                MEIAMTriggerMEEvent *appEvent = [MEIAMTriggerMEEvent new];

                [[Emarsys should] receive:@selector(trackCustomEventWithName:eventAttributes:completionBlock:)
                            withArguments:@"nameOfTheEvent", kw_any(), kw_any()];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                __block NSDictionary<NSString *, NSObject *> *returnedResult;

                [appEvent handleMessage:@{
                                @"id": @"997",
                                @"name": @"nameOfTheEvent"
                        }
                            resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                                returnedResult = result;
                                [exp fulfill];
                            }];
                [EMSWaiter waitForExpectations:@[exp] timeout:30];
                [[returnedResult should] equal:@{
                        @"success": @YES,
                        @"id": @"997"
                }];
            });

            it(@"should call the trackCustomEvent method on the MobileEngage with payload and return with the ME eventId in the resultBlock", ^{
                MEIAMTriggerMEEvent *appEvent = [MEIAMTriggerMEEvent new];
                NSDictionary <NSString *, NSObject *> *payload = @{
                        @"payloadKey1": @{
                                @"payloadKey2": @"payloadValue"
                        }
                };

                [[Emarsys should] receive:@selector(trackCustomEventWithName:eventAttributes:completionBlock:)
                            withArguments:@"nameOfTheEvent", payload, kw_any()];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                __block NSDictionary<NSString *, NSObject *> *returnedResult;

                [appEvent handleMessage:@{
                                @"id": @"997",
                                @"name": @"nameOfTheEvent",
                                @"payload": payload
                        }
                            resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                                returnedResult = result;
                                [exp fulfill];
                            }];
                [EMSWaiter waitForExpectations:@[exp] timeout:30];
                [[returnedResult should] equal:@{
                        @"success": @YES,
                        @"id": @"997"
                }];
            });

        });

SPEC_END