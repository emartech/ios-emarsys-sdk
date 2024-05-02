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

@interface EMSContactClientInternalTests : XCTestCase

@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;
@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) MERequestContext *mockRequestContext;
@property(nonatomic, strong) PRERequestContext *mockPredictRequestContext;
@property(nonatomic, strong) id<EMSStorageProtocol>mockStorage;
@property(nonatomic, strong) EMSSession *mockSession;

@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *uuidProvider;

@property(nonatomic, strong) NSNumber *contactFieldId;
@property(nonatomic, strong) NSString *contactFieldValue;
@property(nonatomic, copy) void (^completionBlock)(NSError *);

@property(nonatomic, strong) EMSContactClientInternal *internal;

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
    _completionBlock = ^(NSError *error) {
    };
    
    _internal = [[EMSContactClientInternal alloc] initWithRequestFactory:self.mockRequestFactory
                                                          requestManager:self.mockRequestManager
                                                          requestContext:self.mockRequestContext
                                                   predictRequestContext:self.mockPredictRequestContext
                                                                 storage:self.mockStorage
                                                                 session:self.mockSession];
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
                                                         session:self.mockSession];
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
                                                         session:self.mockSession];
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
                                                         session:self.mockSession];
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
                                                         session:self.mockSession];
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
                                                         session:self.mockSession];
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
                                                         session:nil];
        XCTFail(@"Expected Exception when session is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: session");
    }
}

- (void)testSetContactWithContactFieldValue {
    EMSContactClientInternal *partialMockInternal = OCMPartialMock(self.internal);

    [partialMockInternal setContactWithContactFieldId:self.contactFieldId
                                    contactFieldValue:self.contactFieldValue];

    OCMVerify([partialMockInternal setContactWithContactFieldId:self.contactFieldId
                                              contactFieldValue:self.contactFieldValue
                                                completionBlock:nil]);
}

