//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSSession.h"
#import "EMSRequestFactory.h"
#import "EMSRequestManager.h"
#import "EMSTimestampProvider.h"
#import "NSDate+EMSCore.h"
#import "XCTestCase+Helper.h"
#import "EmarsysTestUtils.h"
#import "MEExperimental.h"
#import "EMSInnerFeature.h"

@interface EMSSessionTests : XCTestCase

@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;
@property(nonatomic, strong) EMSTimestampProvider *mockTimestampProvider;
@property(nonatomic, strong) NSOperationQueue *operationQueue;
@property(nonatomic, strong) EMSSessionIdHolder *sessionIdHolder;
@property(nonatomic, strong) EMSSession *session;

@end

@implementation EMSSessionTests

- (void)setUp {
    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    _mockTimestampProvider = OCMClassMock([EMSTimestampProvider class]);
    _sessionIdHolder = [EMSSessionIdHolder new];
    _operationQueue = [self createTestOperationQueue];
    _session = [[EMSSession alloc] initWithSessionIdHolder:self.sessionIdHolder
                                            requestManager:self.mockRequestManager
                                            requestFactory:self.mockRequestFactory
                                            operationQueue:self.operationQueue
                                         timestampProvider:self.mockTimestampProvider];
}

- (void)tearDown {
    [EmarsysTestUtils tearDownOperationQueue:self.operationQueue];
}

- (void)testInit_sessionIdHolder_mustNotBeNil {
    @try {
        [[EMSSession alloc] initWithSessionIdHolder:nil
                                     requestManager:self.mockRequestManager
                                     requestFactory:self.mockRequestFactory
                                     operationQueue:self.operationQueue
                                  timestampProvider:self.mockTimestampProvider];
        XCTFail(@"Expected Exception when sessionIdHolde is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: sessionIdHolder");
    }
}

- (void)testInit_requestFactory_mustNotBeNil {
    @try {
        [[EMSSession alloc] initWithSessionIdHolder:self.sessionIdHolder
                                     requestManager:self.mockRequestManager
                                     requestFactory:nil
                                     operationQueue:self.operationQueue
                                  timestampProvider:self.mockTimestampProvider];
        XCTFail(@"Expected Exception when requestFactory is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestFactory");
    }
}

- (void)testInit_operationQueue_mustNotBeNil {
    @try {
        [[EMSSession alloc] initWithSessionIdHolder:self.sessionIdHolder
                                     requestManager:self.mockRequestManager
                                     requestFactory:self.mockRequestFactory
                                     operationQueue:nil
                                  timestampProvider:self.mockTimestampProvider];
        XCTFail(@"Expected Exception when operationQueue is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: operationQueue");
    }
}

- (void)testInit_requestManager_mustNotBeNil {
    @try {
        [[EMSSession alloc] initWithSessionIdHolder:self.sessionIdHolder
                                     requestManager:nil
                                     requestFactory:self.mockRequestFactory
                                     operationQueue:self.operationQueue
                                  timestampProvider:self.mockTimestampProvider];
        XCTFail(@"Expected Exception when requestManager is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestManager");
    }
}

- (void)testInit_timestampProvider_mustNotBeNil {
    @try {
        [[EMSSession alloc] initWithSessionIdHolder:self.sessionIdHolder
                                     requestManager:self.mockRequestManager
                                     requestFactory:self.mockRequestFactory
                                     operationQueue:self.operationQueue
                                  timestampProvider:nil];
        XCTFail(@"Expected Exception when timestampProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: timestampProvider");
    }
}

- (void)testStartSession_shouldGenerateSessionId {
    [self.session startSessionWithCompletionBlock:nil];

    [self waitATickOnOperationQueue:self.operationQueue];
    
    XCTAssertNotNil(self.session.sessionIdHolder.sessionId);
}

- (void)testStartSession_shouldSetSessionStartTime {
    NSDate *sessionStartTime = [NSDate date];

    OCMStub([self.mockTimestampProvider provideTimestamp]).andReturn(sessionStartTime);

    [self.session startSessionWithCompletionBlock:nil];
    
    [self waitATickOnOperationQueue:self.operationQueue];

    XCTAssertEqualObjects(self.session.sessionStartTime, sessionStartTime);
}

