//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSRESTClient.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSResponseModel.h"
#import "NSURLRequest+EMSCore.h"
#import "NSError+EMSCore.h"
#import "FakeRESTClientCompletionProxy.h"
#import "EMSRequestModelMapperProtocol.h"
#import "FakeRequestModelMapper.h"
#import "EMSAbstractResponseHandler.h"
#import "EMSMobileEngageNullSafeBodyParser.h"
#import "XCTestCase+Helper.h"

typedef void (^AssertionBlock)(XCTWaiterResult, EMSRequestModel *, EMSResponseModel *, NSError *, NSOperationQueue *operationQueue);

@interface EMSRESTClientTests : XCTestCase

@property(nonatomic, strong) EMSRESTClient *restClient;
@property(nonatomic, strong) NSURLSession *mockSession;
@property(nonatomic, strong) NSOperationQueue *expectedOperationQueue;
@property(nonatomic, strong) NSOperationQueue *mockQueue;
@property(nonatomic, strong) EMSTimestampProvider *mockTimestampProvider;
@property(nonatomic, strong) EMSCoreCompletionHandler *mockCoreCompletionHandler;
@property(nonatomic, strong) EMSRequestModel *mockRequestModel;
@property(nonatomic, strong) EMSRequestModel *requestModel;
@property(nonatomic, strong) NSURLRequest *request;
@property(nonatomic, strong) NSHTTPURLResponse *response;
@property(nonatomic, strong) NSData *data;
@property(nonatomic, strong) NSDate *responseTimestamp;
@property(nonatomic, strong) EMSResponseModel *expectedResponseModel;
@property(nonatomic, strong) NSNull *nullValue;
@property(nonatomic, strong) EMSMobileEngageNullSafeBodyParser *mockMobileEngageBodyParser;

@end

@implementation EMSRESTClientTests

- (void)setUp {
    _mockSession = OCMClassMock([NSURLSession class]);
    _expectedOperationQueue = [self createTestOperationQueue];
    _mockQueue = OCMClassMock([NSOperationQueue class]);
    _mockTimestampProvider = OCMClassMock([EMSTimestampProvider class]);
    _mockCoreCompletionHandler = OCMClassMock([EMSCoreCompletionHandler class]);
    _mockRequestModel = OCMClassMock([EMSRequestModel class]);

    _requestModel = [self generateRequestModel];
    _request = [NSURLRequest requestWithRequestModel:self.requestModel];
    _response = [self generateResponse];
    _data = [self generateBodyData];
    _responseTimestamp = [NSDate date];
    _expectedResponseModel = [[EMSResponseModel alloc] initWithStatusCode:[self.response statusCode]
                                                                  headers:[self.response allHeaderFields]
                                                                     body:self.data
                                                               parsedBody:nil
                                                             requestModel:self.requestModel
                                                                timestamp:self.responseTimestamp];
    _nullValue = [NSNull null];
    _mockMobileEngageBodyParser = OCMClassMock([EMSMobileEngageNullSafeBodyParser class]);

    _restClient = [[EMSRESTClient alloc] initWithSession:self.mockSession
                                                   queue:self.expectedOperationQueue
                                       timestampProvider:self.mockTimestampProvider
                                       additionalHeaders:nil
                                     requestModelMappers:nil
                                        responseHandlers:nil
                                  mobileEngageBodyParser:self.mockMobileEngageBodyParser];
}

- (void)tearDown {
    [self tearDownOperationQueue:self.expectedOperationQueue];
}

- (void)testInit_session_mustNotBeNil {
    @try {
        [[EMSRESTClient alloc] initWithSession:nil
                                         queue:self.mockQueue
                             timestampProvider:self.mockTimestampProvider
                             additionalHeaders:nil
                           requestModelMappers:nil
                              responseHandlers:nil
                        mobileEngageBodyParser:self.mockMobileEngageBodyParser];
        XCTFail(@"Expected Exception when session is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: session");
    }
}

- (void)testInit_queue_mustNotBeNil {
    @try {
        [[EMSRESTClient alloc] initWithSession:self.mockSession
                                         queue:nil
                             timestampProvider:self.mockTimestampProvider
                             additionalHeaders:nil
                           requestModelMappers:nil
                              responseHandlers:nil
                        mobileEngageBodyParser:self.mockMobileEngageBodyParser];
        XCTFail(@"Expected Exception when queue is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: queue");
    }
}

