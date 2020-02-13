//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSMobileEngageProtocol.h"
#import "EMSCustomEventAction.h"

@interface EMSCustomEventActionTests : XCTestCase

@property(nonatomic, strong) id mockMobileEngage;

@end

@implementation EMSCustomEventActionTests

- (void)setUp {
    _mockMobileEngage = OCMProtocolMock(@protocol(EMSMobileEngageProtocol));
}

- (void)testInit_action_mustNotBeNil {
    @try {
        [[EMSCustomEventAction alloc] initWithAction:nil
                                        mobileEngage:self.mockMobileEngage];
        XCTFail(@"Expected Exception when action is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: action");
    }
}

- (void)testInit_mobileEngage_mustNotBeNil {
    @try {
        [[EMSCustomEventAction alloc] initWithAction:@{}
                                        mobileEngage:nil];
        XCTFail(@"Expected Exception when mobileEngage is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: mobileEngage");
    }
}

- (void)testExecute_shouldCallMobileEngage_withPayload {
    NSDictionary *expectedPayload = @{
            @"testKey1": @"testValue1",
            @"testKey2": @"testValue2"
    };

    NSDictionary *actionDictionary = @{
            @"type": @"MECustomEvent",
            @"name": @"testName",
            @"payload": expectedPayload
    };

    EMSCustomEventAction *customEventAction = [[EMSCustomEventAction alloc] initWithAction:actionDictionary
                                                                              mobileEngage:self.mockMobileEngage];
    [customEventAction execute];

    OCMVerify([self.mockMobileEngage trackCustomEventWithName:@"testName"
                                              eventAttributes:expectedPayload
                                              completionBlock:nil]);
}

- (void)testExecute_shouldCallMobileEngage_whenPayloadIsNil {
    NSDictionary *actionDictionary = @{
            @"type": @"MECustomEvent",
            @"name": @"testName"
    };

    EMSCustomEventAction *customEventAction = [[EMSCustomEventAction alloc] initWithAction:actionDictionary
                                                                              mobileEngage:self.mockMobileEngage];
    [customEventAction execute];

    OCMVerify([self.mockMobileEngage trackCustomEventWithName:@"testName"
                                              eventAttributes:nil
                                              completionBlock:nil]);
}


@end
