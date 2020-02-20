//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "EMSActionFactory.h"
#import "EMSBadgeCountAction.h"
#import "EMSAppEventAction.h"
#import "EMSOpenExternalUrlAction.h"
#import "EMSCustomEventAction.h"

@interface EMSActionFactoryTests : XCTestCase

@property(nonatomic, strong) EMSActionFactory *factory;
@property(nonatomic, strong) id mockMobileEngage;
@property(nonatomic, strong) id mockApplication;
@property(nonatomic, strong) id mockEventHandler;

@end

@implementation EMSActionFactoryTests

- (void)setUp {
    _mockMobileEngage = OCMProtocolMock(@protocol(EMSMobileEngageProtocol));
    _mockApplication = OCMClassMock([UIApplication class]);
    _mockEventHandler = OCMProtocolMock(@protocol(EMSEventHandler));
    _factory = [[EMSActionFactory alloc] initWithApplication:self.mockApplication
                                                mobileEngage:self.mockMobileEngage];
}

- (void)tearDown {
    [self.mockApplication stopMocking];
    [super tearDown];
}

- (void)testInit_application_mustNotBeNil {
    @try {
        [[EMSActionFactory alloc] initWithApplication:nil
                                         mobileEngage:self.mockMobileEngage];
        XCTFail(@"Expected Exception when application is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: application");
    }
}

- (void)testInit_mobileEngage_mustNotBeNil {
    @try {
        [[EMSActionFactory alloc] initWithApplication:self.mockApplication
                                         mobileEngage:nil];
        XCTFail(@"Expected Exception when mobileEngage is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: mobileEngage");
    }
}

- (void)testCreateActionWithActionDictionary_shouldNotCreateBadgeCountAction_whenTypeIsBadgeCount_necessaryFieldsAreMissing {
    NSDictionary *actionDictionary = @{
            @"type": @"BadgeCount"
    };

    id <EMSActionProtocol> action = [self.factory createActionWithActionDictionary:actionDictionary];

    XCTAssertNil(action);
}

- (void)testCreateActionWithActionDictionary_shouldCreateBadgeCountAction_whenMethodAndValueIsAvailable {
    NSDictionary *actionDictionary = @{
            @"type": @"BadgeCount",
            @"method": @"SET",
            @"value": @123
    };

    id <EMSActionProtocol> action = [self.factory createActionWithActionDictionary:actionDictionary];

    XCTAssertTrue([action isKindOfClass:[EMSBadgeCountAction class]]);
}

- (void)testCreateActionWithActionDictionary_shouldNotCreateAppEventAction_whenTypeIsMEAppEvent_necessaryFieldsAreMissing {
    NSDictionary *actionDictionary = @{
            @"type": @"MEAppEvent"
    };

    [self.factory setEventHandler:self.mockEventHandler];
    id <EMSActionProtocol> action = [self.factory createActionWithActionDictionary:actionDictionary];

    XCTAssertNil(action);
}

- (void)testCreateActionWithActionDictionary_shouldNotCreateAppEventAction_whenEventHandlerIsMissing {
    NSDictionary *actionDictionary = @{
            @"type": @"MEAppEvent",
            @"name": @"testName"
    };

    id <EMSActionProtocol> action = [self.factory createActionWithActionDictionary:actionDictionary];

    XCTAssertNil(action);
}

- (void)testCreateActionWithActionDictionary_shouldCreateAppEventAction_whenNameAndEventHandlerAreAvailable {
    NSDictionary *actionDictionary = @{
            @"type": @"MEAppEvent",
            @"name": @"testName"
    };

    [self.factory setEventHandler:self.mockEventHandler];
    id <EMSActionProtocol> action = [self.factory createActionWithActionDictionary:actionDictionary];

    XCTAssertTrue([action isKindOfClass:[EMSAppEventAction class]]);
}

- (void)testCreateActionWithActionDictionary_shouldNotCreateOpenExternalEventAction_whenTypeIsOpenExternalUrl_necessaryFieldsAreMissing {
    NSDictionary *actionDictionary = @{
            @"type": @"OpenExternalUrl"
    };

    id <EMSActionProtocol> action = [self.factory createActionWithActionDictionary:actionDictionary];

    XCTAssertNil(action);
}

- (void)testCreateActionWithActionDictionary_shouldCreateOpenExternalEventAction_whenUrlIsAvailable {
    NSDictionary *actionDictionary = @{
            @"type": @"OpenExternalUrl",
            @"url": @"https://www.emarsys.com"
    };

    id <EMSActionProtocol> action = [self.factory createActionWithActionDictionary:actionDictionary];

    XCTAssertTrue([action isKindOfClass:[EMSOpenExternalUrlAction class]]);
}

- (void)testCreateActionWithActionDictionary_shouldNotCreateEMSCustomEventAction_whenTypeIsMECustomEvent_necessaryFieldsAreMissing {
    NSDictionary *actionDictionary = @{
            @"type": @"MECustomEvent"
    };

    id <EMSActionProtocol> action = [self.factory createActionWithActionDictionary:actionDictionary];

    XCTAssertNil(action);
}

- (void)testCreateActionWithActionDictionary_shouldCreateEMSCustomEventAction_whenTypeIsMECustomEvent {
    NSDictionary *actionDictionary = @{
            @"type": @"MECustomEvent",
            @"name": @"testName"
    };

    id <EMSActionProtocol> action = [self.factory createActionWithActionDictionary:actionDictionary];

    XCTAssertTrue([action isKindOfClass:[EMSCustomEventAction class]]);
}

@end
