//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <UserNotifications/UNUserNotificationCenter.h>
#import <Tests-Swift.h>
#import "EMSPushV3Internal.h"
#import "NSData+MobileEngine.h"
#import "NSDictionary+MobileEngage.h"
#import "NSError+EMSCore.h"
#import "FakeNotificationDelegate.h"
#import "EMSWaiter.h"
#import "EMSNotificationInformation.h"

@interface EMSPushV3Internal ()

- (NSDictionary *)actionFromResponse:(UNNotificationResponse *)response;

@end

@interface EMSPushV3InternalTests : XCTestCase

@property(nonatomic, strong) EMSPushV3Internal *push;
@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;
@property(nonatomic, strong) EMSTimestampProvider *mockTimestampProvider;
@property(nonatomic, strong) EMSActionFactory *mockActionFactory;
@property(nonatomic, strong) NSString *pushToken;
@property(nonatomic, strong) id mockPushTokenData;
@property(nonatomic, strong) EMSStorage *mockStorage;
@property(nonatomic, strong) MEInApp *mockInApp;
@property(nonatomic, strong) EMSUUIDProvider *mockUuidProvider;
@property(nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation EMSPushV3InternalTests

id (^notificationResponseWithUserInfoWithActionId)(NSDictionary *userInfo, NSString *actionId) = ^id(NSDictionary *userInfo, NSString *actionId) {
    UNNotificationResponse *response = OCMClassMock([UNNotificationResponse class]);
    UNNotification *notification = OCMClassMock([UNNotification class]);
    UNNotificationRequest *request = OCMClassMock([UNNotificationRequest class]);
    UNNotificationContent *content = OCMClassMock([UNNotificationContent class]);
    OCMStub([response notification]).andReturn(notification);
    OCMStub([response actionIdentifier]).andReturn(actionId);
    OCMStub([notification request]).andReturn(request);
    OCMStub([request content]).andReturn(content);
    OCMStub([content userInfo]).andReturn(userInfo);

    return response;
};

id (^notificationResponseWithUserInfo)(NSDictionary *userInfo) = ^id(NSDictionary *userInfo) {
    return notificationResponseWithUserInfoWithActionId(userInfo, @"uniqueId");
};

- (void)setUp {
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockTimestampProvider = OCMClassMock([EMSTimestampProvider class]);
    _mockActionFactory = OCMClassMock([EMSActionFactory class]);
    _mockStorage = OCMClassMock([EMSStorage class]);
    _mockInApp = OCMClassMock([MEInApp class]);
    _mockUuidProvider = OCMClassMock([EMSUUIDProvider class]);
    _operationQueue = [NSOperationQueue new];

    _pushToken = @"pushTokenString";
    NSData *data = [NSData new];
    _mockPushTokenData = OCMPartialMock(data);
    OCMStub([self.mockPushTokenData deviceTokenString]).andReturn(self.pushToken);

    _push = [[EMSPushV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                               requestManager:self.mockRequestManager
                                            timestampProvider:self.mockTimestampProvider
                                                actionFactory:self.mockActionFactory
                                                      storage:self.mockStorage
                                                        inApp:self.mockInApp
                                                 uuidProvider:self.mockUuidProvider
                                               operationQueue:self.operationQueue];
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
                                                  storage:self.mockStorage
                                                    inApp:self.mockInApp
                                             uuidProvider:self.mockUuidProvider
                                           operationQueue:self.operationQueue];
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
                                                  storage:self.mockStorage
                                                    inApp:self.mockInApp
                                             uuidProvider:self.mockUuidProvider
                                           operationQueue:self.operationQueue];
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
                                                  storage:self.mockStorage
                                                    inApp:self.mockInApp
                                             uuidProvider:self.mockUuidProvider
                                           operationQueue:self.operationQueue];
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
                                                  storage:self.mockStorage
                                                    inApp:self.mockInApp
                                             uuidProvider:self.mockUuidProvider
                                           operationQueue:self.operationQueue];
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
                                                  storage:nil
                                                    inApp:self.mockInApp
                                             uuidProvider:self.mockUuidProvider
                                           operationQueue:self.operationQueue];
        XCTFail(@"Expected Exception when storage is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: storage");
    }
}

