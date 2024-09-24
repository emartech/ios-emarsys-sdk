//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSMobileEngageRefreshTokenCompletionProxy.h"
#import "EMSResponseModel.h"
#import "EMSContactTokenResponseHandler.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSEndpoint.h"
#import "EMSValueProvider.h"
#import "NSError+EMSCore.h"
#import "EMSStorage.h"
#import "EMSStorageProtocol.h"

@interface EMSMobileEngageRefreshTokenCompletionProxy()

@property(nonatomic, assign) NSInteger retryCount;
@property(nonatomic, strong) EMSResponseModel *originalResponseModel;

- (void)reset;

@end

@interface EMSMobileEngageRefreshTokenCompletionProxyTests : XCTestCase

@property(nonatomic, strong) EMSRESTClient *mockRestClient;
@property(nonatomic, strong) id <EMSRESTClientCompletionProxyProtocol> mockCompletionProxy;
@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;
@property(nonatomic, strong) EMSContactTokenResponseHandler *mockResponseHandler;
@property(nonatomic, strong) NSError *error;
@property(nonatomic, strong) EMSMobileEngageRefreshTokenCompletionProxy *refreshCompletionProxy;
@property(nonatomic, strong) EMSEndpoint *endpoint;
@property(nonatomic, strong) EMSStorage *mockStorage;

@end

@implementation EMSMobileEngageRefreshTokenCompletionProxyTests
- (void)setUp {
    _mockRestClient = OCMClassMock([EMSRESTClient class]);
    _mockCompletionProxy = OCMProtocolMock(@protocol(EMSRESTClientCompletionProxyProtocol));
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    _mockResponseHandler = OCMClassMock([EMSContactTokenResponseHandler class]);
    _mockStorage = OCMClassMock([EMSStorage class]);
    _error = [NSError errorWithCode:500
               localizedDescription:@"customError"];

    EMSValueProvider *clientServiceUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://me-client.eservice.emarsys.net"
                                                                                       valueKey:@"CLIENT_SERVICE_URL"];
    EMSValueProvider *eventServiceUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://mobile-events.eservice.emarsys.net"
                                                                                      valueKey:@"EVENT_SERVICE_URL"];
    EMSValueProvider *v3MessageInboxUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://me-inbox.eservice.emarsys.net"
                                                                                        valueKey:@"V3_MESSAGE_INBOX_URL"];
    EMSValueProvider *predictUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://recommender.scarabresearch.com"
                                                                                 valueKey:@"PREDICT_URL"];
    _endpoint = [[EMSEndpoint alloc] initWithClientServiceUrlProvider:clientServiceUrlProvider
                                              eventServiceUrlProvider:eventServiceUrlProvider
                                                   predictUrlProvider:predictUrlProvider
                                                  deeplinkUrlProvider:OCMClassMock([EMSValueProvider class])
                                            v3MessageInboxUrlProvider:v3MessageInboxUrlProvider];

    _refreshCompletionProxy = [[EMSMobileEngageRefreshTokenCompletionProxy alloc] initWithCompletionProxy:self.mockCompletionProxy
                                                                                               restClient:self.mockRestClient
                                                                                           requestFactory:self.mockRequestFactory
                                                                                   contactResponseHandler:self.mockResponseHandler
                                                                                                 endpoint:self.endpoint
                                                                                                  storage:self.mockStorage];
}

- (void)testInit_completionProxy_mustNotBeNil {
    @try {
        [[EMSMobileEngageRefreshTokenCompletionProxy alloc] initWithCompletionProxy:nil
                                                                         restClient:self.mockRestClient
                                                                     requestFactory:self.mockRequestFactory
                                                             contactResponseHandler:self.mockResponseHandler
                                                                           endpoint:OCMClassMock([EMSEndpoint class])
                                                                            storage:self.mockStorage];
        XCTFail(@"Expected Exception when completionProxy is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: completionProxy"]);
    }
}