- (void)testSetContactWithContactFieldValueCompletionBlock {
    [MEExperimental enableFeature:EMSInnerFeature.mobileEngage];
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

- (void)testSetContactWithContactFieldValueCompletionBlock_predict {
    [MEExperimental enableFeature:EMSInnerFeature.predict];
    EMSRequestModel *requestModel = [self createRequestModel];

    OCMReject([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
    OCMReject([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);

    OCMStub([self.mockPredictRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockPredictRequestContext contactFieldValue]).andReturn(self.contactFieldValue);
    OCMStub([self.mockRequestContext contactFieldValue]).andReturn(self.contactFieldValue);
    OCMStub([self.mockRequestFactory createPredictOnlyContactRequestModelWithRefresh:NO]).andReturn(requestModel);
    OCMStub([self.mockRequestManager submitRequestModel:requestModel
                                    withCompletionBlock:[OCMArg invokeBlock]]);

    [self.internal setContactWithContactFieldId:self.contactFieldId
                              contactFieldValue:self.contactFieldValue
                                completionBlock:self.completionBlock];


    OCMVerify([self.mockRequestFactory createPredictOnlyContactRequestModelWithRefresh:NO]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockPredictRequestContext setContactFieldValue:self.contactFieldValue]);
    OCMVerify([self.mockPredictRequestContext setContactFieldId:self.contactFieldId]);
    OCMVerify([self.mockRequestContext setOpenIdToken:nil]);
}

- (void)testSetAuthenticatedContactWithIdTokenCompletionBlock_setIdTokenOnRequestContext {
    [MEExperimental enableFeature:EMSInnerFeature.mobileEngage];
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

- (void)testSetAuthenticatedContactWithIdTokenCompletionBlock_setIdTokenOnRequestContext_predict {
    [MEExperimental enableFeature:EMSInnerFeature.predict];
    EMSRequestModel *requestModel = [self createRequestModel];
    NSString *newIdToken = @"testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken";

    OCMReject([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
    OCMReject([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);

    OCMStub([self.mockRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockPredictRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestContext openIdToken]).andReturn(newIdToken);
    OCMStub([self.mockRequestFactory createPredictOnlyContactRequestModelWithRefresh:NO]).andReturn(requestModel);

    [self.internal setAuthenticatedContactWithContactFieldId:@3
                                                 openIdToken:newIdToken
                                             completionBlock:self.completionBlock];

    OCMVerify([self.mockRequestFactory createPredictOnlyContactRequestModelWithRefresh:NO]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockRequestContext setOpenIdToken:newIdToken]);
    OCMVerify([self.mockPredictRequestContext setContactFieldValue:nil]);
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
    OCMStub([self.mockSession stopSessionWithCompletionBlock:[OCMArg invokeBlock]]);

    [self.internal setAuthenticatedContactWithContactFieldId:@3
                                                 openIdToken:idToken
                                             completionBlock:self.completionBlock];

    OCMVerify([self.mockRequestFactory createPredictOnlyContactRequestModelWithRefresh:NO]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
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

    OCMVerify([self.mockRequestContext setContactFieldValue:self.contactFieldValue]);

    OCMVerify([self.mockRequestFactory createContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
}

- (void)testSetContactWithContactFieldValueCompletionBlock_resetSession_predict {
    [MEExperimental enableFeature:EMSInnerFeature.predict];
    EMSRequestModel *requestModel = [self createRequestModel];

    OCMStub([self.mockRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestContext contactFieldValue]).andReturn(@"otherContactFieldValue");
    OCMStub([self.mockRequestFactory createPredictOnlyContactRequestModelWithRefresh:NO]).andReturn(requestModel);
    OCMStub([self.mockRequestManager submitRequestModel:requestModel
                                    withCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([self.mockSession stopSessionWithCompletionBlock:[OCMArg invokeBlock]]);

    [self.internal setContactWithContactFieldId:self.contactFieldId
                              contactFieldValue:self.contactFieldValue
                                completionBlock:self.completionBlock];

    OCMVerify([self.mockRequestContext setContactFieldValue:self.contactFieldValue]);

    OCMVerify([self.mockRequestFactory createPredictOnlyContactRequestModelWithRefresh:NO]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockSession stopSessionWithCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
}

- (void)testClearContact {
    EMSContactClientInternal *partialMockInternal = OCMPartialMock(self.internal);

    [partialMockInternal clearContact];

    OCMVerify([partialMockInternal clearContactWithCompletionBlock:nil];);
}

- (void)testClearContactWithCompletionBlock {
    [MEExperimental enableFeature:EMSInnerFeature.mobileEngage];

    EMSRequestModel *requestModel = [self createRequestModel];

    OCMStub([self.mockRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestContext contactFieldValue]).andReturn(self.contactFieldValue);
    OCMStub([self.mockRequestFactory createContactRequestModel]).andReturn(requestModel);
    OCMStub([self.mockSession stopSessionWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([self.mockRequestManager submitRequestModel:[OCMArg any]
                                    withCompletionBlock:[OCMArg invokeBlock]]);
    
    [self.internal clearContactWithCompletionBlock:self.completionBlock];

    OCMVerify([self.mockRequestFactory createContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
}

- (void)testClearContactWithCompletionBlock_predict {
    [MEExperimental enableFeature:EMSInnerFeature.predict];

    EMSRequestModel *requestModel = [self createRequestModel];

    OCMStub([self.mockRequestContext contactFieldId]).andReturn(self.contactFieldId);
    OCMStub([self.mockRequestContext contactFieldValue]).andReturn(self.contactFieldValue);
    OCMStub([self.mockRequestFactory createPredictOnlyClearContactRequestModel]).andReturn(requestModel);
    OCMStub([self.mockSession stopSessionWithCompletionBlock:[OCMArg invokeBlock]]);
    OCMStub([self.mockRequestManager submitRequestModel:[OCMArg any]
                                    withCompletionBlock:[OCMArg invokeBlock]]);
    
    [self.internal clearContactWithCompletionBlock:self.completionBlock];

    OCMVerify([self.mockRequestFactory createPredictOnlyClearContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    OCMVerify([self.mockSession startSessionWithCompletionBlock:[OCMArg any]]);
}


- (EMSRequestModel *)createRequestModel {
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"https://www.emarsys.com"];
            }
                          timestampProvider:self.timestampProvider
                               uuidProvider:self.uuidProvider];
}


@end