- (void)testInit_timestampProvider_mustNotBeNil {
    @try {
        [[EMSRESTClient alloc] initWithSession:self.mockSession
                                         queue:self.mockQueue
                             timestampProvider:nil
                             additionalHeaders:nil
                           requestModelMappers:nil
                              responseHandlers:nil
                        mobileEngageBodyParser:self.mockMobileEngageBodyParser];
        XCTFail(@"Expected Exception when timestampProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: timestampProvider");
    }
}

- (void)testInit_mobileEngageBodyParser_mustNotBeNil {
    @try {
        [[EMSRESTClient alloc] initWithSession:self.mockSession
                                         queue:self.mockQueue
                             timestampProvider:self.mockTimestampProvider
                             additionalHeaders:nil
                           requestModelMappers:nil
                              responseHandlers:nil
                        mobileEngageBodyParser:nil];
        XCTFail(@"Expected Exception when mobileEngageBodyParser is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: mobileEngageBodyParser");
    }
}

- (void)testExecute_shouldNotAccept_nilRequestModel {
    @try {
        [self.restClient executeWithRequestModel:nil
                             coreCompletionProxy:self.mockCoreCompletionHandler];
        XCTFail(@"Expected Exception when requestModel is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestModel");
    }
}

- (void)testExecute_shouldNotAccept_nilCoreCompletionProxy {
    @try {
        [self.restClient executeWithRequestModel:self.mockRequestModel
                             coreCompletionProxy:nil];
        XCTFail(@"Expected Exception when completionProxy is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: (NSObject *) completionProxy");
    }
}

- (void)testExecute_shouldNotCrash_when_completionBlock {
    OCMStub([self.mockSession dataTaskWithRequest:self.request
                                completionHandler:([OCMArg invokeBlockWithArgs:self.data,
                                                                               self.response,
                                                                               self.nullValue,
                                                                               nil])]);
    OCMStub([self.mockTimestampProvider provideTimestamp]).andReturn(self.responseTimestamp);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForSuccessBlock"];
    [self.restClient executeWithRequestModel:self.requestModel
                         coreCompletionProxy:[[FakeRESTClientCompletionProxy alloc] initWithCompletionBlock:nil]];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation]
                                                    timeout:1];
    XCTAssertEqual(result, XCTWaiterResultTimedOut);
}

- (void)testExecute_shouldGiveResponse {
    [self runExecuteWithData:self.data
                 urlResponse:self.response
                       error:self.nullValue
              assertionBlock:^(XCTWaiterResult waiterResult, EMSRequestModel *returnedRequest, EMSResponseModel *returnedResponseModel, NSError *returnedError, NSOperationQueue *operationQueue) {
                  XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
                  XCTAssertEqualObjects(returnedRequest, self.requestModel);
                  XCTAssertEqualObjects(returnedResponseModel, self.expectedResponseModel);
                  XCTAssertNil(returnedError);
                  XCTAssertEqualObjects(operationQueue, self.expectedOperationQueue);
              }];
}

- (void)testExecute_shouldGiveResponseWithParsedBody_whenMobileEngageRequest {
    NSData *nullsafeData = [NSData alloc];

    OCMStub([self.mockMobileEngageBodyParser parseWithRequestModel:[OCMArg any]
                                                      responseBody:self.data]).andReturn(nullsafeData);
    OCMStub([self.mockMobileEngageBodyParser shouldParse:[OCMArg any]
                                            responseBody:[OCMArg any]
                                         httpUrlResponse:[OCMArg any]]).andReturn(YES);

    EMSResponseModel *expectedResponseModel = [[EMSResponseModel alloc] initWithStatusCode:[self.response statusCode]
                                                                                   headers:[self.response allHeaderFields]
                                                                                      body:self.data
                                                                                parsedBody:nullsafeData
                                                                              requestModel:self.requestModel
                                                                                 timestamp:self.responseTimestamp];
    [self runExecuteWithData:self.data
                 urlResponse:self.response
                       error:self.nullValue
              assertionBlock:^(XCTWaiterResult waiterResult, EMSRequestModel *returnedRequest, EMSResponseModel *returnedResponseModel, NSError *returnedError, NSOperationQueue *operationQueue) {
                  XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
                  XCTAssertEqualObjects(returnedRequest, self.requestModel);
                  XCTAssertEqualObjects(returnedResponseModel, expectedResponseModel);
                  XCTAssertNil(returnedError);
                  XCTAssertEqualObjects(operationQueue, self.expectedOperationQueue);
                  OCMVerify([self.mockMobileEngageBodyParser parseWithRequestModel:self.requestModel
                                                                      responseBody:self.data]);
              }];
}

