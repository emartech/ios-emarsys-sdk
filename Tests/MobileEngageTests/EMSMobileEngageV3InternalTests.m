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

- (void)testSetContactWithContactFieldValueCompletionBlock {
    EMSRequestModel *requestModel = [self createRequestModel];

    OCMReject([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
    OCMReject([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);

    OCMStub([self.mockRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestContext contactFieldValue]).andReturn(self.contactFieldValue);
    OCMStub([self.mockRequestFactory createContactRequestModel]).andReturn(requestModel);
    OCMStub([self.mockRequestManager submitRequestModel:requestModel
                                    withCompletionBlock:[OCMArg invokeBlock]]);

    [self.internal setContactWithContactFieldId:self.contactFieldId
                              contactFieldValue:self.contactFieldValue
                                completionBlock:self.completionBlock];


    OCMVerify([self.mockRequestFactory createContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockRequestContext setContactFieldValue:self.contactFieldValue]);
    OCMVerify([self.mockRequestContext setContactFieldId:self.contactFieldId]);
    OCMVerify([self.mockRequestContext setOpenIdToken:nil]);
}

- (void)testSetAuthenticatedContactWithIdTokenCompletionBlock_setIdTokenOnRequestContext {
    EMSRequestModel *requestModel = [self createRequestModel];
    NSString *newIdToken = @"testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken";

    OCMReject([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
    OCMReject([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);

    OCMStub([self.mockRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestContext openIdToken]).andReturn(newIdToken);
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

- (void)testClearContactWithCompletionBlock {
    EMSMobileEngageV3Internal *partialMockInternal = OCMPartialMock(self.internal);
    OCMStub([self.mockSession stopSessionWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([partialMockInternal setContactWithContactFieldId:nil
                                            contactFieldValue:nil
                                              completionBlock:[OCMArg invokeBlock]]);

    [partialMockInternal clearContactWithCompletionBlock:self.completionBlock];
    
    [self waitATickOnOperationQueue:self.operationQueue];

    OCMVerify([self.mockStorage setData:nil
                                 forKey:@"EMSPushTokenKey"]);
    OCMVerify([partialMockInternal setContactWithContactFieldId:nil
                                              contactFieldValue:nil
                                                completionBlock:[OCMArg any]]);
    OCMVerify([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
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