- (void)testInit_inApp_mustNotBeNil {
    @try {
        [[EMSPushV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                           requestManager:self.mockRequestManager
                                        timestampProvider:self.mockTimestampProvider
                                            actionFactory:self.mockActionFactory
                                                  storage:self.mockStorage
                                                    inApp:nil
                                             uuidProvider:self.mockUuidProvider
                                           operationQueue:self.operationQueue];
        XCTFail(@"Expected Exception when inApp is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: inApp");
    }
}

- (void)testInit_uuidProvider_mustNotBeNil {
    @try {
        [[EMSPushV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                           requestManager:self.mockRequestManager
                                        timestampProvider:self.mockTimestampProvider
                                            actionFactory:self.mockActionFactory
                                                  storage:self.mockStorage
                                                    inApp:self.mockInApp
                                             uuidProvider:nil
                                           operationQueue:self.operationQueue];
        XCTFail(@"Expected Exception when uuidProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: uuidProvider");
    }
}

- (void)testInit_operationQueue_mustNotBeNil {
    @try {
        [[EMSPushV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                           requestManager:self.mockRequestManager
                                        timestampProvider:self.mockTimestampProvider
                                            actionFactory:self.mockActionFactory
                                                  storage:self.mockStorage
                                                    inApp:self.mockInApp
                                             uuidProvider:self.mockUuidProvider
                                           operationQueue:nil];
        XCTFail(@"Expected Exception when operationQueue is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: operationQueue");
    }
}

- (void)testInit_shouldSetDeviceTokenValueFromStorage {
    NSData *token = [@"token" dataUsingEncoding:NSUTF8StringEncoding];
    OCMStub([self.mockStorage dataForKey:@"EMSPushTokenKey"]).andReturn(token);

    EMSPushV3Internal *push = [[EMSPushV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                                                 requestManager:self.mockRequestManager
                                                              timestampProvider:self.mockTimestampProvider
                                                                  actionFactory:self.mockActionFactory
                                                                        storage:self.mockStorage
                                                                          inApp:self.mockInApp
                                                                   uuidProvider:self.mockUuidProvider
                                                                 operationQueue:self.operationQueue];

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
    [self.push setSilentMessageInformationBlock:^(EMSNotificationInformation *notificationInformation) {
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


- (void)testShouldCallTheInjectedDelegate_userNotificationCenterWillPresentNotificationWithCompletionHandler_method {
    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];

    id userNotificationCenterDelegate = OCMProtocolMock(@protocol(UNUserNotificationCenterDelegate));
    UNUserNotificationCenter *mockCenter = OCMClassMock([UNUserNotificationCenter class]);
    UNNotification *mockNotification = OCMClassMock([UNNotification class]);

    void (^ const completionHandler)(UNNotificationPresentationOptions) =^(UNNotificationPresentationOptions options) {
        [exp fulfill];
    };
    self.push.delegate = userNotificationCenterDelegate;

    [self.push userNotificationCenter:mockCenter
              willPresentNotification:mockNotification
                withCompletionHandler:completionHandler];

    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[exp]
                                                    timeout:10];
    XCTAssertEqual(result, XCTWaiterResultCompleted);
    OCMVerify([userNotificationCenterDelegate userNotificationCenter:mockCenter
                                             willPresentNotification:mockNotification
                                               withCompletionHandler:completionHandler]);
}

- (void)testShouldCallTheInjectedDelegate_userNotificationCenter_openSettingsForNotification_method {
    if (@available(iOS 12, *)) {
        id userNotificationCenterDelegate = OCMProtocolMock(@protocol(UNUserNotificationCenterDelegate));
        UNUserNotificationCenter *mockCenter = OCMClassMock([UNUserNotificationCenter class]);
        UNNotification *mockNotification = OCMClassMock([UNNotification class]);

        self.push.delegate = userNotificationCenterDelegate;

        [self.push userNotificationCenter:mockCenter
              openSettingsForNotification:mockNotification];

        XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForMainQueue"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [expectation fulfill];
        });
        XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                              timeout:2];

        OCMVerify([userNotificationCenterDelegate userNotificationCenter:mockCenter
                                             openSettingsForNotification:mockNotification]);
        XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    }
}

- (void)testShouldCallTheInjectedDelegate_userNotificationCenterWillPresentNotificationWithCompletionHandler_methodOnMainThread {
    FakeNotificationDelegate *delegate = [FakeNotificationDelegate new];

    __block NSOperationQueue *returnedQueue = nil;
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    [delegate setWillPresentBlock:^(NSOperationQueue *operationQueue) {
        returnedQueue = operationQueue;
        [expectation fulfill];
    }];

    UNUserNotificationCenter *mockCenter = OCMClassMock([UNUserNotificationCenter class]);
    UNNotification *mockNotification = OCMClassMock([UNNotification class]);
    void (^ const completionHandler)(UNNotificationPresentationOptions) =^(UNNotificationPresentationOptions options) {
    };
    self.push.delegate = delegate;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.push userNotificationCenter:mockCenter
                  willPresentNotification:mockNotification
                    withCompletionHandler:completionHandler];
    });

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(returnedQueue, [NSOperationQueue mainQueue]);
}

