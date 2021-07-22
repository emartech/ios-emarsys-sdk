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

@interface EMSMobileEngageV3InternalTests : XCTestCase

@property(nonatomic, strong) EMSMobileEngageV3Internal *internal;
@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;
@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) MERequestContext *mockRequestContext;
@property(nonatomic, strong) EMSSession *mockSession;
@property(nonatomic, strong) EMSStorage *mockStorage;
@property(nonatomic, strong) NSString *contactFieldValue;
@property(nonatomic, strong) NSNumber *contactFieldId;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *uuidProvider;
@property(nonatomic, strong) NSString *eventName;
@property(nonatomic, strong) NSDictionary *eventAttributes;
@property(nonatomic, copy) void (^completionBlock)(NSError *);

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

    _internal = [[EMSMobileEngageV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                                           requestManager:self.mockRequestManager
                                                           requestContext:self.mockRequestContext
                                                                  storage:self.mockStorage
                                                                  session:self.mockSession];
}

- (void)testInit_requestFactory_mustNotBeNil {
    @try {
        [[EMSMobileEngageV3Internal alloc] initWithRequestFactory:nil
                                                   requestManager:self.mockRequestManager
                                                   requestContext:self.mockRequestContext
                                                          storage:self.mockStorage
                                                          session:self.mockSession];
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
                                                          session:self.mockSession];
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
                                                          session:self.mockSession];
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
                                                          session:self.mockSession];
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
                                                          session:nil];
        XCTFail(@"Expected Exception when session is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: session");
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

    OCMReject([self.mockSession startSession]);
    OCMReject([self.mockSession stopSession]);

    OCMStub([self.mockRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestContext contactFieldValue]).andReturn(self.contactFieldValue);
    OCMStub([self.mockRequestFactory createContactRequestModel]).andReturn(requestModel);

    [self.internal setContactWithContactFieldId:self.contactFieldId
                              contactFieldValue:self.contactFieldValue
                                completionBlock:self.completionBlock];


    OCMVerify([self.mockRequestFactory createContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:self.completionBlock]);
    OCMVerify([self.mockRequestContext setContactFieldValue:self.contactFieldValue]);
    OCMVerify([self.mockRequestContext setContactFieldId:self.contactFieldId]);
    OCMVerify([self.mockRequestContext setOpenIdToken:nil]);
}

- (void)testSetAuthenticatedContactWithIdTokenCompletionBlock_setIdTokenOnRequestContext {
    EMSRequestModel *requestModel = [self createRequestModel];
    NSString *newIdToken = @"testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken";

    OCMReject([self.mockSession startSession]);
    OCMReject([self.mockSession stopSession]);

    OCMStub([self.mockRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestContext openIdToken]).andReturn(newIdToken);
    OCMStub([self.mockRequestFactory createContactRequestModel]).andReturn(requestModel);

    [self.internal setAuthenticatedContactWithOpenIdToken:newIdToken
                                          completionBlock:self.completionBlock];

    OCMVerify([self.mockRequestFactory createContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:self.completionBlock]);
    OCMVerify([self.mockRequestContext setOpenIdToken:newIdToken]);
    OCMVerify([self.mockRequestContext setContactFieldValue:nil]);
}

- (void)testSetAuthenticatedContactWithIdTokenCompletionBlock_resetSession {
    EMSRequestModel *requestModel = [self createRequestModel];
    NSString *idToken = @"testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken";

    OCMStub([self.mockRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestFactory createContactRequestModel]).andReturn(requestModel);

    [self.internal setAuthenticatedContactWithOpenIdToken:idToken
                                          completionBlock:self.completionBlock];

    OCMVerify([self.mockRequestFactory createContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:self.completionBlock]);
    OCMVerify([self.mockSession stopSession]);
    OCMVerify([self.mockSession startSession]);
}

- (void)testSetContactWithContactFieldValueCompletionBlock_resetSession {
    EMSRequestModel *requestModel = [self createRequestModel];

    OCMStub([self.mockRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestContext contactFieldValue]).andReturn(@"otherContactFieldValue");
    OCMStub([self.mockRequestFactory createContactRequestModel]).andReturn(requestModel);

    [self.internal setContactWithContactFieldId:self.contactFieldId
                              contactFieldValue:self.contactFieldValue
                                completionBlock:self.completionBlock];

    OCMVerify([self.mockRequestContext setContactFieldValue:self.contactFieldValue]);

    OCMVerify([self.mockRequestFactory createContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:self.completionBlock]);
    OCMVerify([self.mockSession stopSession]);
    OCMVerify([self.mockSession startSession]);
}

- (void)testClearContact {
    EMSMobileEngageV3Internal *partialMockInternal = OCMPartialMock(self.internal);

    [partialMockInternal clearContact];

    OCMVerify([partialMockInternal clearContactWithCompletionBlock:nil];);
}

- (void)testClearContactWithCompletionBlock {
    EMSMobileEngageV3Internal *partialMockInternal = OCMPartialMock(self.internal);

    OCMStub([partialMockInternal setContactWithContactFieldId:nil
                                            contactFieldValue:nil
                                              completionBlock:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        OCMVerify([self.mockRequestContext reset]);
    });

    [partialMockInternal clearContactWithCompletionBlock:self.completionBlock];

    OCMVerify([self.mockStorage setData:nil
                                 forKey:@"EMSPushTokenKey"]);
    OCMVerify([partialMockInternal setContactWithContactFieldId:nil
                                              contactFieldValue:nil
                                                completionBlock:self.completionBlock]);
    OCMVerify([self.mockSession stopSession]);
    OCMVerify([self.mockSession startSession]);
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