- (void)testExecute_shouldGiveResponseWithParsedBody_whenNotMobileEngageRequest {
    NSData *nullsafeData = [NSData alloc];

    OCMStub([self.mockMobileEngageBodyParser parseWithRequestModel:[OCMArg any]
                                                      responseBody:self.data]).andReturn(nullsafeData);
    OCMStub([self.mockMobileEngageBodyParser shouldParse:[OCMArg any]
                                            responseBody:nil
                                         httpUrlResponse:[OCMArg any]]).andReturn(NO);

    EMSResponseModel *expectedResponseModel = [[EMSResponseModel alloc] initWithStatusCode:[self.response statusCode]
                                                                                   headers:[self.response allHeaderFields]
                                                                                      body:self.data
                                                                                parsedBody:nil
                                                                              requestModel:self.requestModel
                                                                                 timestamp:self.responseTimestamp];
    [self runExecuteWithData:self.data
                 urlResponse:self.response
                       error:self.nullValue
              assertionBlock:^(XCTWaiterResult waiterResult, EMSRequestModel *returnedRequest, EMSResponseModel *returnedResponseModel, NSError *returnedError, NSOperationQueue *operationQueue) {
                  XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
                  XCTAssertEqualObjects(returnedRequest, self.requestModel);
                  XCTAssertEqualObjects(returnedResponseModel, expectedResponseModel);
                  XCTAssertNil(returnedError);
                  XCTAssertEqualObjects(operationQueue, self.expectedOperationQueue);
              }];
}

- (void)testExecute_shouldGiveError_whenErrorIsAvailable {
    NSError *expectedError = [NSError errorWithCode:-42
                               localizedDescription:@"TestError for Test."];
    EMSResponseModel *expectedResponseModel = [[EMSResponseModel alloc] initWithStatusCode:nil
                                                                                   headers:nil
                                                                                      body:nil
                                                                                parsedBody:nil
                                                                              requestModel:self.requestModel
                                                                                 timestamp:self.responseTimestamp];
    [self runExecuteWithData:self.nullValue
                 urlResponse:self.nullValue
                       error:expectedError
              assertionBlock:^(XCTWaiterResult waiterResult, EMSRequestModel *returnedRequest, EMSResponseModel *returnedResponseModel, NSError *returnedError, NSOperationQueue *operationQueue) {
                  XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
                  XCTAssertEqualObjects(returnedRequest, self.requestModel);
                  XCTAssertEqualObjects(returnedResponseModel, expectedResponseModel);
                  XCTAssertEqualObjects(returnedError, expectedError);
                  XCTAssertEqualObjects(operationQueue, self.expectedOperationQueue);
              }];
}

- (void)testExecute_shouldGiveError_when_noError_noResponseModel {
    NSError *expectedError = [NSError errorWithCode:1500
                               localizedDescription:@"Missing response"];
    EMSResponseModel *expectedResponseModel = [[EMSResponseModel alloc] initWithStatusCode:nil
                                                                                   headers:nil
                                                                                      body:self.data
                                                                                parsedBody:nil
                                                                              requestModel:self.requestModel
                                                                                 timestamp:self.responseTimestamp];
    [self runExecuteWithData:self.data
                 urlResponse:self.nullValue
                       error:self.nullValue
              assertionBlock:^(XCTWaiterResult waiterResult, EMSRequestModel *returnedRequest, EMSResponseModel *returnedResponseModel, NSError *returnedError, NSOperationQueue *operationQueue) {
                  XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
                  XCTAssertEqualObjects(returnedRequest, self.requestModel);
                  XCTAssertEqualObjects(returnedResponseModel, expectedResponseModel);
                  XCTAssertEqualObjects(returnedError, expectedError);
                  XCTAssertEqualObjects(operationQueue, self.expectedOperationQueue);
              }];
}

