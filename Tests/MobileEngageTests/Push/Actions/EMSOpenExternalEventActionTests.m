//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSOpenExternalUrlAction.h"

@interface EMSOpenExternalEventActionTests : XCTestCase

@property(nonatomic, strong) id mockApplication;

@end

@implementation EMSOpenExternalEventActionTests

- (void)setUp {
    _mockApplication = OCMClassMock([UIApplication class]);
}

- (void)tearDown {
    [self.mockApplication stopMocking];
    [super tearDown];
}

- (void)testInit_action_mustNotBeNil {
    @try {
        [[EMSOpenExternalUrlAction alloc] initWithActionDictionary:nil
                                                       application:self.mockApplication];
        XCTFail(@"Expected Exception when action is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: action");
    }
}

- (void)testInit_application_mustNotBeNil {
    @try {
        [[EMSOpenExternalUrlAction alloc] initWithActionDictionary:@{}
                                                       application:nil];
        XCTFail(@"Expected Exception when application is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: application");
    }
}

- (void)testExecute {
    EMSOpenExternalUrlAction *action = [[EMSOpenExternalUrlAction alloc] initWithActionDictionary:@{
            @"id": @"uniqueId",
            @"title": @"actionTitle",
            @"type": @"OpenExternalUrl",
            @"url": @"https://www.emarsys.com"
        }
                                                                                      application:self.mockApplication];

    [action execute];

    OCMVerify([self.mockApplication openURL:[[NSURL alloc] initWithString:@"https://www.emarsys.com"]
                                    options:@{}
                          completionHandler:nil]);
}

- (void)testExecute_withNilUrl {
    OCMReject([self.mockApplication openURL:[OCMArg any]
                                    options:@{}
                          completionHandler:nil]);

    EMSOpenExternalUrlAction *action = [[EMSOpenExternalUrlAction alloc] initWithActionDictionary:@{
            @"id": @"uniqueId",
            @"title": @"actionTitle",
            @"type": @"OpenExternalUrl"
        }
                                                                                      application:self.mockApplication];

    [action execute];
}

@end
