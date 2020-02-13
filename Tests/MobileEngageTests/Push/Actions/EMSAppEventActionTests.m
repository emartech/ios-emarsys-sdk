//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSEventHandler.h"
#import "EMSAppEventAction.h"

@interface EMSAppEventActionTests : XCTestCase

@property(nonatomic, strong) id mockAppEventHandler;

@end

@implementation EMSAppEventActionTests

- (void)setUp {
    _mockAppEventHandler = OCMProtocolMock(@protocol(EMSEventHandler));
}

- (void)testInit_action_mustNotBeNil {
    @try {
        [[EMSAppEventAction alloc] initWithActionDictionary:nil
                                               eventHandler:self.mockAppEventHandler];
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
            @"payload" : expectedPayload
    };

    EMSAppEventAction *appEventAction = [[EMSAppEventAction alloc] initWithActionDictionary: actionDictionary
                                                                               eventHandler:self.mockAppEventHandler];

    [appEventAction execute];

    OCMVerify([self.mockAppEventHandler handleEvent:@"testName" payload:expectedPayload]);
}

- (void)testHandleMessageWithUserInfo_shouldHandleEventWithEventHandler_whenPayloadIsNil {
    NSDictionary *actionDictionary = @{
            @"type": @"MEAppEvent",
            @"name": @"testName"
    };

    EMSAppEventAction *appEventAction = [[EMSAppEventAction alloc] initWithActionDictionary: actionDictionary
                                                                               eventHandler:self.mockAppEventHandler];

    [appEventAction execute];

    OCMVerify([self.mockAppEventHandler handleEvent:@"testName" payload:nil]);
}

@end