- (void)testShouldCallCompletionHandler_withUNNotificationPresentationOptionAlert {
    __block NSOperationQueue *currentQueue = nil;
    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    __block UNNotificationPresentationOptions _option;

    [self.push userNotificationCenter:OCMClassMock([UNUserNotificationCenter class])
              willPresentNotification:nil
                withCompletionHandler:^(UNNotificationPresentationOptions options) {
                    _option = options;
                    currentQueue = [NSOperationQueue currentQueue];
                    [exp fulfill];
                }];

    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[exp]
                                                    timeout:10];

    XCTAssertEqual(result, XCTWaiterResultCompleted);
    XCTAssertEqual(_option, UNNotificationPresentationOptionAlert);
    XCTAssertEqualObjects(currentQueue, [NSOperationQueue mainQueue]);
}

- (void)testShouldCallTheInjectedDelegate_userNotificationCenterDidReceiveNotificationResponseWithCompletionHandler_method {
    id userNotificationCenterDelegate = OCMProtocolMock(@protocol(UNUserNotificationCenterDelegate));
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    UNUserNotificationCenter *center = OCMClassMock([UNUserNotificationCenter class]);
    UNNotificationResponse *notificationResponse = notificationResponseWithUserInfo(@{});

    void (^ const completionHandler)(void) =^{
        [expectation fulfill];
    };

    self.push.delegate = userNotificationCenterDelegate;

    [self.push userNotificationCenter:center
       didReceiveNotificationResponse:notificationResponse
                withCompletionHandler:completionHandler];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2];

    OCMVerify([userNotificationCenterDelegate userNotificationCenter:center
                                      didReceiveNotificationResponse:notificationResponse
                                               withCompletionHandler:completionHandler]);
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
}

- (void)testShouldCallTheInjectedDelegate_userNotificationCenterDidReceiveNotificationResponseWithCompletionHandler_methodOnMainThread {
    UNUserNotificationCenter *center = OCMClassMock([UNUserNotificationCenter class]);
    UNNotificationResponse *notificationResponse = notificationResponseWithUserInfo(@{});
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    void (^ const completionHandler)(void) =^{
    };

    FakeNotificationDelegate *delegate = [FakeNotificationDelegate new];

    __block NSOperationQueue *returnedQueue = nil;
    [delegate setDidReceiveBlock:^(NSOperationQueue *operationQueue) {
        returnedQueue = operationQueue;
        [expectation fulfill];
    }];

    self.push.delegate = delegate;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.push userNotificationCenter:center
                    didReceiveNotificationResponse:notificationResponse
                             withCompletionHandler:completionHandler];
    });

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(returnedQueue, [NSOperationQueue mainQueue]);
}

- (void)testShouldCallCompletionHandler {
    __block NSOperationQueue *currentQueue = nil;

    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    [self.push userNotificationCenter:OCMClassMock([UNUserNotificationCenter class])
       didReceiveNotificationResponse:notificationResponseWithUserInfo(@{})
                withCompletionHandler:^{
                    currentQueue = [NSOperationQueue currentQueue];
                    [exp fulfill];
                }];

    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[exp]
                                                    timeout:10];

    XCTAssertEqual(result, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(currentQueue, [NSOperationQueue mainQueue]);
}

- (void)testShouldCallTrackClickWith_richNotificationActionClicked_eventNameAndTitleAndActionId_inPayload {
    NSDictionary *userInfo = @{@"ems": @{
            @"actions": @[
                    @{
                            @"id": @"uniqueId",
                            @"title": @"actionTitle",
                            @"key": @"value"
                    }
            ]}, @"u": @"{\"sid\": \"123456789\"}"
    };

    EMSRequestModel *requestModel = OCMClassMock([EMSRequestModel class]);

    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:@"push:click"
                                                          eventAttributes:(@{
                                                                  @"origin": @"button",
                                                                  @"button_id": @"uniqueId",
                                                                  @"sid": @"123456789"
                                                          })
                                                                eventType:EventTypeInternal]).andReturn(requestModel);

    OCMStub([self.mockRequestManager submitRequestModel:requestModel
                                    withCompletionBlock:[OCMArg any]]);

    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    [self.push userNotificationCenter:OCMClassMock([UNNotificationResponse class])
       didReceiveNotificationResponse:notificationResponseWithUserInfo(userInfo)
                withCompletionHandler:^{
                    [exp fulfill];
                }];

    [EMSWaiter waitForExpectations:@[exp]
                           timeout:10];
}

