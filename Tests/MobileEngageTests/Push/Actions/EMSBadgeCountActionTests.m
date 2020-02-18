//
//  Copyright © 2020 Emarsys. All rights reserved.
//
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSBadgeCountAction.h"

@interface EMSBadgeCountActionTests : XCTestCase

@property(nonatomic, strong) id mockApplication;

@end

@implementation EMSBadgeCountActionTests

- (void)setUp {
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 3;
    _mockApplication = OCMPartialMock(application);
}

- (void)tearDown {
    [self.mockApplication stopMocking];
    [super tearDown];
}

- (void)testInit_action_mustNotBeNil {
    @try {
        [[EMSBadgeCountAction alloc] initWithActionDictionary:nil
                                                  application:self.mockApplication];
        XCTFail(@"Expected Exception when action is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: action");
    }
}

- (void)testInit_application_mustNotBeNil {
    @try {
        [[EMSBadgeCountAction alloc] initWithActionDictionary:@{}
                                                  application:nil];
        XCTFail(@"Expected Exception when application is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: application");
    }
}

- (void)testHandleMessageWithUserInfo_shouldSetBadgeNumberWhenMultipleActionsAreAvailable {
    NSDictionary *actionDictionary = @{
            @"type": @"testType",
            @"value": @123
    };

    EMSBadgeCountAction *badgeCountAction = [[EMSBadgeCountAction alloc] initWithActionDictionary:actionDictionary
                                                                                      application:self.mockApplication];

    [badgeCountAction execute];

    OCMVerify([self.mockApplication setApplicationIconBadgeNumber:123]);
    XCTAssertEqual([self.mockApplication applicationIconBadgeNumber], 123);
}

- (void)testExecute_shouldSetBadgeNumberCorrectly_whenMethodIsAdd {
    NSDictionary *actionDictionary = @{
            @"type": @"BadgeCount",
            @"method": @"ADD",
            @"value": @2
    };

    EMSBadgeCountAction *badgeCountAction = [[EMSBadgeCountAction alloc] initWithActionDictionary:actionDictionary
                                                                                      application:self.mockApplication];

    [badgeCountAction execute];

    OCMVerify([self.mockApplication setApplicationIconBadgeNumber:5]);
    XCTAssertEqual([self.mockApplication applicationIconBadgeNumber], 5);
}


- (void)testHandleMessageWithUserInfo_shouldSetBadgeNumberCorrectly_whenMethodIsAdd_withNegativeValue {
    NSDictionary *actionDictionary = @{
            @"type": @"BadgeCount",
            @"method": @"ADD",
            @"value": @-2
    };

    EMSBadgeCountAction *badgeCountAction = [[EMSBadgeCountAction alloc] initWithActionDictionary:actionDictionary
                                                                                      application:self.mockApplication];

    [badgeCountAction execute];

    OCMVerify([self.mockApplication setApplicationIconBadgeNumber:1]);
    XCTAssertEqual([self.mockApplication applicationIconBadgeNumber], 1);
}

@end
