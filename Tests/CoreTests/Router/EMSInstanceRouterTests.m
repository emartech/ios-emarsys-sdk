//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSInstanceRouter.h"
#import "EMSLoggingMobileEngageInternal.h"
#import "EMSMobileEngageV3Internal.h"
#import "EMSInnerFeature.h"
#import "MEExperimental.h"

@interface EMSInstanceRouterTests : XCTestCase

@property(nonatomic, strong) RouterLogicBlock mobileEngageRouterLogicBlock;
@property(nonatomic, strong) EMSLoggingMobileEngageInternal *mockLoggingMEInternal;
@property(nonatomic, strong) EMSMobileEngageV3Internal *mockDefaultMEInternal;

@end

@implementation EMSInstanceRouterTests

- (void)setUp {
    self.mockLoggingMEInternal = OCMClassMock([EMSLoggingMobileEngageInternal class]);
    self.mockDefaultMEInternal = OCMClassMock([EMSMobileEngageV3Internal class]);
    self.mobileEngageRouterLogicBlock = ^BOOL {
        return [MEExperimental isFeatureEnabled:[EMSInnerFeature mobileEngage]];
    };
}

- (void)testInit_defaultInstance_shouldNotBeNil {
    @try {
        [[EMSInstanceRouter alloc] initWithDefaultInstance:nil
                                                                       loggingInstance:self.mockLoggingMEInternal
                                                                           routerLogic:self.mobileEngageRouterLogicBlock];
        XCTFail(@"Expected Exception when defaultInstance is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: defaultInstance");
    }
}

- (void)testInit_loggingInstance_shouldNotBeNil {
    @try {
        [[EMSInstanceRouter alloc] initWithDefaultInstance:self.mockDefaultMEInternal
                                                                       loggingInstance:nil
                                                                           routerLogic:self.mobileEngageRouterLogicBlock];
        XCTFail(@"Expected Exception when loggingInstance is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: loggingInstance");
    }
}

- (void)testInit_routerLogic_shouldNotBeNil {
    @try {
        [[EMSInstanceRouter alloc] initWithDefaultInstance:self.mockDefaultMEInternal
                                                                       loggingInstance:self.mockLoggingMEInternal
                                                                           routerLogic:nil];
        XCTFail(@"Expected Exception when routerLogic is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: routerLogic");
    }
}

- (void)testInstance_shouldReturnDefaultInstance {
    EMSInstanceRouter *router = [[EMSInstanceRouter alloc] initWithDefaultInstance:self.mockDefaultMEInternal
                                                                   loggingInstance:self.mockLoggingMEInternal
                                                                       routerLogic:^BOOL {
                                                                           return YES;
                                                                       }];

    EMSMobileEngageV3Internal *result = [router instance];

    XCTAssertEqualObjects(result, self.mockDefaultMEInternal);
}

- (void)testInstance_shouldReturnLoggingInstance {
    EMSInstanceRouter *router = [[EMSInstanceRouter alloc] initWithDefaultInstance:self.mockDefaultMEInternal
                                                                   loggingInstance:self.mockLoggingMEInternal
                                                                       routerLogic:^BOOL {
                                                                           return NO;
                                                                       }];

    EMSLoggingMobileEngageInternal *result = [router instance];

    XCTAssertEqualObjects(result, self.mockLoggingMEInternal);
}


@end
