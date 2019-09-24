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
#import "EMSNotificationCache.h"
#import "EMSTimestampProvider.h"

@interface EMSPushV3InternalTests : XCTestCase

@property(nonatomic, strong) EMSPushV3Internal *push;
@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;
@property(nonatomic, strong) EMSNotificationCache *mockNotificationCache;
@property(nonatomic, strong) EMSTimestampProvider *mockTimestampProvider;
@property(nonatomic, strong) NSString *pushToken;
@property(nonatomic, strong) id mockPushTokenData;

@end

@implementation EMSPushV3InternalTests

- (void)setUp {
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockNotificationCache = OCMClassMock([EMSNotificationCache class]);
    _mockTimestampProvider = OCMClassMock([EMSTimestampProvider class]);

    _pushToken = @"pushTokenString";
    NSData *data = [NSData new];
    _mockPushTokenData = OCMPartialMock(data);
    OCMStub([self.mockPushTokenData deviceTokenString]).andReturn(self.pushToken);

    _push = [[EMSPushV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                               requestManager:self.mockRequestManager
                                            notificationCache:self.mockNotificationCache
                                            timestampProvider:self.mockTimestampProvider];
}

- (void)tearDown {
    [self.mockPushTokenData stopMocking];
    [super tearDown];
}

- (void)testInit_requestFactory_mustNotBeNil {
    @try {
        [[EMSPushV3Internal alloc] initWithRequestFactory:nil
                                           requestManager:self.mockRequestManager
                                        notificationCache:self.mockNotificationCache
                                        timestampProvider:self.mockTimestampProvider];
        XCTFail(@"Expected Exception when requestFactory is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestFactory");
    }
}

- (void)testInit_requestManager_mustNotBeNil {
    @try {
        [[EMSPushV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                           requestManager:nil
                                        notificationCache:self.mockNotificationCache
                                        timestampProvider:self.mockTimestampProvider];
        XCTFail(@"Expected Exception when requestManager is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestManager");
    }
}

- (void)testInit_notificationCache_mustNotBeNil {
    @try {
        [[EMSPushV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                           requestManager:self.mockRequestManager
                                        notificationCache:nil
                                        timestampProvider:self.mockTimestampProvider];
        XCTFail(@"Expected Exception when notificationCache is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: notificationCache");
    }
}

- (void)testInit_timestampProvider_mustNotBeNil {
    @try {
        [[EMSPushV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                           requestManager:self.mockRequestManager
                                        notificationCache:self.mockNotificationCache
                                        timestampProvider:nil];
        XCTFail(@"Expected Exception when timestampProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: timestampProvider");
    }
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
    [self.push setPushToken:token completionBlock:nil];

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
                                      withCompletionBlock:completionBlock]);
}

- (void)testClearPushToken {
    id partialMockPush = OCMPartialMock(self.push);

    [partialMockPush clearPushToken];

    OCMVerify([partialMockPush clearPushTokenWithCompletionBlock:nil]);

    [partialMockPush stopMocking];
}

- (void)testClearPushTokenWithCompletionBlock {
    EMSCompletionBlock completionBlock = ^(NSError *error) {
    };
    id mockRequestModel = OCMClassMock([EMSRequestModel class]);

    OCMStub([self.mockRequestFactory createClearPushTokenRequestModel]).andReturn(mockRequestModel);

    [self.push clearPushTokenWithCompletionBlock:completionBlock];

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

    [self.push trackMessageOpenWithUserInfo:mockUserInfo completionBlock:nil];

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

- (void)testTrackMessageOpenWithUserInfoCompletionBlock_cachesInboxNotifications {
    NSDictionary *userInfo = @{
            @"inbox": @(1)
    };
    NSDate *date = [NSDate date];

    OCMStub([self.mockTimestampProvider provideTimestamp]).andReturn(date);

    EMSNotification *expectedNotification = [[EMSNotification alloc] initWithUserInfo:userInfo
                                                                    timestampProvider:self.mockTimestampProvider];

    [self.push trackMessageOpenWithUserInfo:userInfo
                            completionBlock:nil];

    OCMVerify([self.mockNotificationCache cache:expectedNotification]);
}

- (void)testTrackMessageOpenWithUserInfoCompletionBlock_shouldNotCache_when_notInboxNotification {
    NSDictionary *userInfo = @{@"inbox": @(NO)};

    OCMReject([self.mockNotificationCache cache:[OCMArg any]]);

    [self.push trackMessageOpenWithUserInfo:userInfo
                            completionBlock:nil];
}

@end