- (void)testStartSession_shouldSendSessionStartEvent {
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);

    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:@"session:start"
                                                          eventAttributes:nil
                                                                eventType:EventTypeInternal]).andReturn(mockRequestModel);
    [self.session startSessionWithCompletionBlock:nil];
    
    [self waitATickOnOperationQueue:self.operationQueue];

    OCMVerify([self.mockRequestManager submitRequestModel:mockRequestModel
                                      withCompletionBlock:nil]);
}

- (void)testDidBecomeActiveNotification_shouldInvokeStartSession {
    [MEExperimental enableFeature:[EMSInnerFeature mobileEngage]];
    XCTestExpectation *expectation = [self expectationForNotification:UIApplicationDidBecomeActiveNotification
                                                               object:nil
                                                              handler:^BOOL(NSNotification * _Nonnull notification) {
        return YES;
    }];
    EMSSession *partialMockSession = OCMPartialMock(self.session);

    [NSNotificationCenter.defaultCenter postNotification:[NSNotification notificationWithName:UIApplicationDidBecomeActiveNotification
                                                                                       object:nil]];
    OCMVerify([partialMockSession startSessionWithCompletionBlock:nil]);

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2.0];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
}

- (void)testDidBecomeActiveNotification_shouldNotInvokeStartSession_whenMobileEngageIsDisabled {
    [MEExperimental disableFeature:[EMSInnerFeature mobileEngage]];
    XCTestExpectation *expectation = [self expectationForNotification:UIApplicationDidBecomeActiveNotification
                                                               object:nil
                                                              handler:^BOOL(NSNotification * _Nonnull notification) {
        return YES;
    }];
    EMSSession *partialMockSession = OCMPartialMock(self.session);

    [NSNotificationCenter.defaultCenter postNotification:[NSNotification notificationWithName:UIApplicationDidBecomeActiveNotification
                                                                                       object:nil]];
    OCMVerify(never(), [partialMockSession startSessionWithCompletionBlock:nil]);

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2.0];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
}

- (void)testDidEnterBackgroundNotification_shouldInvokeStopSession {
    [MEExperimental enableFeature:[EMSInnerFeature mobileEngage]];
    XCTestExpectation *expectation = [self expectationForNotification:UIApplicationDidEnterBackgroundNotification
                                                               object:nil
                                                              handler:^BOOL(NSNotification * _Nonnull notification) {
        return YES;
    }];
    EMSSession *partialMockSession = OCMPartialMock(self.session);
    
    [NSNotificationCenter.defaultCenter postNotification:[NSNotification notificationWithName:UIApplicationDidEnterBackgroundNotification
                                                                                       object:nil]];
    OCMVerify([partialMockSession stopSessionWithCompletionBlock:nil]);

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2.0];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
}

- (void)testDidEnterBackgroundNotification_shouldNotInvokeStopSession_whenMobileEngageIsDisabled {
    [MEExperimental disableFeature:[EMSInnerFeature mobileEngage]];
    XCTestExpectation *expectation = [self expectationForNotification:UIApplicationDidEnterBackgroundNotification
                                                               object:nil
                                                              handler:^BOOL(NSNotification * _Nonnull notification) {
        return YES;
    }];
    EMSSession *partialMockSession = OCMPartialMock(self.session);
    
    [NSNotificationCenter.defaultCenter postNotification:[NSNotification notificationWithName:UIApplicationDidEnterBackgroundNotification
                                                                                       object:nil]];
    OCMVerify(never(), [partialMockSession stopSessionWithCompletionBlock:nil]);

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2.0];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
}

- (void)testStopSession_shouldSendSessionStopEvent {
    self.session.sessionStartTime = [NSDate date];
    NSDate *sessionStopTime = [NSDate date];
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([self.mockTimestampProvider provideTimestamp]).andReturn(sessionStopTime);

    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:@"session:end"
                                                          eventAttributes:@{@"duration": [[sessionStopTime numberValueInMillisFromDate:self.session.sessionStartTime] stringValue]}
                                                                eventType:EventTypeInternal]).andReturn(mockRequestModel);
    [self.session stopSessionWithCompletionBlock:nil];

    [self waitATickOnOperationQueue:self.operationQueue];
    
    OCMVerify([self.mockRequestManager submitRequestModel:mockRequestModel
                                      withCompletionBlock:nil]);
    XCTAssertNil(self.sessionIdHolder.sessionId);
}

@end
