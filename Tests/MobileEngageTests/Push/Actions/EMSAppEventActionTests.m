//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSAppEventAction.h"

@interface EMSAppEventActionTests : XCTestCase

@end

@implementation EMSAppEventActionTests


- (void)testInit_action_mustNotBeNil {
    @try {
        [[EMSAppEventAction alloc] initWithActionDictionary:nil
                                               eventHandler:^(NSString *eventName, NSDictionary<NSString *, id> *payload) {
                                               }];
        XCTFail(@"Expected Exception when action is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: action");
    }
}

- (void)testInit_eventHandler_mustNotBeNil {
    @try {
        [[EMSAppEventAction alloc] initWithActionDictionary:@{}
                                               eventHandler:nil];
        XCTFail(@"Expected Exception when eventHandler is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: eventHandler");
    }
}

- (void)testHandleMessageWithUserInfo_shouldCallEventHandler {
    NSDictionary *expectedPayload = @{
            @"testKey1": @"testValue1",
            @"testKey2": @"testValue2"
    };

    NSDictionary *actionDictionary = @{
            @"type": @"MEAppEvent",
            @"name": @"testName",
            @"payload": expectedPayload
    };

    __block NSDictionary *resultPayload = nil;
    __block NSString *resultEventName = nil;
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];
    EMSAppEventAction *appEventAction = [[EMSAppEventAction alloc] initWithActionDictionary:actionDictionary
                                                                               eventHandler:^(NSString *eventName, NSDictionary<NSString *, id> *payload) {
                                                                                   resultEventName = eventName;
                                                                                   resultPayload = payload;
                                                                                   [expectation fulfill];
                                                                               }];

    [appEventAction execute];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:3];

    XCTAssertEqual(XCTWaiterResultCompleted, waiterResult);
    XCTAssertEqual(resultEventName, @"testName");
    XCTAssertEqualObjects(expectedPayload, resultPayload);
}

- (void)testHandleMessageWithUserInfo_shouldHandleEventWithEventHandler_whenPayloadIsNil {
    NSDictionary *actionDictionary = @{
            @"type": @"MEAppEvent",
            @"name": @"testName"
    };

    __block NSDictionary *result = @{};
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];
    EMSAppEventAction *appEventAction = [[EMSAppEventAction alloc] initWithActionDictionary:actionDictionary
                                                                               eventHandler:^(NSString *eventName, NSDictionary<NSString *, id> *payload) {
                                                                                   result = payload;
                                                                                   [expectation fulfill];
                                                                               }];

    [appEventAction execute];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:3];

    XCTAssertEqual(XCTWaiterResultCompleted, waiterResult);
    XCTAssertNil(result);
}

- (void)testHandleMessageWithUserInfo_shouldNotCrash_whenEventHandlerIsNil {
    NSDictionary *actionDictionary = @{
            @"type": @"MEAppEvent",
            @"name": @"testName"
    };

    EMSAppEventAction *appEventAction = [[EMSAppEventAction alloc] initWithActionDictionary:actionDictionary
                                                                               eventHandler:^(NSString *eventName, NSDictionary<NSString *, id> *payload) {
                                                                               }];
    appEventAction.eventHandler = nil;
    [appEventAction execute];
}

@end