- (void)testExecute_shouldGiveError_when_noData {
    NSError *expectedError = [NSError errorWithCode:1500
                               localizedDescription:@"Missing data"];
    EMSResponseModel *expectedResponseModel = [[EMSResponseModel alloc] initWithStatusCode:[self.response statusCode]
                                                                                   headers:[self.response allHeaderFields]
                                                                                      body:nil
                                                                                parsedBody:nil
                                                                              requestModel:self.requestModel
                                                                                 timestamp:self.responseTimestamp];
    [self runExecuteWithData:self.nullValue
                 urlResponse:self.response
                       error:self.nullValue
              assertionBlock:^(XCTWaiterResult waiterResult, EMSRequestModel *returnedRequest, EMSResponseModel *returnedResponseModel, NSError *returnedError, NSOperationQueue *operationQueue) {
                  XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
                  XCTAssertEqualObjects(returnedRequest, self.requestModel);
                  XCTAssertEqualObjects(returnedResponseModel, expectedResponseModel);
                  XCTAssertEqualObjects(returnedError, expectedError);
                  XCTAssertEqualObjects(operationQueue, self.expectedOperationQueue);
              }];
}

- (void)testExecute_shouldUseModelMappers {
    EMSRequestModel *requestModel1 = [self generateRequestModel];
    EMSRequestModel *mockRequestModel1 = OCMClassMock([EMSRequestModel class]);
    EMSRequestModel *requestModel2 = [self generateRequestModel];

    FakeRequestModelMapper *mapper1 = [[FakeRequestModelMapper alloc] initWithShouldHandle:YES
                                                                            returningValue:mockRequestModel1];
    FakeRequestModelMapper *mapper2 = [[FakeRequestModelMapper alloc] initWithShouldHandle:NO
                                                                            returningValue:nil];
    FakeRequestModelMapper *mapper3 = [[FakeRequestModelMapper alloc] initWithShouldHandle:YES
                                                                            returningValue:requestModel2];

    NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionaryWithDictionary:requestModel1.headers];
    mutableHeaders[@"testAdditionalHeaderKey"] = @"testAdditionalHeaderValue";
    NSDictionary *headers = [NSDictionary dictionaryWithDictionary:mutableHeaders];
    EMSRequestModel *requestModelWithAdditionalHeaders = [[EMSRequestModel alloc] initWithRequestId:requestModel1.requestId
                                                                                          timestamp:requestModel1.timestamp
                                                                                             expiry:requestModel1.ttl
                                                                                                url:requestModel1.url
                                                                                             method:requestModel1.method
                                                                                            payload:requestModel1.payload
                                                                                            headers:headers
                                                                                             extras:requestModel1.extras];
    NSURLRequest *urlRequest = [NSURLRequest requestWithRequestModel:requestModel2];

    _restClient = [[EMSRESTClient alloc] initWithSession:self.mockSession
                                                   queue:self.expectedOperationQueue
                                       timestampProvider:self.mockTimestampProvider
                                       additionalHeaders:@{@"testAdditionalHeaderKey": @"testAdditionalHeaderValue"}
                                     requestModelMappers:@[mapper1, mapper2, mapper3]
                                        responseHandlers:nil
                                  mobileEngageBodyParser:self.mockMobileEngageBodyParser];

    [self.restClient executeWithRequestModel:requestModel1
                         coreCompletionProxy:[[FakeRESTClientCompletionProxy alloc] initWithCompletionBlock:^(EMSRequestModel *requestModel, EMSResponseModel *responseModel, NSError *error) {
                         }]];

    OCMVerify([self.mockSession dataTaskWithRequest:urlRequest
                                  completionHandler:[OCMArg any]]);

    XCTAssertEqualObjects(mapper1.inputValue, requestModelWithAdditionalHeaders);
    XCTAssertEqualObjects(mapper3.inputValue, mockRequestModel1);
}

