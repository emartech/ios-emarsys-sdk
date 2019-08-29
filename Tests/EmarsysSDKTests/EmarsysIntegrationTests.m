//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EmarsysTestUtils.h"
#import "NSData+MobileEngine.h"
#import "EMSDependencyInjection.h"
#import "MERequestContext.h"

typedef void (^ExecutionBlock)(EMSCompletionBlock completionBlock);

@interface EmarsysIntegrationTests : XCTestCase

@end

@implementation EmarsysIntegrationTests

- (void)setUp {
    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                       withDependencyContainer:nil];
    [EmarsysTestUtils waitForSetPushToken];
    [EmarsysTestUtils waitForSetCustomer];
}

- (void)tearDown {
    [EmarsysTestUtils tearDownEmarsys];
}

- (void)testClearContact {
    [self integrationTestWithExecutionBlock:^(EMSCompletionBlock completionBlock) {
        [Emarsys clearContactWithCompletionBlock:completionBlock];
    }];
}

- (void)testTokenRefresh {
    NSString *const contactToken = @"testContactToken for refresh";
    MERequestContext *requestContext = EMSDependencyInjection.dependencyContainer.requestContext;

    [requestContext setContactToken:contactToken];

    [self integrationTestWithExecutionBlock:^(EMSCompletionBlock completionBlock) {
        [Emarsys trackCustomEventWithName:@"testEventName"
                          eventAttributes:@{
                              @"testEventAttributesKey1": @"testEventAttributesValue1",
                              @"testEventAttributesKey2": @"testEventAttributesValue2"}
                          completionBlock:completionBlock];
    }];

    XCTAssertNotEqualObjects(requestContext.contactToken, contactToken);
}

- (void)testTrackCustomEventWithNameEventAttributes {
    [self integrationTestWithExecutionBlock:^(EMSCompletionBlock completionBlock) {
        [Emarsys trackCustomEventWithName:@"testEventName"
                          eventAttributes:@{
                              @"testEventAttributesKey1": @"testEventAttributesValue1",
                              @"testEventAttributesKey2": @"testEventAttributesValue2"}
                          completionBlock:completionBlock];
    }];
}

- (void)testSetPushToken_when_valid_clientState_contactToken_HaveSet {
    id deviceToken = OCMClassMock([NSData class]);
    OCMStub([deviceToken deviceTokenString]).andReturn(@"test_pushToken_for_iOS_integrationTest");

    [self integrationTestWithExecutionBlock:^(EMSCompletionBlock completionBlock) {
        [Emarsys.push setPushToken:deviceToken
                   completionBlock:completionBlock];
    }];

    [deviceToken stopMocking];
}

- (void)testClearPushToken {
    [self integrationTestWithExecutionBlock:^(EMSCompletionBlock completionBlock) {
        [Emarsys.push clearPushTokenWithCompletionBlock:completionBlock];
    }];
}

- (void)testTrackMessageOpenWithUserInfo {
    NSDictionary *userInfo = @{
        @"u": @"{\"sid\": \"testSID\"}"
    };

    [self integrationTestWithExecutionBlock:^(EMSCompletionBlock completionBlock) {
        [Emarsys.push trackMessageOpenWithUserInfo:userInfo
                                   completionBlock:completionBlock];
    }];
}

- (void)testTrackDeepLinkWithUserActivitySourceHandler {
    NSString *expectedSource = @"https://github.com/emartech/android-emarsys-sdk/wiki?ems_dl=210268110_ZVwwYrYUFR_1_100302293_1_2000000";
    NSString *activityType = [NSString stringWithFormat:@"%@", NSUserActivityTypeBrowsingWeb];
    NSURL *url = [[NSURL alloc] initWithString:expectedSource];
    NSUserActivity *userActivity = OCMClassMock([NSUserActivity class]);

    OCMStub([userActivity activityType]).andReturn(activityType);
    OCMStub([userActivity webpageURL]).andReturn(url);

    [self integrationTestWithExecutionBlock:^(EMSCompletionBlock completionBlock) {
        id target = EMSDependencyInjection.dependencyContainer.deepLink;
        SEL selector = @selector(trackDeepLinkWith:sourceHandler:withCompletionBlock:);

        typedef BOOL (*MethodType)(id, SEL, id, id, id);
        MethodType methodToCall = (MethodType) [target methodForSelector:selector];

        methodToCall(target, selector, userActivity, nil, completionBlock);
    }];
}

- (void)integrationTestWithExecutionBlock:(ExecutionBlock)executionBlock {
    __block NSError *returnedError = [NSError new];
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];

    executionBlock(^(NSError *error) {
        returnedError = error;
        [expectation fulfill];
    });

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
}

@end
