////
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSContactClientInternal.h"
#import "EMSRequestFactory.h"
#import "EMSRequestManager.h"
#import "MERequestContext.h"
#import "PRERequestContext.h"
#import "EMSStorageProtocol.h"
#import "EMSSession.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "MEExperimental+Test.h"
#import "EMSInnerFeature.h"
#import "EMSCompletionBlockProvider.h"
#import "XCTestCase+Helper.h"

@interface EMSContactClientInternalTests : XCTestCase

@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;
@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) MERequestContext *mockRequestContext;
@property(nonatomic, strong) PRERequestContext *mockPredictRequestContext;
@property(nonatomic, strong) id<EMSStorageProtocol>mockStorage;
@property(nonatomic, strong) EMSSession *mockSession;
@property(nonatomic, strong) EMSCompletionBlockProvider *completionBlockProvider;

@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *uuidProvider;

@property(nonatomic, strong) NSNumber *contactFieldId;
@property(nonatomic, strong) NSString *contactFieldValue;
@property(nonatomic, strong) NSString *otherContactFieldValue;
@property(nonatomic, copy) void (^completionBlock)(NSError *);

@property(nonatomic, strong) EMSContactClientInternal *internal;
@property(nonatomic, strong) NSOperationQueue *queue;

@end

@implementation EMSContactClientInternalTests

