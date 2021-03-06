//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSPushV3Internal.h"
#import "EMSRequestManager.h"
#import "EMSRequestFactory.h"
#import "NSData+MobileEngine.h"
#import "NSDictionary+MobileEngage.h"
#import "NSError+EMSCore.h"
#import "EMSTimestampProvider.h"
#import "EMSActionFactory.h"
#import "EMSActionProtocol.h"
#import "EMSNotificationInformationDelegate.h"
#import "EMSStorage.h"

@interface EMSPushV3InternalTests : XCTestCase

@property(nonatomic, strong) EMSPushV3Internal *push;
@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;
@property(nonatomic, strong) EMSTimestampProvider *mockTimestampProvider;
@property(nonatomic, strong) EMSActionFactory *mockActionFactory;
@property(nonatomic, strong) NSString *pushToken;
@property(nonatomic, strong) id mockPushTokenData;
@property(nonatomic, strong) EMSStorage *mockStorage;

@end

@implementation EMSPushV3InternalTests

- (void)setUp {
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockTimestampProvider = OCMClassMock([EMSTimestampProvider class]);
    _mockActionFactory = OCMClassMock([EMSActionFactory class]);
    _mockStorage = OCMClassMock([EMSStorage class]);

    _pushToken = @"pushTokenString";
    NSData *data = [NSData new];
    _mockPushTokenData = OCMPartialMock(data);
    OCMStub([self.mockPushTokenData deviceTokenString]).andReturn(self.pushToken);

    _push = [[EMSPushV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                               requestManager:self.mockRequestManager
                                            timestampProvider:self.mockTimestampProvider
                                                actionFactory:self.mockActionFactory
                                                      storage:self.mockStorage];
}

- (void)tearDown {
    [self.mockPushTokenData stopMocking];
    [super tearDown];
}

- (void)testInit_requestFactory_mustNotBeNil {
    @try {
        [[EMSPushV3Internal alloc] initWithRequestFactory:nil
                                           requestManager:self.mockRequestManager
                                        timestampProvider:self.mockTimestampProvider
                                            actionFactory:self.mockActionFactory
                                                  storage:self.mockStorage];
        XCTFail(@"Expected Exception when requestFactory is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestFactory");
    }
}

- (void)testInit_requestManager_mustNotBeNil {
    @try {
        [[EMSPushV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                           requestManager:nil
                                        timestampProvider:self.mockTimestampProvider
                                            actionFactory:self.mockActionFactory
                                                  storage:self.mockStorage];
        XCTFail(@"Expected Exception when requestManager is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestManager");
    }
}

- (void)testInit_timestampProvider_mustNotBeNil {
    @try {
        [[EMSPushV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                           requestManager:self.mockRequestManager
                                        timestampProvider:nil
                                            actionFactory:self.mockActionFactory
                                                  storage:self.mockStorage];
        XCTFail(@"Expected Exception when timestampProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: timestampProvider");
    }
}

- (void)testInit_actionFactory_mustNotBeNil {
    @try {
        [[EMSPushV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                           requestManager:self.mockRequestManager
                                        timestampProvider:self.mockTimestampProvider
                                            actionFactory:nil
                                                  storage:self.mockStorage];
        XCTFail(@"Expected Exception when actionFactory is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: actionFactory");
    }
}

- (void)testInit_storage_mustNotBeNil {
    @try {
        [[EMSPushV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                           requestManager:self.mockRequestManager
                                        timestampProvider:self.mockTimestampProvider
                                            actionFactory:self.mockActionFactory
                                                  storage:nil];
        XCTFail(@"Expected Exception when storage is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: storage");
    }
}

- (void)testInit_shouldSetDeviceTokenValueFromStorage {
    NSData *token = [@"token" dataUsingEncoding:NSUTF8StringEncoding];
    OCMStub([self.mockStorage dataForKey:@"EMSPushTokenKey"]).andReturn(token);

    EMSPushV3Internal *push = [[EMSPushV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                                                 requestManager:self.mockRequestManager
                                                              timestampProvider:self.mockTimestampProvider
                                                                  actionFactory:self.mockActionFactory
                                                                        storage:self.mockStorage];

    NSData *result = [push pushToken];

    XCTAssertEqualObjects(result, token);
}

- (void)testSetPushToken {
    id partialMockPush = OCMPartialMock(self.push);

    [partialMockPush setPushToken:self.mockPushTokenData];

    OCMVerify([partialMockPush setPushToken:self.mockPushTokenData
                            completionBlock:nil]);

    [partialMockPush stopMocking];
}

- (void)testSetPushToken_andClearPushToken_withDeviceToken {
    NSData *token = [@"token" dataUsingEncoding:NSUTF8StringEncoding];
    [self.push setPushToken:token
            completionBlock:nil];

    XCTAssertEqualObjects(self.push.deviceToken, token);

    [self.push clearPushTokenWithCompletionBlock:nil];

    XCTAssertNil(self.push.deviceToken);
}

- (void)testSetPushTokenCompletionBlock_requestFactory_calledWithProperPushToken {
    [self.push setPushToken:self.mockPushTokenData
            completionBlock:nil];

    OCMVerify([self.mockRequestFactory createPushTokenRequestModelWithPushToken:self.pushToken]);
}

- (void)testSetPushTokenCompletionBlock_shouldNotCallRequestFactory_when_pushTokenIsNil {
    OCMReject([self.mockRequestFactory createPushTokenRequestModelWithPushToken:[OCMArg any]]);

    [self.push setPushToken:nil
            completionBlock:nil];
}

- (void)testSetPushTokenCompletionBlock_shouldNotCallRequestFactory_when_pushTokenStringIsNilOrEmpty {
    _mockPushTokenData = OCMClassMock([NSData class]);
    OCMStub([self.mockPushTokenData deviceTokenString]).andReturn(nil);

    OCMReject([self.mockRequestFactory createPushTokenRequestModelWithPushToken:[OCMArg any]]);

    [self.push setPushToken:self.mockPushTokenData
            completionBlock:nil];
}

- (void)testSetPushTokenCompletionBlock_shouldNotCallRequestManager_when_pushTokenIsNil {
    [self.mockPushTokenData stopMocking];

    OCMReject([self.mockRequestManager submitRequestModel:[OCMArg any]
                                      withCompletionBlock:[OCMArg any]]);

    [self.push setPushToken:nil
            completionBlock:nil];
}

- (void)testSetPushTokenCompletionBlock {
    id mockRequestModel = OCMClassMock([EMSRequestModel class]);
    EMSCompletionBlock completionBlock = ^(NSError *error) {
    };

    OCMStub([self.mockRequestFactory createPushTokenRequestModelWithPushToken:self.pushToken]).andReturn(mockRequestModel);

    [self.push setPushToken:self.mockPushTokenData
            completionBlock:completionBlock];

    OCMVerify([self.mockRequestManager submitRequestModel:mockRequestModel
                                      withCompletionBlock:[OCMArg any]]);
}

- (void)testSetPushToken_shouldStoreToken_afterSuccessRequestSending {
    OCMStub([self.mockRequestManager submitRequestModel:[OCMArg any]
                                    withCompletionBlock:([OCMArg invokeBlock])]);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];
    [self.push setPushToken:self.mockPushTokenData
            completionBlock:^(NSError *error) {
                [expectation fulfill];
            }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];

    OCMVerify([self.mockStorage setData:self.mockPushTokenData
                                 forKey:@"EMSPushTokenKey"]);

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
}

- (void)testSetPushToken_shouldNotStoreToken_afterFailedRequestSending {
    OCMStub([self.mockRequestManager submitRequestModel:[OCMArg any]
                                    withCompletionBlock:([OCMArg invokeBlockWithArgs:[NSError errorWithCode:-123
                                                                                       localizedDescription:@"testError"],
                                                                                     nil])]);
    OCMReject([self.mockStorage setData:[OCMArg any]
                                 forKey:@"EMSPushTokenKey"]);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];
    [self.push setPushToken:self.mockPushTokenData
            completionBlock:^(NSError *error) {
                [expectation fulfill];
            }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
}

- (void)testSetPushToken_shouldNotSendRequest_whenTokenAlreadyStored_callbackOnMainQueue {
    NSData *pushToken = [@"testPushTokenData" dataUsingEncoding:NSUTF8StringEncoding];

    OCMReject([self.mockRequestManager submitRequestModel:[OCMArg any]
                                      withCompletionBlock:[OCMArg any]]);

    OCMStub([self.mockStorage dataForKey:@"EMSPushTokenKey"]).andReturn(pushToken);

    __block NSOperationQueue *returnedQueue = nil;
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];
    [self.push setPushToken:pushToken
            completionBlock:^(NSError *error) {
                returnedQueue = [NSOperationQueue currentQueue];
                [expectation fulfill];
            }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(returnedQueue, [NSOperationQueue mainQueue]);
}

- (void)testPushToken_shouldReturnTheDeviceToken {
    NSData *pushToken = [@"testPushTokenData" dataUsingEncoding:NSUTF8StringEncoding];
    [self.push setPushToken:pushToken];

    XCTAssertEqualObjects([self.push pushToken], pushToken);
}


- (void)testClearPushToken {
    id partialMockPush = OCMPartialMock(self.push);

    [partialMockPush clearPushToken];

    OCMVerify([partialMockPush clearPushTokenWithCompletionBlock:nil]);

    [partialMockPush stopMocking];
}

- (void)testClearDeviceTokenStorage {
    [self.push clearDeviceTokenStorage];

    OCMVerify([self.mockStorage setData:nil
                                 forKey:@"EMSPushTokenKey"]);
}

- (void)testClearPushTokenWithCompletionBlock {
    EMSCompletionBlock completionBlock = ^(NSError *error) {
    };
    id mockRequestModel = OCMClassMock([EMSRequestModel class]);

    OCMStub([self.mockRequestFactory createClearPushTokenRequestModel]).andReturn(mockRequestModel);

    [self.push clearPushTokenWithCompletionBlock:completionBlock];

    OCMVerify([self.mockStorage setData:nil
                                 forKey:@"EMSPushTokenKey"]);
    OCMVerify([self.mockRequestFactory createClearPushTokenRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:mockRequestModel
                                      withCompletionBlock:completionBlock]);
}

- (void)testTrackMessageOpenWithUserInfo_userInfo_mustNotBeNil {
    @try {
        [self.push trackMessageOpenWithUserInfo:nil];
        XCTFail(@"Expected Exception when userInfo is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: userInfo");
    }
}

- (void)testTrackMessageOpenWithUserInfo {
    NSDictionary *testUserInfo = @{@"testKey": @"testValue"};

    id partialMockPush = OCMPartialMock(self.push);

    [partialMockPush trackMessageOpenWithUserInfo:testUserInfo];

    OCMVerify([partialMockPush trackMessageOpenWithUserInfo:testUserInfo
                                            completionBlock:nil]);
    [partialMockPush stopMocking];
}

- (void)testTrackMessageOpenWithUserInfoCompletionBlock_userInfo_mustNotBeNil {
    @try {
        [self.push trackMessageOpenWithUserInfo:nil
                                completionBlock:^(NSError *error) {
                                }];
        XCTFail(@"Expected Exception when userInfo is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: userInfo");
    }
}

- (void)testTrackMessageOpenWithUserInfoCompletionBlock {
    NSDictionary *mockUserInfo = OCMClassMock([NSDictionary class]);
    NSString *messageId = @"testMessageId";
    NSString *eventName = @"push:click";
    NSDictionary *eventAttributes = @{
            @"origin": @"main",
            @"sid": messageId
    };

    id mockRequestModel = OCMClassMock([EMSRequestModel class]);

    OCMStub([mockUserInfo messageId]).andReturn(messageId);
    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:eventName
                                                          eventAttributes:eventAttributes
                                                                eventType:EventTypeInternal]).andReturn(mockRequestModel);

    [self.push trackMessageOpenWithUserInfo:mockUserInfo
                            completionBlock:nil];

    OCMVerify([self.mockRequestFactory createEventRequestModelWithEventName:eventName
                                                            eventAttributes:eventAttributes
                                                                  eventType:EventTypeInternal]);
    OCMVerify([self.mockRequestManager submitRequestModel:mockRequestModel
                                      withCompletionBlock:nil]);
}

- (void)testTrackMessageOpenWithUserInfoCompletionBlock_when_messageIdIsMissing {
    NSError *expectedError = [NSError errorWithCode:1400
                               localizedDescription:@"No messageId found!"];

    __block NSError *returnedError = nil;
    __block NSOperationQueue *usedOperationQueue = [NSOperationQueue new];
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionBlock"];
    [self.push trackMessageOpenWithUserInfo:@{}
                            completionBlock:^(NSError *error) {
                                returnedError = error;
                                usedOperationQueue = [NSOperationQueue currentQueue];
                                [expectation fulfill];
                            }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(returnedError, expectedError);
    XCTAssertEqualObjects(usedOperationQueue, [NSOperationQueue mainQueue]);
}

- (void)testHandleMessageWithUserInfo {
    NSDictionary *openExternalUrlAction = @{
            @"type": @"OpenExternalUrl",
            @"url": @"https://www.emarsys.com"
    };
    NSDictionary *badgeCountAction = @{
            @"type": @"BadgeCount",
            @"method": @"ADD",
            @"value": @12
    };

    id mockActionUrl = OCMProtocolMock(@protocol(EMSActionProtocol));
    id mockActionBadge = OCMProtocolMock(@protocol(EMSActionProtocol));

    OCMStub([self.mockActionFactory createActionWithActionDictionary:openExternalUrlAction]).andReturn(mockActionUrl);
    OCMStub([self.mockActionFactory createActionWithActionDictionary:badgeCountAction]).andReturn(mockActionBadge);

    __block NSOperationQueue *returnedOperationQueue = nil;
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];

    EMSEventHandlerBlock eventHandler = ^(NSString *eventName, NSDictionary<NSString *, id> *payload) {

    };

    [self.push setSilentMessageEventHandler:eventHandler];
    [self.push setSilentNotificationInformationDelegate:^(EMSNotificationInformation *notificationInformation) {
        returnedOperationQueue = [NSOperationQueue currentQueue];
        [expectation fulfill];
    }];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.push handleMessageWithUserInfo:@{
                @"ems":
                @{
                        @"actions": @[
                        openExternalUrlAction,
                        badgeCountAction
                ],
                        @"multichannelId": @"testMultiChannelId"
                }
        }];
    });

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:5];

    OCMVerify([self.mockActionFactory setEventHandler:eventHandler]);
    OCMVerify([self.mockActionFactory createActionWithActionDictionary:openExternalUrlAction]);
    OCMVerify([mockActionUrl execute]);
    OCMVerify([self.mockActionFactory createActionWithActionDictionary:badgeCountAction]);
    OCMVerify([mockActionBadge execute]);
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(returnedOperationQueue, [NSOperationQueue mainQueue]);
}

@end