- (void)testShouldCallTrackMessageOpenWithUserInfoOnMobileEngageWithTheUserInfo_whenDidReceiveNotificationResponseWithCompletionHandler_isCalled {
    EMSPushV3Internal *partialMockPushInternal = OCMPartialMock(self.push);
    NSDictionary *userInfo = @{@"ems": @{
            @"u": @{
                    @"sid": @"123456789"
            }}};

    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    [partialMockPushInternal userNotificationCenter:nil
                     didReceiveNotificationResponse:notificationResponseWithUserInfo(userInfo)
                              withCompletionHandler:^{
                                  [exp fulfill];
                              }];


    [EMSWaiter waitForExpectations:@[exp]
                           timeout:10];
    OCMVerify([partialMockPushInternal trackMessageOpenWithUserInfo:userInfo]);
}

- (void)testShouldCall_showMessageCompletionHandler_onIAMWithInAppMessage_whenDidReceiveNotificationResponseWithCompletionHandler_isCalledWithInAppPayload {
    NSDate *responseTimestamp = [NSDate date];
    OCMStub([self.mockTimestampProvider provideTimestamp]).andReturn(responseTimestamp);

    MEInAppMessage *expectation = [[MEInAppMessage new] initWithCampaignId:@"42"
                                                                       sid:@"123456789"
                                                                       url:@"https://www.test.com"
                                                                      html:@"<html/>"
                                                         responseTimestamp:responseTimestamp];

    NSDictionary *userInfo = @{@"ems": @{
            @"inapp": @{
                    @"campaign_id": @"42",
                    @"url": @"https://www.test.com",
                    @"inAppData": [@"<html/>" dataUsingEncoding:NSUTF8StringEncoding]
            }},
            @"u": @"{\"sid\": \"123456789\"}"};

    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    [self.push userNotificationCenter:OCMClassMock([UNUserNotificationCenter class])
       didReceiveNotificationResponse:notificationResponseWithUserInfo(userInfo)
                withCompletionHandler:^{
                    [exp fulfill];
                }];
    [EMSWaiter waitForExpectations:@[exp]
                           timeout:10];

    OCMVerify([self.mockInApp showMessage:expectation
                        completionHandler:[OCMArg any]]);
}

- (void)testShouldDownloadInappAndTriggerIt_whenInAppDataMissing {
    NSDate *responseTimestamp = [NSDate date];
    OCMStub([self.mockTimestampProvider provideTimestamp]).andReturn(responseTimestamp);

    NSDictionary *userInfo = @{@"ems": @{
            @"inapp": @{
                    @"campaign_id": @"42",
                    @"url": @"https://www.test.com"
            }},
            @"u": @"{\"sid\": \"123456789\"}"};

    EMSResponseModel *responseModel = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                           headers:@{}
                                                                              body:[@"<html/>" dataUsingEncoding:NSUTF8StringEncoding]
                                                                        parsedBody:nil
                                                                      requestModel:OCMClassMock([EMSRequestModel class])
                                                                         timestamp:responseTimestamp];

    MEInAppMessage *inAppMessage = [[MEInAppMessage alloc] initWithCampaignId:@"42"
                                                                          sid:@"123456789"
                                                                          url:@"https://www.test.com"
                                                                         html:@"<html/>"
                                                            responseTimestamp:responseTimestamp];

    OCMStub([self.mockRequestManager submitRequestModelNow:[OCMArg any]
                                              successBlock:([OCMArg invokeBlockWithArgs:@"testRequestId",
                                                                                        responseModel,
                                                                                        nil])
                                                errorBlock:[OCMArg any]]);

    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];

    [self.push userNotificationCenter:OCMClassMock([UNUserNotificationCenter class])
       didReceiveNotificationResponse:notificationResponseWithUserInfo(userInfo)
                withCompletionHandler:^{
                    [exp fulfill];
                }];
    [EMSWaiter waitForExpectations:@[exp]
                           timeout:10];

    //times 2
    OCMVerify([self.mockInApp showMessage:inAppMessage
                        completionHandler:[OCMArg any]]);
    OCMVerify([self.mockTimestampProvider provideTimestamp]);
    OCMVerify([self.mockTimestampProvider provideTimestamp]);
}