- (void)testInit_restClient_mustNotBeNil {
    @try {
        [[EMSMobileEngageRefreshTokenCompletionProxy alloc] initWithCompletionProxy:self.mockCompletionProxy
                                                                         restClient:nil
                                                                     requestFactory:self.mockRequestFactory
                                                             contactResponseHandler:self.mockResponseHandler
                                                                           endpoint:OCMClassMock([EMSEndpoint class])
                                                                            storage:self.mockStorage];
        XCTFail(@"Expected Exception when restClient is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: restClient"]);
    }
}

- (void)testInit_requestFactory_mustNotBeNil {
    @try {
        [[EMSMobileEngageRefreshTokenCompletionProxy alloc] initWithCompletionProxy:self.mockCompletionProxy
                                                                         restClient:self.mockRestClient
                                                                     requestFactory:nil
                                                             contactResponseHandler:self.mockResponseHandler
                                                                           endpoint:OCMClassMock([EMSEndpoint class])
                                                                            storage:self.mockStorage];
        XCTFail(@"Expected Exception when requestFactory is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: requestFactory"]);
    }
}

- (void)testInit_contactResponseHandler_mustNotBeNil {
    @try {
        [[EMSMobileEngageRefreshTokenCompletionProxy alloc] initWithCompletionProxy:self.mockCompletionProxy
                                                                         restClient:self.mockRestClient
                                                                     requestFactory:self.mockRequestFactory
                                                             contactResponseHandler:nil
                                                                           endpoint:OCMClassMock([EMSEndpoint class])
                                                                            storage:self.mockStorage];
        XCTFail(@"Expected Exception when contactResponseHandler is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: contactResponseHandler"]);
    }
}

- (void)testInit_endpoint_mustNotBeNil {
    @try {
        [[EMSMobileEngageRefreshTokenCompletionProxy alloc] initWithCompletionProxy:self.mockCompletionProxy
                                                                         restClient:self.mockRestClient
                                                                     requestFactory:self.mockRequestFactory
                                                             contactResponseHandler:self.mockResponseHandler
                                                                           endpoint:nil
                                                                            storage:self.mockStorage];
        XCTFail(@"Expected Exception when endpoint is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: endpoint"]);
    }
}

- (void)testInit_storage_mustNotBeNil {
    @try {
        [[EMSMobileEngageRefreshTokenCompletionProxy alloc] initWithCompletionProxy:self.mockCompletionProxy
                                                                         restClient:self.mockRestClient
                                                                     requestFactory:self.mockRequestFactory
                                                             contactResponseHandler:self.mockResponseHandler
                                                                           endpoint:OCMClassMock([EMSEndpoint class])
                                                                            storage:nil];
        XCTFail(@"Expected Exception when storage is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: storage"]);
    }
}

- (void)testCompletionBlock_shouldDelegate_toCompletionProxy_whenOnSuccess {
    EMSRequestModel *requestModel = [self generateRequestModel: @""];
    EMSResponseModel *responseModel = [self generateResponseWithStatusCode:200];

    __block EMSRequestModel *returnedRequestModel;
    __block EMSResponseModel *returnedResponseModel;
    __block NSError *returnedError;
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionBlock"];
    OCMStub([self.mockCompletionProxy completionBlock]).andReturn(^(EMSRequestModel *requestModel, EMSResponseModel *responseModel, NSError *error) {
        returnedRequestModel = requestModel;
        returnedResponseModel = responseModel;
        returnedError = error;
        [expectation fulfill];
    });

    self.refreshCompletionProxy.completionBlock(requestModel, responseModel, self.error);

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(returnedRequestModel, requestModel);
    XCTAssertEqualObjects(returnedResponseModel, responseModel);
    XCTAssertEqualObjects(returnedError, self.error);
}

