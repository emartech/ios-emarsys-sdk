//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSMobileEngageV3Internal.h"
#import "EMSRequestFactory.h"
#import "EMSRequestManager.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "MERequestContext.h"
#import "EMSStorage.h"
#import "EMSSession.h"
#import "EMSStorageProtocol.h"
#import "EMSCompletionBlockProvider.h"
#import "XCTestCase+Helper.h"

@interface EMSMobileEngageV3InternalTests : XCTestCase

@property(nonatomic, strong) EMSMobileEngageV3Internal *internal;
@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;
@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) MERequestContext *mockRequestContext;
@property(nonatomic, strong) EMSSession *mockSession;
@property(nonatomic, strong) EMSCompletionBlockProvider *completionBlockProvider;
@property(nonatomic, strong) EMSStorage *mockStorage;
@property(nonatomic, strong) NSString *contactFieldValue;
@property(nonatomic, strong) NSString *otherContactFieldValue;
@property(nonatomic, strong) NSNumber *contactFieldId;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *uuidProvider;
@property(nonatomic, strong) NSString *eventName;
@property(nonatomic, strong) NSDictionary *eventAttributes;
@property(nonatomic, copy) void (^completionBlock)(NSError *);
@property(nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation EMSMobileEngageV3InternalTests

- (void)setUp {
    _timestampProvider = [EMSTimestampProvider new];
    _uuidProvider = [EMSUUIDProvider new];

    _contactFieldValue = @"testContactFieldValue";
    _otherContactFieldValue = @"otherContactFieldValue";
    _contactFieldId = @3;
    _eventName = @"testEventName";
    _eventAttributes = @{
            @"TestKey": @"TestValue"
    };
    _completionBlock = ^(NSError *error) {
    };

    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockRequestContext = OCMClassMock([MERequestContext class]);
    _mockStorage = OCMClassMock([EMSStorage class]);
    _mockSession = OCMClassMock([EMSSession class]);

    _operationQueue = self.createTestOperationQueue;
    _completionBlockProvider = [[EMSCompletionBlockProvider alloc] initWithOperationQueue:self.operationQueue];

    _internal = [[EMSMobileEngageV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                                           requestManager:self.mockRequestManager
                                                           requestContext:self.mockRequestContext
                                                                  storage:self.mockStorage
                                                                  session:self.mockSession
                                                  completionBlockProvider:self.completionBlockProvider];
}

- (void)testInit_requestFactory_mustNotBeNil {
    @try {
        [[EMSMobileEngageV3Internal alloc] initWithRequestFactory:nil
                                                   requestManager:self.mockRequestManager
                                                   requestContext:self.mockRequestContext
                                                          storage:self.mockStorage
                                                          session:self.mockSession
                                          completionBlockProvider:self.completionBlockProvider];
        XCTFail(@"Expected Exception when requestFactory is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestFactory");
    }
}

- (void)testInit_requestManager_mustNotBeNil {
    @try {
        [[EMSMobileEngageV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                                   requestManager:nil
                                                   requestContext:self.mockRequestContext
                                                          storage:self.mockStorage
                                                          session:self.mockSession
                                          completionBlockProvider:self.completionBlockProvider];
        XCTFail(@"Expected Exception when requestManager is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestManager");
    }
}

- (void)testInit_requestContext_mustNotBeNil {
    @try {
        [[EMSMobileEngageV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                                   requestManager:self.mockRequestManager
                                                   requestContext:nil
                                                          storage:self.mockStorage
                                                          session:self.mockSession
                                          completionBlockProvider:self.completionBlockProvider];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestContext");
    }
}

- (void)testInit_storage_mustNotBeNil {
    @try {
        [[EMSMobileEngageV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                                   requestManager:self.mockRequestManager
                                                   requestContext:self.mockRequestContext
                                                          storage:nil
                                                          session:self.mockSession
                                          completionBlockProvider:self.completionBlockProvider];
        XCTFail(@"Expected Exception when storage is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: storage");
    }
}

- (void)testInit_session_mustNotBeNil {
    @try {
        [[EMSMobileEngageV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                                   requestManager:self.mockRequestManager
                                                   requestContext:self.mockRequestContext
                                                          storage:self.mockStorage
                                                          session:nil
                                          completionBlockProvider:self.completionBlockProvider];
        XCTFail(@"Expected Exception when session is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: session");
    }
}

- (void)testInit_completionBlockProvider_mustNotBeNil {
    @try {
        [[EMSMobileEngageV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                                   requestManager:self.mockRequestManager
                                                   requestContext:self.mockRequestContext
                                                          storage:self.mockStorage
                                                          session:self.mockSession
                                          completionBlockProvider:nil];
        XCTFail(@"Expected Exception when completionBlockProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: completionBlockProvider");
    }
}

- (void)testSetContactWithContactFieldValue {
    EMSMobileEngageV3Internal *partialMockInternal = OCMPartialMock(self.internal);

    [partialMockInternal setContactWithContactFieldId:self.contactFieldId
                                    contactFieldValue:self.contactFieldValue];

    OCMVerify([partialMockInternal setContactWithContactFieldId:self.contactFieldId
                                              contactFieldValue:self.contactFieldValue
                                                completionBlock:nil]);
}

- (void)testSetContactWithContactFieldIdWithNewContactFieldValueCompletionBlock {
    EMSRequestModel *requestModel = [self createRequestModel];
    XCTestExpectation *expectation = [self expectationWithDescription:@"StartSession was called."];
    
    OCMStub([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]).andDo(^(NSInvocation *invocation) {[expectation fulfill];});
    OCMStub([self.mockSession stopSessionWithCompletionBlock:[OCMArg invokeBlock]]);

    OCMStub([self.mockRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestContext contactFieldValue]).andReturn(self.contactFieldValue);
    OCMStub([self.mockRequestFactory createContactRequestModel]).andReturn(requestModel);
    OCMStub([self.mockRequestManager submitRequestModel:requestModel
                                    withCompletionBlock:[OCMArg invokeBlock]]);

    [self.internal setContactWithContactFieldId:self.contactFieldId
                              contactFieldValue:self.otherContactFieldValue
                                completionBlock:self.completionBlock];


    OCMVerify([self.mockRequestFactory createContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockRequestContext setContactFieldValue:self.otherContactFieldValue]);
    OCMVerify([self.mockRequestContext setContactFieldId:self.contactFieldId]);
    OCMVerify([self.mockRequestContext setOpenIdToken:nil]);
    OCMVerify([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    OCMVerify([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
}

- (void)testSetContactWithContactFieldIdWithNewContactFieldValueCompletionBlockAndError {
    EMSRequestModel *requestModel = [self createRequestModel];
    NSError *testError = [NSError errorWithDomain:@"domain" code:500 userInfo:nil];
    
    OCMReject([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
    OCMReject([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);

    OCMStub([self.mockRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestContext contactFieldValue]).andReturn(self.contactFieldValue);
    OCMStub([self.mockRequestFactory createContactRequestModel]).andReturn(requestModel);
    OCMStub([self.mockRequestManager submitRequestModel:requestModel
                                    withCompletionBlock:([OCMArg invokeBlockWithArgs:testError, nil])]);

    [self.internal setContactWithContactFieldId:self.contactFieldId
                              contactFieldValue:self.otherContactFieldValue
                                completionBlock:self.completionBlock];


    OCMVerify([self.mockRequestFactory createContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockRequestContext setContactFieldValue:self.otherContactFieldValue]);
    OCMVerify([self.mockRequestContext setContactFieldId:self.contactFieldId]);
    OCMVerify([self.mockRequestContext setOpenIdToken:nil]);
    OCMVerify([self.mockRequestContext resetPreviousContactValues]);
    OCMVerify(never(), [self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);
    OCMVerify(never(), [self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
}

- (void)testSetContactWithContactFieldIdWithSameContactFieldValueCompletionBlock {
    EMSRequestModel *requestModel = [self createRequestModel];
    XCTestExpectation *expectation = [self expectationWithDescription:@"CompletionBlock was called."];
    EMSCompletionBlock completionBlock = ^(NSError *error) {
        [expectation fulfill];
    };
    OCMStub([self.mockRequestContext contactFieldValue]).andReturn(self.contactFieldValue);
    
    [self.internal setContactWithContactFieldId:self.contactFieldId
                              contactFieldValue:self.contactFieldValue
                                completionBlock:completionBlock];
    
    OCMVerify(never(), [self.mockRequestFactory createContactRequestModel]);
    OCMVerify(never(), [self.mockRequestManager submitRequestModel:requestModel
                                               withCompletionBlock:[OCMArg any]]);
    OCMVerify(never(), [self.mockRequestContext setContactFieldValue:self.contactFieldValue]);
    OCMVerify(never(), [self.mockRequestContext setContactFieldId:self.contactFieldId]);
    OCMVerify(never(), [self.mockRequestContext setOpenIdToken:nil]);
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testSetAuthenticatedContactWithNewIdTokenCompletionBlock_setIdTokenOnRequestContext {
    EMSRequestModel *requestModel = [self createRequestModel];
    NSString *idToken = @"testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken";
    NSString *newIdToken = @"newTestIdToken_newTestIdToken_newTestIdToken_newTestIdToken_newTestIdToken_newTestIdToken";

    OCMReject([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
    OCMReject([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);

    OCMStub([self.mockRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestContext openIdToken]).andReturn(idToken);
    OCMStub([self.mockRequestFactory createContactRequestModel]).andReturn(requestModel);

    [self.internal setAuthenticatedContactWithContactFieldId:@3
                                                 openIdToken:newIdToken
                                             completionBlock:self.completionBlock];

    OCMVerify([self.mockRequestFactory createContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockRequestContext setOpenIdToken:newIdToken]);
    OCMVerify([self.mockRequestContext setContactFieldValue:nil]);
}

- (void)testSetAuthenticatedContactWithNewIdTokenCompletionBlock_setIdTokenOnRequestContextWithError {
    EMSRequestModel *requestModel = [self createRequestModel];
    NSError *testError = [NSError errorWithDomain:@"domain" code:500 userInfo:nil];
    NSString *idToken = @"testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken";
    NSString *newIdToken = @"newTestIdToken_newTestIdToken_newTestIdToken_newTestIdToken_newTestIdToken_newTestIdToken";

    OCMReject([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
    OCMReject([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);

    OCMStub([self.mockRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestContext openIdToken]).andReturn(idToken);
    OCMStub([self.mockRequestFactory createContactRequestModel]).andReturn(requestModel);
    OCMStub([self.mockRequestManager submitRequestModel:requestModel
                                    withCompletionBlock:([OCMArg invokeBlockWithArgs:testError, nil])]);

    [self.internal setAuthenticatedContactWithContactFieldId:@3
                                                 openIdToken:newIdToken
                                             completionBlock:self.completionBlock];

    OCMVerify([self.mockRequestFactory createContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockRequestContext resetPreviousContactValues]);
    OCMVerify([self.mockRequestContext setContactFieldValue:nil]);
    OCMVerify(never(), [self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);
    OCMVerify(never(), [self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
}

- (void)testSetAuthenticatedContactWithSameIdTokenCompletionBlock_setIdTokenOnRequestContext {
    EMSRequestModel *requestModel = [self createRequestModel];
    NSString *idToken = @"testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken";
    XCTestExpectation *expectation = [self expectationWithDescription:@"CompletionBlock was called."];
    EMSCompletionBlock completionBlock = ^(NSError *error) {
        [expectation fulfill];
    };
    OCMStub([self.mockRequestContext openIdToken]).andReturn(idToken);

    [self.internal setAuthenticatedContactWithContactFieldId:@3
                                                 openIdToken:idToken
                                             completionBlock:completionBlock];

    OCMVerify(never(), [self.mockRequestFactory createContactRequestModel]);
    OCMVerify(never(), [self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify(never(), [self.mockRequestContext setOpenIdToken:idToken]);
    OCMVerify(never(), [self.mockRequestContext setContactFieldValue:nil]);
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testSetAuthenticatedContactWithIdTokenCompletionBlock_resetSession {
    EMSRequestModel *requestModel = [self createRequestModel];
    NSString *idToken = @"testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken";

    OCMStub([self.mockRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestFactory createContactRequestModel]).andReturn(requestModel);
    OCMStub([self.mockRequestManager submitRequestModel:requestModel
                                    withCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([self.mockSession stopSessionWithCompletionBlock:[OCMArg invokeBlock]]);

    [self.internal setAuthenticatedContactWithContactFieldId:@3
                                                 openIdToken:idToken
                                             completionBlock:self.completionBlock];
    [self waitATickOnOperationQueue:self.operationQueue];

    OCMVerify([self.mockRequestFactory createContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
}

- (void)testSetContactWithContactFieldValueCompletionBlock_resetSession {
    EMSRequestModel *requestModel = [self createRequestModel];

    OCMStub([self.mockRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestContext contactFieldValue]).andReturn(@"otherContactFieldValue");
    OCMStub([self.mockRequestFactory createContactRequestModel]).andReturn(requestModel);
    OCMStub([self.mockRequestManager submitRequestModel:requestModel
                                    withCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([self.mockSession stopSessionWithCompletionBlock:[OCMArg invokeBlock]]);

    [self.internal setContactWithContactFieldId:self.contactFieldId
                              contactFieldValue:self.contactFieldValue
                                completionBlock:self.completionBlock];
    
    [self waitATickOnOperationQueue:self.operationQueue];

    OCMVerify([self.mockRequestContext setContactFieldValue:self.contactFieldValue]);

    OCMVerify([self.mockRequestFactory createContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
}

- (void)testClearContact {
    EMSMobileEngageV3Internal *partialMockInternal = OCMPartialMock(self.internal);

    [partialMockInternal clearContact];

    OCMVerify([partialMockInternal clearContactWithCompletionBlock:nil];);
}

- (void)testClearContactWithCompletionBlockWhenContactTokenIsPresentAndContactIsSet {
    NSString *testContactToken = @"testContactToken_testContactToken_testContactToken_testContactToken_testContactToken";
    EMSRequestModel *requestModel = [self createRequestModel];
    
    OCMStub([self.mockRequestContext contactToken]).andReturn(testContactToken);
    OCMStub([self.mockRequestContext hasContactIdentification]).andReturn(YES);
    OCMStub([self.mockRequestFactory createContactRequestModel]).andReturn(requestModel);
    OCMStub([self.mockRequestManager submitRequestModel:requestModel
                                    withCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([self.mockSession stopSessionWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([self.mockSession startSessionWithCompletionBlock:[OCMArg invokeBlock]]);

    [self.internal clearContactWithCompletionBlock:self.completionBlock];
    
    [self waitATickOnOperationQueue:self.operationQueue];

    OCMVerify([self.mockStorage setData:nil
                                 forKey:@"EMSPushTokenKey"]);
    OCMVerify([self.mockRequestFactory createContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockRequestContext setContactFieldValue:nil]);
    OCMVerify([self.mockRequestContext setContactFieldId:nil]);
    OCMVerify([self.mockRequestContext setOpenIdToken:nil]);
    OCMVerify([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
}

-(void)testClearContactWithCompletionBlock_onErrorShouldResetRequestContextToPreviousValues {
    NSError *testError = [NSError errorWithDomain:@"domain" code:500 userInfo:nil];
    NSString *testContactToken = @"testContactToken_testContactToken_testContactToken_testContactToken_testContactToken";
    EMSRequestModel *requestModel = [self createRequestModel];
    
    OCMStub([self.mockRequestContext contactToken]).andReturn(testContactToken);
    OCMStub([self.mockRequestContext hasContactIdentification]).andReturn(YES);
    OCMStub([self.mockRequestFactory createContactRequestModel])
        .andReturn(requestModel);
    OCMStub([self.mockRequestManager submitRequestModel:requestModel
                                    withCompletionBlock:([OCMArg invokeBlockWithArgs:testError,
                                                          nil])]);

    [self.internal clearContactWithCompletionBlock:self.completionBlock];
    
    [self waitATickOnOperationQueue:self.operationQueue];

    OCMVerify(never(), [self.mockStorage setData:nil
                                 forKey:@"EMSPushTokenKey"]);
    OCMVerify([self.mockRequestFactory createContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockRequestContext setContactFieldValue:nil]);
    OCMVerify([self.mockRequestContext setContactFieldId:nil]);
    OCMVerify([self.mockRequestContext setOpenIdToken:nil]);
    OCMVerify(never(), [self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);
    OCMVerify(never(), [self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockRequestContext resetPreviousContactValues]);
}

- (void)testClearContactWithCompletionBlockWhenContactTokenIsMissing {
    EMSRequestModel *requestModel = [self createRequestModel];
    
    OCMStub([self.mockRequestContext contactToken]).andReturn(nil);
    OCMStub([self.mockRequestFactory createContactRequestModel]).andReturn(requestModel);
    OCMStub([self.mockRequestManager submitRequestModel:requestModel
                                    withCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([self.mockSession stopSessionWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([self.mockSession startSessionWithCompletionBlock:[OCMArg invokeBlock]]);

    [self.internal clearContactWithCompletionBlock:self.completionBlock];
    
    [self waitATickOnOperationQueue:self.operationQueue];

    OCMVerify([self.mockStorage setData:nil
                                 forKey:@"EMSPushTokenKey"]);
    OCMVerify([self.mockRequestFactory createContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockRequestContext setContactFieldValue:nil]);
    OCMVerify([self.mockRequestContext setContactFieldId:nil]);
    OCMVerify([self.mockRequestContext setOpenIdToken:nil]);
    OCMVerify([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
}

- (void)testClearContactWithCompletionBlockWhenAnonymousContactIsSet_shouldNotSendRequest {
    NSString *anonymousContactToken = @"this is an anonymous contact token";
    XCTestExpectation *expectation = [self expectationWithDescription:@"CallCompletion was called"];
    EMSRequestModel *requestModel = [self createRequestModel];
    
    OCMStub([self.mockRequestContext contactToken])
        .andReturn(anonymousContactToken);
    OCMStub([self.mockRequestContext hasContactIdentification]).andReturn(NO);

    [self.internal clearContactWithCompletionBlock:^(NSError *error) {
        [expectation fulfill];
    }];
    
    [self waitATickOnOperationQueue:self.operationQueue];

    OCMVerify(never(), [self.mockStorage setData:nil
                                          forKey:@"EMSPushTokenKey"]);
    OCMVerify(never(), [self.mockRequestFactory createContactRequestModel]);
    OCMVerify(never(), [self.mockRequestManager submitRequestModel:requestModel
                         withCompletionBlock:[OCMArg any]]);
    OCMVerify(never(), [self.mockRequestContext setContactFieldValue:nil]);
    OCMVerify(never(), [self.mockRequestContext setContactFieldId:nil]);
    OCMVerify(never(), [self.mockRequestContext setOpenIdToken:nil]);
    OCMVerify(never(),
              [self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);
    OCMVerify(never(),
              [self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testTrackCustomEventWithNameEventAttributes_eventName_mustNotBeNil {
    @try {
        [self.internal trackCustomEventWithName:nil
                                eventAttributes:@{}];
        XCTFail(@"Expected Exception when eventName is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: eventName");
    }
}

- (void)testTrackCustomEventWithNameEventAttributesCompletionBlock_eventName_mustNotBeNil {
    @try {
        [self.internal trackCustomEventWithName:nil
                                eventAttributes:@{}
                                completionBlock:self.completionBlock];
        XCTFail(@"Expected Exception when eventName is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: eventName");
    }
}

- (void)testTrackCustomEventWithNameEventAttributes {
    EMSMobileEngageV3Internal *partialMockInternal = OCMPartialMock(self.internal);

    [partialMockInternal trackCustomEventWithName:self.eventName
                                  eventAttributes:self.eventAttributes];

    OCMVerify([partialMockInternal trackCustomEventWithName:self.eventName
                                            eventAttributes:self.eventAttributes
                                            completionBlock:nil]);
}

- (void)testTrackCustomEventWithNameEventAttributesCompletionBlock {
    EMSRequestModel *requestModel = [self createRequestModel];

    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:self.eventName
                                                          eventAttributes:self.eventAttributes
                                                                eventType:EventTypeCustom]).andReturn(requestModel);

    [self.internal trackCustomEventWithName:self.eventName
                            eventAttributes:self.eventAttributes
                            completionBlock:self.completionBlock];

    OCMVerify([self.mockRequestFactory createEventRequestModelWithEventName:self.eventName
                                                            eventAttributes:self.eventAttributes
                                                                  eventType:EventTypeCustom]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:self.completionBlock]);
}

- (EMSRequestModel *)createRequestModel {
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"https://www.emarsys.com"];
            }
                          timestampProvider:self.timestampProvider
                               uuidProvider:self.uuidProvider];
}

@end