- (void)testShouldReturnTheDefaultAction_whenTheActionIdentifierIsUNNotificationDefaultActionIdentifier {
    NSDictionary *expectedAction = @{
            @"type": @"MEAppEvent",
            @"name": @"nameValue",
            @"payload": @{
                    @"someKey": @"someValue"
            }
    };
    NSDictionary *userInfo = @{@"ems": @{
            @"default_action": expectedAction,
            @"actions": @[
                    @{
                            @"id": @"uniqueId",
                            @"title": @"actionTitle",
                            @"type": @"OpenExternalUrl",
                            @"url": @"https://www.emarsys.com"
                    }
            ]
    }, @"u": @"{\"sid\": \"123456789\"}"};


    NSDictionary *action = [self.push actionFromResponse:notificationResponseWithUserInfoWithActionId(userInfo, UNNotificationDefaultActionIdentifier)];

    XCTAssertEqual(action, expectedAction);
}

- (void)testShouldReturnNil_whenTheActionIdentifierIsNotUNNotificationDefaultActionIdentifier_andNoCustomActions {
    NSDictionary *expectedAction = @{
            @"type": @"MEAppEvent",
            @"name": @"nameValue",
            @"payload": @{
                    @"someKey": @"someValue"
            }
    };
    NSDictionary *userInfo = @{@"ems": @{
            @"default_action": expectedAction,
            @"actions": @[
                    @{
                            @"id": @"uniqueId",
                            @"title": @"actionTitle",
                            @"type": @"OpenExternalUrl",
                            @"url": @"https://www.emarsys.com"
                    }
            ]
    }, @"u": @"{\"sid\": \"123456789\"}"};

    NSDictionary *action = [self.push actionFromResponse:notificationResponseWithUserInfoWithActionId(userInfo, UNNotificationDismissActionIdentifier)];

    XCTAssertNil(action);
}

- (void)testShouldUseActionFactory {
    EMSEventHandlerBlock eventHandler = ^(NSString *eventName, NSDictionary<NSString *, id> *payload) {
    };
    NSString *eventName = @"testEventName";
    NSDictionary *payload = @{@"key1": @"value1", @"key2": @"value2", @"key3": @"value3"};
    NSDictionary *expectedAction = @{
            @"id": @"uniqueId",
            @"title": @"actionTitle",
            @"type": @"MEAppEvent",
            @"name": eventName,
            @"payload": payload
    };
    id mockAction = OCMProtocolMock(@protocol(EMSActionProtocol));
    OCMStub([self.mockActionFactory createActionWithActionDictionary:expectedAction]).andReturn(mockAction);

    self.push.notificationEventHandler = eventHandler;
    NSDictionary *userInfo = @{@"ems": @{
            @"actions": @[
                    expectedAction
            ]},
            @"u": @"{\"sid\": \"123456789\"}"
    };

    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    [self.push userNotificationCenter:OCMClassMock([UNUserNotificationCenter class])
       didReceiveNotificationResponse:notificationResponseWithUserInfo(userInfo)
                withCompletionHandler:^{
                    [exp fulfill];
                }];
    [EMSWaiter waitForExpectations:@[exp]
                           timeout:10];

    OCMVerify([self.mockActionFactory setEventHandler:eventHandler]);
    OCMVerify([self.mockActionFactory createActionWithActionDictionary:expectedAction]);
    OCMVerify([mockAction execute]);
}

- (void)testShouldCallotificationInformationDelegate {
    __block NSOperationQueue *returnedQueue = nil;
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];

    self.push.notificationInformationBlock = ^(EMSNotificationInformation *notificationInformation) {
        returnedQueue = [NSOperationQueue currentQueue];
        [expectation fulfill];
    };
    NSDictionary *userInfo = @{@"ems": @{
            @"multichannelId": @"testMultiChannelId"
    },
            @"u": @"{\"sid\": \"123456789\"}"
    };

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.push userNotificationCenter:OCMClassMock([UNUserNotificationCenter class])
           didReceiveNotificationResponse:notificationResponseWithUserInfo(userInfo)
                    withCompletionHandler:^{
                    }];
    });
    [EMSWaiter waitForExpectations:@[expectation]
                           timeout:5];

    XCTAssertEqualObjects(returnedQueue, [NSOperationQueue mainQueue]);
}

@end
