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
    _operationQueue = [NSOperationQueue new];
    _session = [[EMSSession alloc] initWithSessionIdHolder:self.sessionIdHolder
                                            requestManager:self.mockRequestManager
                                            requestFactory:self.mockRequestFactory
                                            operationQueue:self.operationQueue
                                         timestampProvider:self.mockTimestampProvider];
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
    [self.session startSession];

    XCTAssertNotNil(self.session.sessionIdHolder.sessionId);
}

- (void)testStartSession_shouldSetSessionStartTime {
    NSDate *sessionStartTime = [NSDate date];

    OCMStub([self.mockTimestampProvider provideTimestamp]).andReturn(sessionStartTime);

    [self.session startSession];

    XCTAssertEqualObjects(self.session.sessionStartTime, sessionStartTime);
}

- (void)testStartSession_shouldSendSessionStartEvent {
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);

    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:@"session:start"
                                                          eventAttributes:nil
                                                                eventType:EventTypeInternal]).andReturn(mockRequestModel);
    [self.session startSession];

    OCMVerify([self.mockRequestManager submitRequestModel:mockRequestModel
                                      withCompletionBlock:nil]);
}

- (void)testDidBecomeActiveNotification_shouldInvokeStartSession {
    EMSSession *partialMockSession = OCMPartialMock(self.session);

    [NSNotificationCenter.defaultCenter postNotification:[NSNotification notificationWithName:UIApplicationDidBecomeActiveNotification
                                                                                       object:nil]];
    OCMVerify([partialMockSession startSession]);
}

- (void)testDidEnterBackgroundNotification_shouldInvokeStopSession {
    EMSSession *partialMockSession = OCMPartialMock(self.session);

    [NSNotificationCenter.defaultCenter postNotification:[NSNotification notificationWithName:UIApplicationDidEnterBackgroundNotification
                                                                                       object:nil]];
    OCMVerify([partialMockSession stopSession]);
}

- (void)testStopSession_shouldSendSessionStopEvent {
    self.session.sessionStartTime = [NSDate date];
    NSDate *sessionStopTime = [NSDate date];
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([self.mockTimestampProvider provideTimestamp]).andReturn(sessionStopTime);

    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:@"session:end"
                                                          eventAttributes:@{@"duration": [[sessionStopTime numberValueInMillisFromDate:self.session.sessionStartTime] stringValue]}
                                                                eventType:EventTypeInternal]).andReturn(mockRequestModel);
    [self.session stopSession];

    OCMVerify([self.mockRequestManager submitRequestModel:mockRequestModel
                                      withCompletionBlock:nil]);
    XCTAssertNil(self.sessionIdHolder.sessionId);
}

@end