- (void)testExecute_shouldUseResponseHandlers {
    EMSAbstractResponseHandler *mockResponseHandler1 = OCMClassMock([EMSAbstractResponseHandler class]);
    EMSAbstractResponseHandler *mockResponseHandler2 = OCMClassMock([EMSAbstractResponseHandler class]);

    OCMStub([self.mockTimestampProvider provideTimestamp]).andReturn([NSDate date]);
    OCMStub([self.mockSession dataTaskWithRequest:self.request
                                completionHandler:([OCMArg invokeBlockWithArgs:self.data,
                                                                               self.response,
                                                                               [NSError errorWithCode:-42
                                                                                 localizedDescription:@"TestError for Test."],
                                                                               nil])]);

    _restClient = [[EMSRESTClient alloc] initWithSession:self.mockSession
                                                   queue:self.expectedOperationQueue
                                       timestampProvider:self.mockTimestampProvider
                                       additionalHeaders:nil
                                     requestModelMappers:nil
                                        responseHandlers:@[mockResponseHandler1, mockResponseHandler2]
                                  mobileEngageBodyParser:self.mockMobileEngageBodyParser];

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionProxy"];
    __block EMSResponseModel *returnedResponseModel = nil;
    [self.restClient executeWithRequestModel:self.requestModel
                         coreCompletionProxy:[[FakeRESTClientCompletionProxy alloc] initWithCompletionBlock:^(EMSRequestModel *requestModel, EMSResponseModel *responseModel, NSError *error) {
                             returnedResponseModel = responseModel;
                             [expectation fulfill];
                         }]];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNotNil(returnedResponseModel);

    OCMVerify([mockResponseHandler1 processResponse:returnedResponseModel]);
    OCMVerify([mockResponseHandler2 processResponse:returnedResponseModel]);
}

- (EMSRequestModel *)generateRequestModel {
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"https://www.emarsys.com"];
                [builder setMethod:HTTPMethodPOST];
            }
                          timestampProvider:[EMSTimestampProvider new]
                               uuidProvider:[EMSUUIDProvider new]];
}

- (NSHTTPURLResponse *)generateResponse {
    return [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:@"https://www.emarsys.com"]
                                       statusCode:200
                                      HTTPVersion:nil
                                     headerFields:@{@"responseHeaderKey": @"responseHeaderValue"}];
}

- (NSData *)generateBodyData {
    return [NSJSONSerialization dataWithJSONObject:@{@"bodyKey": @"bodyValue"}
                                           options:NSJSONWritingPrettyPrinted
                                             error:nil];
}

- (void)runExecuteWithData:(id)data
               urlResponse:(id)urlResponse
                     error:(id)error
            assertionBlock:(AssertionBlock)assertionBlock {
    NSURLSessionDataTask *mockTask = OCMClassMock([NSURLSessionDataTask class]);

    OCMStub([self.mockSession dataTaskWithRequest:self.request
                                completionHandler:([OCMArg invokeBlockWithArgs:data,
                                                                               urlResponse,
                                                                               error,
                                                                               nil])]).andReturn(mockTask);
    OCMStub([self.mockTimestampProvider provideTimestamp]).andReturn(self.responseTimestamp);

    __block EMSRequestModel *returnedRequest = nil;
    __block EMSResponseModel *returnedResponseModel = nil;
    __block NSError *returnedError = nil;
    __block NSOperationQueue *usedOperationQueue = nil;
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForSuccessBlock"];
    [self.restClient executeWithRequestModel:self.requestModel
                         coreCompletionProxy:[[FakeRESTClientCompletionProxy alloc] initWithCompletionBlock:^(EMSRequestModel *requestModel, EMSResponseModel *responseModel, NSError *error) {
                             returnedRequest = requestModel;
                             returnedResponseModel = responseModel;
                             returnedError = error;
                             usedOperationQueue = [NSOperationQueue currentQueue];
                             [expectation fulfill];
                         }]];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation]
                                                    timeout:1];
    OCMVerify([self.mockSession dataTaskWithRequest:self.request
                                  completionHandler:[OCMArg any]]);
    OCMVerify([mockTask resume]);

    assertionBlock(result, returnedRequest, returnedResponseModel, returnedError, usedOperationQueue);
}

@end
