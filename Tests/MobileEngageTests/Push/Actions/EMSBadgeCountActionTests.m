//
//  Copyright © 2020 Emarsys. All rights reserved.
//
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSBadgeCountAction.h"
#import "XCTestCase+Helper.h"
#import <UserNotifications/UNUserNotificationCenter.h>

@interface EMSBadgeCountActionTests : XCTestCase

@property(nonatomic, strong) UIApplication *application;
@property(nonatomic, strong) UNUserNotificationCenter *userNotificationCenter;
@property(nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation EMSBadgeCountActionTests

- (void)setUp {
    _operationQueue = [self createTestOperationQueue];
    _userNotificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    _application = [UIApplication sharedApplication];
    self.application.applicationIconBadgeNumber = 3;
    [self waitForOperationOnMainQueue];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInit_action_mustNotBeNil {
    @try {
        [[EMSBadgeCountAction alloc] initWithActionDictionary:nil
                                                  application:self.application
                                       userNotificationCenter:self.userNotificationCenter
                                               operationQueue:self.operationQueue];
        XCTFail(@"Expected Exception when action is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: action");
    }
}

- (void)testInit_application_mustNotBeNil {
    @try {
        [[EMSBadgeCountAction alloc] initWithActionDictionary:@{}
                                                  application:nil
                                       userNotificationCenter:self.userNotificationCenter
                                               operationQueue:self.operationQueue];
        XCTFail(@"Expected Exception when application is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: application");
    }
}

- (void)testInit_userNotificationCenter_mustNotBeNil {
    @try {
        [[EMSBadgeCountAction alloc] initWithActionDictionary:@{}
                                                  application:self.application
                                       userNotificationCenter:nil
                                               operationQueue:self.operationQueue];
        XCTFail(@"Expected Exception when userNotificationCenter is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: userNotificationCenter");
    }
}

- (void)testInit_operationQueue_mustNotBeNil {
    @try {
        [[EMSBadgeCountAction alloc] initWithActionDictionary:@{}
                                                  application:self.application
                                       userNotificationCenter:self.userNotificationCenter
                                               operationQueue:nil];
        XCTFail(@"Expected Exception when operationQueue is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: operationQueue");
    }
}

- (void)testHandleMessageWithUserInfo_shouldSetBadgeNumberWhenMultipleActionsAreAvailable {
    NSDictionary *actionDictionary = @{
            @"type": @"testType",
            @"value": @123
    };

    EMSBadgeCountAction *badgeCountAction = [[EMSBadgeCountAction alloc] initWithActionDictionary:actionDictionary
                                                                                      application:self.application
                                                                           userNotificationCenter:self.userNotificationCenter
                                                                                   operationQueue:self.operationQueue];

    [badgeCountAction execute];
    [self waitForOperationOnMainQueue];

    XCTAssertEqual([self.application applicationIconBadgeNumber], 123);
}

- (void)testExecute_shouldSetBadgeNumberCorrectly_whenMethodIsAdd {
    NSDictionary *actionDictionary = @{
            @"type": @"BadgeCount",
            @"method": @"ADD",
            @"value": @2
    };

    EMSBadgeCountAction *badgeCountAction = [[EMSBadgeCountAction alloc] initWithActionDictionary:actionDictionary
                                                                                      application:self.application
                                                                           userNotificationCenter:self.userNotificationCenter
                                                                                   operationQueue:self.operationQueue];
    
    [badgeCountAction execute];
    [self waitForOperationOnMainQueue];

    XCTAssertEqual([self.application applicationIconBadgeNumber], 5);
}


- (void)testHandleMessageWithUserInfo_shouldSetBadgeNumberCorrectly_whenMethodIsAdd_withNegativeValue {
    NSDictionary *actionDictionary = @{
            @"type": @"BadgeCount",
            @"method": @"ADD",
            @"value": @-2
    };

    EMSBadgeCountAction *badgeCountAction = [[EMSBadgeCountAction alloc] initWithActionDictionary:actionDictionary
                                                                                      application:self.application
                                                                           userNotificationCenter:self.userNotificationCenter
                                                                                   operationQueue:self.operationQueue];

    [badgeCountAction execute];
    [self waitForOperationOnMainQueue];

    XCTAssertEqual([self.application applicationIconBadgeNumber], 1);
}

- (void)waitForOperationOnMainQueue {
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForOperationOnMainQueue"];
    [mainQueue addOperationWithBlock:^{
            [NSThread sleepForTimeInterval:0.2];
            [expectation fulfill];
        }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];
    [mainQueue waitUntilAllOperationsAreFinished];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
};

@end