- (void)setUp {
    _timestampProvider = [EMSTimestampProvider new];
    _uuidProvider = [EMSUUIDProvider new];
    
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockRequestContext = OCMClassMock([MERequestContext class]);
    _mockPredictRequestContext = OCMClassMock([PRERequestContext class]);
    _mockStorage = OCMProtocolMock(@protocol(EMSStorageProtocol));
    _mockSession = OCMClassMock([EMSSession class]);
    
    _contactFieldId = @42;
    _contactFieldValue = @"testContactFieldValue";
    _otherContactFieldValue = @"otherContactFieldValue";
    _completionBlock = ^(NSError *error) {
    };
    
    _queue = [self createTestOperationQueue];
    _completionBlockProvider = [[EMSCompletionBlockProvider alloc] initWithOperationQueue:self.queue];
    
    _internal = [[EMSContactClientInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                                          requestManager:self.mockRequestManager
                                                          requestContext:self.mockRequestContext
                                                   predictRequestContext:self.mockPredictRequestContext
                                                                 storage:self.mockStorage
                                                                 session:self.mockSession
                                                 completionBlockProvider:self.completionBlockProvider];
}

- (void)tearDown {
    [MEExperimental reset];
}

- (void)testRequestFactory_shouldNotBeNil {
    @try {
        [[EMSContactClientInternal alloc] initWithRequestFactory:nil
                                                  requestManager:self.mockRequestManager
                                                  requestContext:self.mockRequestContext
                                           predictRequestContext:self.mockPredictRequestContext
                                                         storage:self.mockStorage
                                                         session:self.mockSession
                                         completionBlockProvider:self.completionBlockProvider];
        XCTFail(@"Expected Exception when requestFactory is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestFactory");
    }
}

- (void)testRequestManager_shouldNotBeNil {
    @try {
        [[EMSContactClientInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                                  requestManager:nil
                                                  requestContext:self.mockRequestContext
                                           predictRequestContext:self.mockPredictRequestContext
                                                         storage:self.mockStorage
                                                         session:self.mockSession
                                         completionBlockProvider:self.completionBlockProvider];
        XCTFail(@"Expected Exception when requestManager is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestManager");
    }
}

- (void)testRequestContext_shouldNotBeNil {
    @try {
        [[EMSContactClientInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                                  requestManager:self.mockRequestManager
                                                  requestContext:nil
                                           predictRequestContext:self.mockPredictRequestContext
                                                         storage:self.mockStorage
                                                         session:self.mockSession
                                         completionBlockProvider:self.completionBlockProvider];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestContext");
    }
}

- (void)testPredictRequestContext_shouldNotBeNil {
    @try {
        [[EMSContactClientInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                                  requestManager:self.mockRequestManager
                                                  requestContext:self.mockRequestContext
                                           predictRequestContext:nil
                                                         storage:self.mockStorage
                                                         session:self.mockSession
                                         completionBlockProvider:self.completionBlockProvider];
        XCTFail(@"Expected Exception when predictRequestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: predictRequestContext");
    }
}

- (void)testStorage_shouldNotBeNil {
    @try {
        [[EMSContactClientInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                                  requestManager:self.mockRequestManager
                                                  requestContext:self.mockRequestContext
                                           predictRequestContext:self.mockPredictRequestContext
                                                         storage:nil
                                                         session:self.mockSession
                                         completionBlockProvider:self.completionBlockProvider];
        XCTFail(@"Expected Exception when storage is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: storage");
    }
}

- (void)testSession_shouldNotBeNil {
    @try {
        [[EMSContactClientInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                                  requestManager:self.mockRequestManager
                                                  requestContext:self.mockRequestContext
                                           predictRequestContext:self.mockPredictRequestContext
                                                         storage:self.mockStorage
                                                         session:nil
                                         completionBlockProvider:self.completionBlockProvider];
        XCTFail(@"Expected Exception when session is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: session");
    }
}

- (void)testCompletionBlockProvider_shouldNotBeNil {
    @try {
        [[EMSContactClientInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                                  requestManager:self.mockRequestManager
                                                  requestContext:self.mockRequestContext
                                           predictRequestContext:self.mockPredictRequestContext
                                                         storage:self.mockStorage
                                                         session:self.mockSession
                                         completionBlockProvider:nil];
        XCTFail(@"Expected Exception when completionBlockProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: completionBlockProvider");
    }
}

- (void)testSetContactWithContactFieldValue {
    EMSContactClientInternal *partialMockInternal = OCMPartialMock(self.internal);

    [partialMockInternal setContactWithContactFieldId:self.contactFieldId
                                    contactFieldValue:self.contactFieldValue];
    
    [self waitATickOnOperationQueue:self.queue];

    OCMVerify([partialMockInternal setContactWithContactFieldId:self.contactFieldId
                                              contactFieldValue:self.contactFieldValue
                                                completionBlock:nil]);
}

- (void)testSetContactWithContactFieldIdWithNewContactFieldValueCompletionBlock {
    [MEExperimental enableFeature:EMSInnerFeature.mobileEngage];
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

    [self waitATickOnOperationQueue:self.queue];

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
    [MEExperimental enableFeature:EMSInnerFeature.mobileEngage];
    EMSRequestModel *requestModel = [self createRequestModel];
    NSError *testError = [NSError errorWithDomain:@"domain" code:500 userInfo:nil];

    OCMReject([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
    OCMReject([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);

    OCMStub([self.mockRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestContext contactFieldValue]).andReturn(self.contactFieldValue);
    OCMStub([self.mockRequestFactory createContactRequestModel]).andReturn(requestModel);
    OCMStub([self.mockRequestManager submitRequestModel:requestModel
                                    withCompletionBlock:([OCMArg invokeBlockWithArgs:testError, nil])]);
    OCMReject([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);
    OCMReject([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);

    [self.internal setContactWithContactFieldId:self.contactFieldId
                              contactFieldValue:self.otherContactFieldValue
                                completionBlock:self.completionBlock];

    [self waitATickOnOperationQueue:self.queue];

    OCMVerify([self.mockRequestFactory createContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockRequestContext setContactFieldValue:self.otherContactFieldValue]);
    OCMVerify([self.mockRequestContext setContactFieldId:self.contactFieldId]);
    OCMVerify([self.mockRequestContext setOpenIdToken:nil]);
    OCMVerify([self.mockRequestContext resetPreviousContactValues]);
}

- (void)testSetContactWithContactFieldIdWithSameContactFieldValueCompletionBlock {
    [MEExperimental enableFeature:EMSInnerFeature.mobileEngage];
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
    [MEExperimental enableFeature:EMSInnerFeature.mobileEngage];
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
    [MEExperimental enableFeature:EMSInnerFeature.mobileEngage];
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
    OCMReject([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);
    OCMReject([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);

    [self.internal setAuthenticatedContactWithContactFieldId:@3
                                                 openIdToken:newIdToken
                                             completionBlock:self.completionBlock];

    OCMVerify([self.mockRequestFactory createContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockRequestContext resetPreviousContactValues]);
    OCMVerify([self.mockRequestContext setContactFieldValue:nil]);
}

- (void)testSetAuthenticatedContactWithSameIdTokenCompletionBlock_setIdTokenOnRequestContext {
    [MEExperimental enableFeature:EMSInnerFeature.mobileEngage];
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

- (void)testSetContactWithContactFieldValueCompletionBlock_predict {
    [MEExperimental enableFeature:EMSInnerFeature.predict];
    EMSRequestModel *requestModel = [self createRequestModel];

    OCMReject([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
    OCMReject([self.mockSession stopSessionWithCompletionBlock:[OCMArg invokeBlock]]);

    OCMStub([self.mockRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestContext contactFieldValue]).andReturn(self.contactFieldValue);
    OCMStub([self.mockRequestFactory createPredictOnlyContactRequestModelWithRefresh:NO]).andReturn(requestModel);
    OCMStub([self.mockRequestManager submitRequestModel:requestModel
                                    withCompletionBlock:[OCMArg invokeBlock]]);

    [self.internal setContactWithContactFieldId:self.contactFieldId
                              contactFieldValue:self.otherContactFieldValue
                                completionBlock:self.completionBlock];

    [self waitATickOnOperationQueue:self.queue];
    
    OCMVerify([self.mockRequestFactory createPredictOnlyContactRequestModelWithRefresh:NO]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockRequestContext setContactFieldValue:self.otherContactFieldValue]);
    OCMVerify([self.mockRequestContext setContactFieldId:self.contactFieldId]);
    OCMVerify([self.mockRequestContext setOpenIdToken:nil]);
}

- (void)testSetAuthenticatedContactWithIdTokenCompletionBlock_setIdTokenOnRequestContext {
    [MEExperimental enableFeature:EMSInnerFeature.mobileEngage];
    EMSRequestModel *requestModel = [self createRequestModel];
    NSString *idToken = @"testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken";
    NSString *newIdToken = @"newTestIdToken_newTestIdToken_newTestIdToken_newTestIdToken_newTestIdToken_newTestIdToken";

    OCMReject([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
    OCMReject([self.mockSession stopSessionWithCompletionBlock:[OCMArg invokeBlock]]);

    OCMStub([self.mockRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestContext openIdToken]).andReturn(idToken);
    OCMStub([self.mockRequestFactory createContactRequestModel]).andReturn(requestModel);

    [self.internal setAuthenticatedContactWithContactFieldId:@3
                                                 openIdToken:newIdToken
                                             completionBlock:self.completionBlock];
    
    [self waitATickOnOperationQueue:self.queue];

    OCMVerify([self.mockRequestFactory createContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockRequestContext setOpenIdToken:newIdToken]);
    OCMVerify([self.mockRequestContext setContactFieldValue:nil]);
    OCMVerify([self.mockRequestContext setContactFieldId:@3]);
}

- (void)testSetAuthenticatedContactWithIdTokenCompletionBlock_setIdTokenOnRequestContext_predict {
    [MEExperimental enableFeature:EMSInnerFeature.predict];
    EMSRequestModel *requestModel = [self createRequestModel];
    NSString *idToken = @"testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken";
    NSString *newIdToken = @"newTestIdToken_newTestIdToken_newTestIdToken_newTestIdToken_newTestIdToken_newTestIdToken";

    OCMReject([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
    OCMReject([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);

    OCMStub([self.mockRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestContext openIdToken]).andReturn(idToken);
    OCMStub([self.mockRequestFactory createPredictOnlyContactRequestModelWithRefresh:NO]).andReturn(requestModel);

    [self.internal setAuthenticatedContactWithContactFieldId:@3
                                                 openIdToken:newIdToken
                                             completionBlock:self.completionBlock];
    
    [self waitATickOnOperationQueue:self.queue];

    OCMVerify([self.mockRequestFactory createPredictOnlyContactRequestModelWithRefresh:NO]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockRequestContext setOpenIdToken:newIdToken]);
    OCMVerify([self.mockRequestContext setContactFieldValue:nil]);
    OCMVerify([self.mockRequestContext setContactFieldId:@3]);
}

- (void)testSetAuthenticatedContactWithIdTokenCompletionBlock_resetSession {
    [MEExperimental enableFeature:EMSInnerFeature.mobileEngage];
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

    [self waitATickOnOperationQueue:self.queue];

    OCMVerify([self.mockRequestFactory createContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
}

- (void)testSetAuthenticatedContactWithIdTokenCompletionBlock_resetSession_predict {
    [MEExperimental enableFeature:EMSInnerFeature.predict];
    EMSRequestModel *requestModel = [self createRequestModel];
    NSString *idToken = @"testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken";

    OCMStub([self.mockRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockPredictRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestFactory createPredictOnlyContactRequestModelWithRefresh:NO]).andReturn(requestModel);
    OCMStub([self.mockRequestManager submitRequestModel:requestModel
                                    withCompletionBlock:[OCMArg invokeBlock]]);
    OCMReject([self.mockSession stopSessionWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMReject([self.mockSession startSessionWithCompletionBlock:[OCMArg invokeBlock]]);

    [self.internal setAuthenticatedContactWithContactFieldId:@3
                                                 openIdToken:idToken
                                             completionBlock:self.completionBlock];
    [self waitATickOnOperationQueue:self.queue];

    OCMVerify([self.mockRequestFactory createPredictOnlyContactRequestModelWithRefresh:NO]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
}

- (void)testSetContactWithContactFieldValueCompletionBlock_resetSession {
    [MEExperimental enableFeature:EMSInnerFeature.mobileEngage];
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
    [self waitATickOnOperationQueue:self.queue];

    OCMVerify([self.mockRequestContext setContactFieldValue:self.contactFieldValue]);

    OCMVerify([self.mockRequestFactory createContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
}

- (void)testSetContactWithContactFieldValueCompletionBlock_resetSession_predict {
    [MEExperimental enableFeature:EMSInnerFeature.predict];
    [MEExperimental disableFeature:EMSInnerFeature.mobileEngage];
    EMSRequestModel *requestModel = [self createRequestModel];

    OCMStub([self.mockRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestContext contactFieldValue]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestFactory createPredictOnlyContactRequestModelWithRefresh:NO]).andReturn(requestModel);
    OCMStub([self.mockRequestManager submitRequestModel:requestModel
                                    withCompletionBlock:[OCMArg invokeBlock]]);
    OCMReject([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);
    OCMReject([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);

    [self.internal setContactWithContactFieldId:self.contactFieldId
                              contactFieldValue:self.otherContactFieldValue
                                completionBlock:self.completionBlock];
    [self waitATickOnOperationQueue:self.queue];

    OCMVerify([self.mockRequestContext setContactFieldValue:self.otherContactFieldValue]);

    OCMVerify([self.mockRequestFactory createPredictOnlyContactRequestModelWithRefresh:NO]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
}

- (void)testClearContact {
    EMSContactClientInternal *partialMockInternal = OCMPartialMock(self.internal);

    [partialMockInternal clearContact];

    OCMVerify([partialMockInternal clearContactWithCompletionBlock:nil];);
}

- (void)testClearContactWithCompletionBlockWhenContactTokenIsPresentAndContactIsSet {
    [MEExperimental enableFeature:EMSInnerFeature.mobileEngage];
    NSString *testContactToken = @"testContactToken_testContactToken_testContactToken_testContactToken_testContactToken";
    EMSRequestModel *requestModel = [self createRequestModel];

    OCMStub([self.mockRequestContext contactToken]).andReturn(testContactToken);
    OCMStub([self.mockRequestContext hasContactIdentification]).andReturn(YES);
    OCMStub([self.mockRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestContext contactFieldValue]).andReturn(self.contactFieldValue);
    OCMStub([self.mockRequestFactory createContactRequestModel]).andReturn(requestModel);
    OCMStub([self.mockRequestManager submitRequestModel:requestModel
                                    withCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([self.mockSession stopSessionWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([self.mockSession startSessionWithCompletionBlock:[OCMArg invokeBlock]]);
    
    [self.internal clearContactWithCompletionBlock:self.completionBlock];
    
    [self waitATickOnOperationQueue:self.queue];

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

- (void)testClearContactWithCompletionBlock_predict {
    [MEExperimental enableFeature:EMSInnerFeature.predict];

    EMSRequestModel *requestModel = [self createRequestModel];

    OCMStub([self.mockRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestContext contactFieldValue]).andReturn(self.contactFieldValue);
    OCMStub([self.mockRequestFactory createPredictOnlyClearContactRequestModel]).andReturn(requestModel);
    OCMReject([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);
    OCMReject([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
    OCMStub([self.mockRequestManager submitRequestModel:[OCMArg any]
                                    withCompletionBlock:[OCMArg invokeBlock]]);
    
    [self.internal clearContactWithCompletionBlock:self.completionBlock];
    
    [self waitATickOnOperationQueue:self.queue];

    OCMVerify([self.mockRequestFactory createPredictOnlyClearContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
}

-(void)testClearContactWithCompletionBlock_onErrorShouldResetRequestContextToPreviousValues {
    [MEExperimental enableFeature:EMSInnerFeature.mobileEngage];
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
    OCMReject([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);
    OCMReject([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);

    [self.internal clearContactWithCompletionBlock:self.completionBlock];

    [self waitATickOnOperationQueue:self.queue];

    OCMVerify(never(), [self.mockStorage setData:nil
                                 forKey:@"EMSPushTokenKey"]);
    OCMVerify([self.mockRequestFactory createContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockRequestContext setContactFieldValue:nil]);
    OCMVerify([self.mockRequestContext setContactFieldId:nil]);
    OCMVerify([self.mockRequestContext setOpenIdToken:nil]);
    OCMVerify([self.mockRequestContext resetPreviousContactValues]);
}

-(void)testClearContactWithCompletionBlock_onErrorShouldResetRequestContextToPreviousValues_predict {
    [MEExperimental enableFeature:EMSInnerFeature.predict];
    NSError *testError = [NSError errorWithDomain:@"domain" code:500 userInfo:nil];
    NSString *testContactToken = @"testContactToken_testContactToken_testContactToken_testContactToken_testContactToken";
    EMSRequestModel *requestModel = [self createRequestModel];

    OCMStub([self.mockRequestContext contactToken]).andReturn(testContactToken);
    OCMStub([self.mockRequestContext hasContactIdentification]).andReturn(YES);
    OCMStub([self.mockRequestFactory createPredictOnlyClearContactRequestModel])
        .andReturn(requestModel);
    OCMStub([self.mockRequestManager submitRequestModel:requestModel
                                    withCompletionBlock:([OCMArg invokeBlockWithArgs:testError,
                                                          nil])]);
    OCMReject([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);
    OCMReject([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);

    [self.internal clearContactWithCompletionBlock:self.completionBlock];

    [self waitATickOnOperationQueue:self.queue];

    OCMVerify(never(), [self.mockStorage setData:nil
                                 forKey:@"EMSPushTokenKey"]);
    OCMVerify([self.mockRequestFactory createPredictOnlyClearContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
}

- (void)testClearContactWithCompletionBlockWhenContactTokenIsMissing {
    [MEExperimental enableFeature:EMSInnerFeature.mobileEngage];
    EMSRequestModel *requestModel = [self createRequestModel];

    OCMStub([self.mockRequestContext contactToken]).andReturn(nil);
    OCMStub([self.mockRequestFactory createContactRequestModel]).andReturn(requestModel);
    OCMStub([self.mockRequestManager submitRequestModel:requestModel
                                    withCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([self.mockSession stopSessionWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([self.mockSession startSessionWithCompletionBlock:[OCMArg invokeBlock]]);

    [self.internal clearContactWithCompletionBlock:self.completionBlock];

    [self waitATickOnOperationQueue:self.queue];

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

- (void)testClearContactWithCompletionBlockWhenContactTokenIsMissing_predict {
    [MEExperimental enableFeature:EMSInnerFeature.predict];
    EMSRequestModel *requestModel = [self createRequestModel];

    OCMStub([self.mockRequestContext contactToken]).andReturn(nil);
    OCMStub([self.mockRequestFactory createPredictOnlyClearContactRequestModel]).andReturn(requestModel);
    OCMStub([self.mockRequestManager submitRequestModel:requestModel
                                    withCompletionBlock:[OCMArg invokeBlock]]);
    OCMReject([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);
    OCMReject([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);

    [self.internal clearContactWithCompletionBlock:self.completionBlock];

    [self waitATickOnOperationQueue:self.queue];

    OCMVerify([self.mockRequestFactory createPredictOnlyClearContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockRequestContext reset]);
}

- (void)testClearContactWithCompletionBlockWhenAnonymousContactIsSet_shouldNotSendRequest {
    [MEExperimental enableFeature:EMSInnerFeature.mobileEngage];
    NSString *anonymousContactToken = @"this is an anonymous contact token";
    XCTestExpectation *expectation = [self expectationWithDescription:@"CallCompletion was called"];
    EMSRequestModel *requestModel = [self createRequestModel];

    OCMStub([self.mockRequestContext contactToken])
        .andReturn(anonymousContactToken);
    OCMStub([self.mockRequestContext hasContactIdentification]).andReturn(NO);
    OCMReject([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);
    OCMReject([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);

    [self.internal clearContactWithCompletionBlock:^(NSError *error) {
        [expectation fulfill];
    }];

    [self waitATickOnOperationQueue:self.queue];

    OCMVerify(never(), [self.mockStorage setData:nil
                                          forKey:@"EMSPushTokenKey"]);
    OCMVerify(never(), [self.mockRequestFactory createContactRequestModel]);
    OCMVerify(never(), [self.mockRequestManager submitRequestModel:requestModel
                         withCompletionBlock:[OCMArg any]]);
    OCMVerify(never(), [self.mockRequestContext setContactFieldValue:nil]);
    OCMVerify(never(), [self.mockRequestContext setContactFieldId:nil]);
    OCMVerify(never(), [self.mockRequestContext setOpenIdToken:nil]);
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testClearContactWithCompletionBlockWhenAnonymousContactIsSet_shouldNotSendRequest_predict {
    [MEExperimental enableFeature:EMSInnerFeature.predict];
    NSString *anonymousContactToken = @"this is an anonymous contact token";
    XCTestExpectation *expectation = [self expectationWithDescription:@"CallCompletion was called"];
    EMSRequestModel *requestModel = [self createRequestModel];

    OCMStub([self.mockRequestContext contactToken])
        .andReturn(anonymousContactToken);
    OCMStub([self.mockRequestContext hasContactIdentification]).andReturn(NO);
    OCMReject([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);
    OCMReject([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);

    [self.internal clearContactWithCompletionBlock:^(NSError *error) {
        [expectation fulfill];
    }];

    [self waitATickOnOperationQueue:self.queue];

    OCMVerify(never(), [self.mockRequestFactory createPredictOnlyClearContactRequestModel]);
    OCMVerify(never(), [self.mockRequestManager submitRequestModel:requestModel
                         withCompletionBlock:[OCMArg any]]);
    OCMVerify(never(), [self.mockRequestContext reset]);
    [self waitForExpectationsWithTimeout:1 handler:nil];
}


- (EMSRequestModel *)createRequestModel {
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"https://www.emarsys.com"];
            }
                          timestampProvider:self.timestampProvider
                               uuidProvider:self.uuidProvider];
}


@end
