//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSActionFactory.h"
#import "EMSBadgeCountAction.h"
#import "EMSAppEventAction.h"
#import "EMSOpenExternalEventAction.h"
#import "EMSCustomEventAction.h"

@interface EMSActionFactoryTests : XCTestCase

@property(nonatomic, strong) EMSActionFactory *factory;

@end

@implementation EMSActionFactoryTests

- (void)setUp {
    _factory = [[EMSActionFactory alloc] init];
}

- (void)testCreateActionWithActionDictionary_shouldNotCreateBadgeCountAction_whenTypeIsBadgeCount_necessaryFieldsAreMissing {
    NSDictionary *actionDictionary = @{
            @"type": @"badgeCount"
    };

    id<EMSActionProtocol> action = [self.factory createActionWithActionDictionary:actionDictionary];

    XCTAssertNil(action);
}

- (void)testCreateActionWithActionDictionary_shouldCreateBadgeCountAction_whenMethodAndValueIsAvailable {
    NSDictionary *actionDictionary = @{
            @"type": @"badgeCount",
            @"method": @"SET",
            @"value": @123
    };

    id<EMSActionProtocol> action = [self.factory createActionWithActionDictionary:actionDictionary];

    XCTAssertTrue([action isKindOfClass:[EMSBadgeCountAction class]]);
}

- (void)testCreateActionWithActionDictionary_shouldNotCreateAppEventAction_whenTypeIsMEAppEvent_necessaryFieldsAreMissing {
    NSDictionary *actionDictionary = @{
            @"type": @"MEAppEvent"
    };

    id<EMSActionProtocol> action = [self.factory createActionWithActionDictionary:actionDictionary];

    XCTAssertNil(action);
}

- (void)testCreateActionWithActionDictionary_shouldCreateAppEventAction_whenNameIsAvailable {
    NSDictionary *actionDictionary = @{
            @"type": @"MEAppEvent",
            @"name" : @"testName"
    };

    id<EMSActionProtocol> action = [self.factory createActionWithActionDictionary:actionDictionary];

    XCTAssertTrue([action isKindOfClass:[EMSAppEventAction class]]);
}

- (void)testCreateActionWithActionDictionary_shouldNotCreateOpenExternalEventAction_whenTypeIsOpenExternalUrl_necessaryFieldsAreMissing {
    NSDictionary *actionDictionary = @{
            @"type": @"OpenExternalEvent"
    };

    id<EMSActionProtocol> action = [self.factory createActionWithActionDictionary:actionDictionary];

    XCTAssertNil(action);
}

- (void)testCreateActionWithActionDictionary_shouldCreateOpenExternalEventAction_whenUrlIsAvailable {
    NSDictionary *actionDictionary = @{
            @"type": @"OpenExternalEvent",
            @"url": @"https://www.emarsys.com"
    };

    id<EMSActionProtocol> action = [self.factory createActionWithActionDictionary:actionDictionary];

    XCTAssertTrue([action isKindOfClass:[EMSOpenExternalEventAction class]]);
}

- (void)testCreateActionWithActionDictionary_shouldNotCreateEMSCustomEventAction_whenTypeIsMECustomEvent_necessaryFieldsAreMissing {
    NSDictionary *actionDictionary = @{
            @"type": @"MECustomEvent"
    };

    id<EMSActionProtocol> action = [self.factory createActionWithActionDictionary:actionDictionary];

    XCTAssertNil(action);
}

- (void)testCreateActionWithActionDictionary_shouldCreateEMSCustomEventAction_whenTypeIsMECustomEvent {
    NSDictionary *actionDictionary = @{
            @"type": @"MECustomEvent",
            @"name": @"testName"
    };

    id<EMSActionProtocol> action = [self.factory createActionWithActionDictionary:actionDictionary];

    XCTAssertTrue([action isKindOfClass:[EMSCustomEventAction class]]);
}

@end
