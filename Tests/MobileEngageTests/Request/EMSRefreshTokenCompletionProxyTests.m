//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSRefreshTokenCompletionProxy.h"
#import "EMSResponseModel.h"
#import "EMSContactTokenResponseHandler.h"
#import "EMSResponseModel+EMSCore.h"

@interface EMSRefreshTokenCompletionProxyTests : XCTestCase

@end

@implementation EMSRefreshTokenCompletionProxyTests

- (void)setUp {
}

- (void)testInit_completionProxy_mustNotBeNil {
    @try {
        [[EMSRefreshTokenCompletionProxy alloc] initWithCompletionProxy:nil
                                                             restClient:OCMClassMock([EMSRESTClient class])
                                                         requestFactory:OCMClassMock([EMSRequestFactory class])
                                                 contactResponseHandler:OCMClassMock([EMSContactTokenResponseHandler class])];
        XCTFail(@"Expected Exception when completionProxy is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: completionProxy"]);
    }
}

- (void)testInit_restClient_mustNotBeNil {
    @try {
        [[EMSRefreshTokenCompletionProxy alloc] initWithCompletionProxy:OCMProtocolMock(@protocol(EMSRESTClientCompletionProxyProtocol))
                                                             restClient:nil
                                                         requestFactory:OCMClassMock([EMSRequestFactory class])
                                                 contactResponseHandler:OCMClassMock([EMSContactTokenResponseHandler class])];
        XCTFail(@"Expected Exception when restClient is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: restClient"]);
    }
}

- (void)testInit_requestFactory_mustNotBeNil {
    @try {
        [[EMSRefreshTokenCompletionProxy alloc] initWithCompletionProxy:OCMProtocolMock(@protocol(EMSRESTClientCompletionProxyProtocol))
                                                             restClient:OCMClassMock([EMSRESTClient class])
                                                         requestFactory:nil
                                                 contactResponseHandler:OCMClassMock([EMSContactTokenResponseHandler class])];
        XCTFail(@"Expected Exception when requestFactory is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: requestFactory"]);
    }
}

- (void)testInit_contactResponseHandler_mustNotBeNil {
    @try {
        [[EMSRefreshTokenCompletionProxy alloc] initWithCompletionProxy:OCMProtocolMock(@protocol(EMSRESTClientCompletionProxyProtocol))
                                                             restClient:OCMClassMock([EMSRESTClient class])
                                                         requestFactory:OCMClassMock([EMSRequestFactory class])
                                                 contactResponseHandler:nil];
        XCTFail(@"Expected Exception when contactResponseHandler is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: contactResponseHandler"]);
    }
}

- (void)testCompletionBlock_shouldDelegate_toCompletionProxy_whenOnSuccess {
    id <EMSRESTClientCompletionProxyProtocol> mockCompletionProxy = OCMProtocolMock(@protocol(EMSRESTClientCompletionProxyProtocol));
    EMSRESTClient *mockRestClient = OCMClassMock([EMSRESTClient class]);
    EMSRequestFactory *mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    EMSResponseModel *mockResponseModel = OCMClassMock([EMSResponseModel class]);
    EMSContactTokenResponseHandler *mockResponseHandler = OCMClassMock([EMSContactTokenResponseHandler class]);
    id mockError = OCMClassMock([NSError class]);

    EMSRefreshTokenCompletionProxy *refreshTokenCompletionProxy = [[EMSRefreshTokenCompletionProxy alloc] initWithCompletionProxy:mockCompletionProxy
                                                                                                                       restClient:mockRestClient
                                                                                                                   requestFactory:mockRequestFactory
                                                                                                           contactResponseHandler:mockResponseHandler];
    __block EMSRequestModel *returnedRequestModel;
    __block EMSResponseModel *returnedResponseModel;
    __block NSError *returnedError;
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionBlock"];
    OCMStub([mockCompletionProxy completionBlock]).andReturn(^(EMSRequestModel *requestModel, EMSResponseModel *responseModel, NSError *error) {
        returnedRequestModel = requestModel;
        returnedResponseModel = responseModel;
        returnedError = error;
        [expectation fulfill];
    });

    refreshTokenCompletionProxy.completionBlock(mockRequestModel, mockResponseModel, mockError);

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(returnedRequestModel, mockRequestModel);
    XCTAssertEqualObjects(returnedResponseModel, mockResponseModel);
    XCTAssertEqualObjects(returnedError, mockError);

    [mockError stopMocking];
}