- (void)testCompletionBlock_should_call_completionBlock_and_reset_when_retry_count_overflows {
    EMSRequestModel *requestModel = [self generateRequestModel: @""];
    EMSResponseModel *responseModel = [self generateResponseWithStatusCode:200];
    EMSMobileEngageRefreshTokenCompletionProxy *partialMockProxy = OCMPartialMock(self.refreshCompletionProxy);
    partialMockProxy.retryCount = 4;
    partialMockProxy.originalRequestModel = requestModel;
    partialMockProxy.originalResponseModel = responseModel;

    __block EMSRequestModel *returnedRequestModel;
    __block EMSResponseModel *returnedResponseModel;
    __block NSError *returnedError;
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionBlock"];
    OCMStub([self.mockCompletionProxy completionBlock]).andReturn(^(EMSRequestModel *requestModel, EMSResponseModel *responseModel, NSError *error) {
        returnedRequestModel = requestModel;
        returnedResponseModel = responseModel;
        returnedError = error;
        [expectation fulfill];
    });

    self.refreshCompletionProxy.completionBlock(requestModel, responseModel, self.error);

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(returnedRequestModel, requestModel);
    XCTAssertEqual(returnedResponseModel.statusCode, 418);
    XCTAssertEqualObjects(returnedError, self.error);
    OCMVerify([partialMockProxy reset]);
}

- (void)testCompletionBlock_should_call_completionBlock_and_reset_when_error_happens_on_refresTokenRequest {
    EMSRequestModel *requestModel = [self generateRequestModel: @"contact-token"];
    EMSResponseModel *responseModel = [self generateResponseWithStatusCode:200];
    EMSMobileEngageRefreshTokenCompletionProxy *partialMockProxy = OCMPartialMock(self.refreshCompletionProxy);
    
    partialMockProxy.originalRequestModel = requestModel;
    partialMockProxy.originalResponseModel = responseModel;

    __block EMSRequestModel *returnedRequestModel;
    __block EMSResponseModel *returnedResponseModel;
    __block NSError *returnedError;
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionBlock"];
    OCMStub([self.mockCompletionProxy completionBlock]).andReturn(^(EMSRequestModel *requestModel, EMSResponseModel *responseModel, NSError *error) {
        returnedRequestModel = requestModel;
        returnedResponseModel = responseModel;
        returnedError = error;
        [expectation fulfill];
    });

    self.refreshCompletionProxy.completionBlock(requestModel, responseModel, self.error);

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(returnedRequestModel, requestModel);
    XCTAssertEqual(returnedResponseModel.statusCode, 418);
    XCTAssertEqualObjects(returnedError, self.error);
    OCMVerify([partialMockProxy reset]);
}

- (void)testCompletionBlock_delegateToCompletionProxy_when_statusCode401_andNotV3_andNotPredict {
    EMSRequestModel *requestModel = [self generateRequestModel: @""];
    EMSResponseModel *responseModel = [self generateResponseWithStatusCode:401];

    OCMReject([self.mockResponseHandler processResponse:[OCMArg any]]);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionBlock"];
    OCMStub([self.mockCompletionProxy completionBlock]).andReturn(^(EMSRequestModel *requestModel, EMSResponseModel *responseModel, NSError *error) {
        [expectation fulfill];
    });

    self.refreshCompletionProxy.completionBlock(requestModel, responseModel, self.error);

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
}

- (void)testCompletionBlock_shouldRefreshToken_when_requestIsV3 {
    EMSRequestModel *requestModel = [self generateRequestModelWithUrlString:[self.endpoint eventUrlWithApplicationCode:@"testApplicationCode"]];
    EMSRequestModel *requestModelForRefresh = [self generateRequestModel: @""];
    EMSResponseModel *responseModel = [self generateResponseWithStatusCode:401];

    OCMStub([self.mockRequestFactory createRefreshTokenRequestModel]).andReturn(requestModelForRefresh);

    self.refreshCompletionProxy.completionBlock(requestModel, responseModel, self.error);

    OCMVerify([self.mockRequestFactory createRefreshTokenRequestModel]);
    OCMVerify([self.mockRestClient executeWithRequestModel:requestModelForRefresh
                                       coreCompletionProxy:self.refreshCompletionProxy]);
    OCMVerify([self.mockStorage setData:nil
                                 forKey:@"EMSPushTokenKey"]);
    XCTAssertEqualObjects(self.refreshCompletionProxy.originalRequestModel, requestModel);
}