- (void)testCompletionBlock_shouldRefreshToken {
    id <EMSRESTClientCompletionProxyProtocol> mockCompletionProxy = OCMProtocolMock(@protocol(EMSRESTClientCompletionProxyProtocol));
    EMSRESTClient *mockRestClient = OCMClassMock([EMSRESTClient class]);
    EMSRequestFactory *mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    EMSRequestModel *mockRequestModelForRefresh = OCMClassMock([EMSRequestModel class]);
    EMSResponseModel *mockResponseModel = OCMClassMock([EMSResponseModel class]);
    EMSContactTokenResponseHandler *mockResponseHandler = OCMClassMock([EMSContactTokenResponseHandler class]);

    id mockError = OCMClassMock([NSError class]);

    OCMStub([mockResponseModel statusCode]).andReturn(401);
    OCMStub([mockRequestFactory createRefreshTokenRequestModel]).andReturn(mockRequestModelForRefresh);

    EMSRefreshTokenCompletionProxy *refreshTokenCompletionProxy = [[EMSRefreshTokenCompletionProxy alloc] initWithCompletionProxy:mockCompletionProxy
                                                                                                                       restClient:mockRestClient
                                                                                                                   requestFactory:mockRequestFactory
                                                                                                           contactResponseHandler:mockResponseHandler];
    refreshTokenCompletionProxy.completionBlock(mockRequestModel, mockResponseModel, mockError);

    OCMVerify([mockRequestFactory createRefreshTokenRequestModel]);
    OCMVerify([mockRestClient executeWithRequestModel:mockRequestModelForRefresh
                                  coreCompletionProxy:refreshTokenCompletionProxy]);
    XCTAssertEqualObjects(refreshTokenCompletionProxy.originalRequestModel, mockRequestModel);

    [mockError stopMocking];
}

- (void)testCompletionBlock_shouldHandleResponse {
    id <EMSRESTClientCompletionProxyProtocol> mockCompletionProxy = OCMProtocolMock(@protocol(EMSRESTClientCompletionProxyProtocol));
    EMSRESTClient *mockRestClient = OCMClassMock([EMSRESTClient class]);
    EMSRequestFactory *mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    EMSContactTokenResponseHandler *mockResponseHandler = OCMClassMock([EMSContactTokenResponseHandler class]);
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    EMSRequestModel *mockOriginalRequestModel = OCMClassMock([EMSRequestModel class]);
    EMSResponseModel *mockResponseModelForRefresh = OCMClassMock([EMSResponseModel class]);
    EMSResponseModel *mockResponseModel = OCMClassMock([EMSResponseModel class]);
    id mockError = OCMClassMock([NSError class]);

    OCMStub([mockResponseModel isSuccess]).andReturn(YES);
    OCMStub([mockResponseModelForRefresh statusCode]).andReturn(401);

    EMSRefreshTokenCompletionProxy *refreshTokenCompletionProxy = [[EMSRefreshTokenCompletionProxy alloc] initWithCompletionProxy:mockCompletionProxy
                                                                                                                       restClient:mockRestClient
                                                                                                                   requestFactory:mockRequestFactory
                                                                                                           contactResponseHandler:mockResponseHandler];
    refreshTokenCompletionProxy.completionBlock(mockOriginalRequestModel, mockResponseModelForRefresh, mockError);
    refreshTokenCompletionProxy.completionBlock(mockRequestModel, mockResponseModel, mockError);

    OCMVerify([mockResponseHandler processResponse:mockResponseModel]);
    OCMVerify([mockRestClient executeWithRequestModel:mockOriginalRequestModel
                                  coreCompletionProxy:refreshTokenCompletionProxy]);
    XCTAssertNil(refreshTokenCompletionProxy.originalRequestModel);

    [mockError stopMocking];
}

- (void)testCompletionBlock_shouldNotHandleResponse_when_success_and_noOriginalRequestModel {
    id <EMSRESTClientCompletionProxyProtocol> mockCompletionProxy = OCMProtocolMock(@protocol(EMSRESTClientCompletionProxyProtocol));
    EMSRESTClient *mockRestClient = OCMClassMock([EMSRESTClient class]);
    EMSRequestFactory *mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    EMSContactTokenResponseHandler *mockResponseHandler = OCMClassMock([EMSContactTokenResponseHandler class]);
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    EMSResponseModel *mockResponseModel = OCMClassMock([EMSResponseModel class]);
    id mockError = OCMClassMock([NSError class]);

    OCMStub([mockResponseModel isSuccess]).andReturn(YES);
    OCMReject([mockResponseHandler processResponse:[OCMArg any]]);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionBlock"];
    OCMStub([mockCompletionProxy completionBlock]).andReturn(^(EMSRequestModel *requestModel, EMSResponseModel *responseModel, NSError *error) {
        [expectation fulfill];
    });

    EMSRefreshTokenCompletionProxy *refreshTokenCompletionProxy = [[EMSRefreshTokenCompletionProxy alloc] initWithCompletionProxy:mockCompletionProxy
                                                                                                                       restClient:mockRestClient
                                                                                                                   requestFactory:mockRequestFactory
                                                                                                           contactResponseHandler:mockResponseHandler];
    refreshTokenCompletionProxy.completionBlock(mockRequestModel, mockResponseModel, mockError);

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    [mockError stopMocking];
}

@end