- (void)testCompletionBlock_shouldRefreshToken_when_requestIsPredict {
    EMSRequestModel *requestModel = [self generateRequestModelWithUrlString:[self.endpoint predictUrl]];
    EMSRequestModel *requestModelForRefresh = [self generateRequestModel: @""];
    EMSResponseModel *responseModel = [self generateResponseWithStatusCode:401];

    OCMStub([self.mockRequestFactory createRefreshTokenRequestModel]).andReturn(requestModelForRefresh);

    self.refreshCompletionProxy.completionBlock(requestModel, responseModel, self.error);

    OCMVerify([self.mockRequestFactory createRefreshTokenRequestModel]);
    OCMVerify([self.mockRestClient executeWithRequestModel:requestModelForRefresh
                                       coreCompletionProxy:self.refreshCompletionProxy]);
    OCMVerify([self.mockStorage setData:nil
                                 forKey:@"EMSPushTokenKey"]);
    XCTAssertEqualObjects(self.refreshCompletionProxy.originalRequestModel, requestModel);
}

- (void)testCompletionBlock_shouldHandleResponse {
    EMSRequestModel *requestModel = [self generateRequestModel: @"contact-token"];
    EMSRequestModel *mockOriginalRequestModel = [self generateRequestModel: @""];
    EMSResponseModel *responseModel = [self generateResponseWithStatusCode:200];

    self.refreshCompletionProxy.originalRequestModel = mockOriginalRequestModel;

    self.refreshCompletionProxy.completionBlock(requestModel, responseModel, nil);

    OCMVerify([self.mockResponseHandler processResponse:responseModel]);
    OCMVerify([self.mockRestClient executeWithRequestModel:mockOriginalRequestModel
                                       coreCompletionProxy:self.refreshCompletionProxy]);
}

- (void)testCompletionBlock_shouldNotHandleResponse_when_success_and_noOriginalRequestModel {
    EMSRequestModel *requestModel = [self generateRequestModel: @""];
    EMSResponseModel *responseModel = [self generateResponseWithStatusCode:200];

    OCMReject([self.mockResponseHandler processResponse:[OCMArg any]]);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionBlock"];
    OCMStub([self.mockCompletionProxy completionBlock]).andReturn(^(EMSRequestModel *requestModel, EMSResponseModel *responseModel, NSError *error) {
        [expectation fulfill];
    });

    self.refreshCompletionProxy.completionBlock(requestModel, responseModel, self.error);

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
}

- (EMSRequestModel *)generateRequestModel:(NSString*) urlPath {
    return [self generateRequestModelWithUrlString:[NSString stringWithFormat:@"https://www.emarsys.com/%@", urlPath]];
}

- (EMSRequestModel *)generateRequestModelWithUrlString:(NSString *)url {
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:url];
                [builder setMethod:HTTPMethodPOST];
                [builder setPayload:@{@"payloadKey": @"payloadValue"}];
            }
                          timestampProvider:[EMSTimestampProvider new]
                               uuidProvider:[EMSUUIDProvider new]];
}

- (EMSResponseModel *)generateResponseWithStatusCode:(int)statusCode {
    return [[EMSResponseModel alloc] initWithStatusCode:statusCode
                                                headers:@{@"responseHeaderKey": @"responseHeaderValue"}
                                                   body:[@"data" dataUsingEncoding:NSUTF8StringEncoding]
                                             parsedBody:nil
                                           requestModel:[self generateRequestModel: @""]
                                              timestamp:[[EMSTimestampProvider new] provideTimestamp]];
}

@end
