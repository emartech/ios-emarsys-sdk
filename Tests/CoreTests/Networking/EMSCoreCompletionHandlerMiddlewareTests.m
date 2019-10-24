//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSCoreCompletionHandlerMiddleware.h"
#import "EMSWorkerProtocol.h"
#import "EMSRequestModelRepositoryProtocol.h"
#import "EMSResponseModel.h"
#import "EMSFilterByValuesSpecification.h"
#import "EMSSchemaContract.h"
#import "EMSResponseModel+EMSCore.h"
#import "EMSRequestModel+RequestIds.h"
#import "NSError+EMSCore.h"

typedef void (^AssertionBlock)(XCTWaiterResult, EMSRequestModel *returnedRequestModel, EMSResponseModel *returnedResponseModel, NSError *returnedError, NSOperationQueue *returnedOperationQueue);

@interface EMSCoreCompletionHandlerMiddlewareTests : XCTestCase

@property(nonatomic, strong) NSOperationQueue *operationQueue;
@property(nonatomic, strong) EMSCoreCompletionHandlerMiddleware *completionHandlerMiddleware;
@property(nonatomic, strong) id <EMSRESTClientCompletionProxyProtocol> mockCompletionProxy;
@property(nonatomic, strong) id <EMSWorkerProtocol> mockWorker;
@property(nonatomic, strong) id <EMSRequestModelRepositoryProtocol> mockRepository;
@property(nonatomic, strong) NSOperationQueue *mockOperationQueue;
@property(nonatomic, strong) EMSRequestModel *mockRequestModel;
@property(nonatomic, strong) EMSResponseModel *mockResponseModel;
@property(nonatomic, strong) NSError *error;
@property(nonatomic, strong) NSDate *deleteDate;
@property(nonatomic, strong) NSDate *unlockDate;
@property(nonatomic, strong) NSDate *runDate;

@end

@implementation EMSCoreCompletionHandlerMiddlewareTests

- (void)setUp {
    _operationQueue = [NSOperationQueue new];
    _mockCompletionProxy = OCMProtocolMock(@protocol(EMSRESTClientCompletionProxyProtocol));
    _mockWorker = OCMProtocolMock(@protocol(EMSWorkerProtocol));
    _mockRepository = OCMProtocolMock(@protocol(EMSRequestModelRepositoryProtocol));
    _mockOperationQueue = OCMClassMock([NSOperationQueue class]);
    _mockRequestModel = OCMClassMock([EMSRequestModel class]);
    _mockResponseModel = OCMClassMock([EMSResponseModel class]);
    _error = [NSError new];

    NSArray *requestIds = @[@"requestId", @"requestId2"];
    OCMStub([self.mockRequestModel requestIds]).andReturn(requestIds);

    _completionHandlerMiddleware = [[EMSCoreCompletionHandlerMiddleware alloc] initWithCoreCompletionHandler:self.mockCompletionProxy
                                                                                                      worker:self.mockWorker
                                                                                           requestRepository:self.mockRepository
                                                                                              operationQueue:self.operationQueue];
}

- (void)tearDown {
    [self.operationQueue waitUntilAllOperationsAreFinished];
}

- (void)testInit_completionHandler_mustNotBeNull {
    @try {
        [[EMSCoreCompletionHandlerMiddleware alloc] initWithCoreCompletionHandler:nil
                                                                           worker:self.mockWorker
                                                                requestRepository:self.mockRepository
                                                                   operationQueue:self.mockOperationQueue];
        XCTFail(@"Expected Exception when completionHandler is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: completionHandler");
    }
}

- (void)testInit_worker_mustNotBeNull {
    @try {
        [[EMSCoreCompletionHandlerMiddleware alloc] initWithCoreCompletionHandler:self.mockCompletionProxy
                                                                           worker:nil
                                                                requestRepository:self.mockRepository
                                                                   operationQueue:self.mockOperationQueue];
        XCTFail(@"Expected Exception when worker is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: worker");
    }
}

- (void)testInit_requestRepository_mustNotBeNull {
    @try {
        [[EMSCoreCompletionHandlerMiddleware alloc] initWithCoreCompletionHandler:self.mockCompletionProxy
                                                                           worker:self.mockWorker
                                                                requestRepository:nil
                                                                   operationQueue:self.mockOperationQueue];
        XCTFail(@"Expected Exception when requestRepository is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestRepository");
    }
}

- (void)testInit_operationQueue_mustNotBeNull {
    @try {
        [[EMSCoreCompletionHandlerMiddleware alloc] initWithCoreCompletionHandler:self.mockCompletionProxy
                                                                           worker:self.mockWorker
                                                                requestRepository:self.mockRepository
                                                                   operationQueue:nil];
        XCTFail(@"Expected Exception when operationQueue is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: operationQueue");
    }
}

- (void)testCompletionBlock_shouldUseGivenOperationQueue {
    OCMStub([self.mockResponseModel statusCode]).andReturn(200);
    OCMStub([self.mockResponseModel isSuccess]).andReturn(YES);

    [self runCompletionBlockWithRequestModel:self.mockRequestModel
                               responseModel:self.mockResponseModel
                                       error:self.error
                              assertionBlock:^(XCTWaiterResult result, EMSRequestModel *returnedRequestModel, EMSResponseModel *returnedResponseModel, NSError *returnedError, NSOperationQueue *returnedOperationQueue) {
                                  XCTAssertEqual(result, XCTWaiterResultCompleted);
                                  XCTAssertEqualObjects(returnedOperationQueue, self.operationQueue);
                                  XCTAssertEqualObjects(returnedRequestModel, self.mockRequestModel);
                                  XCTAssertEqualObjects(returnedResponseModel, self.mockResponseModel);
                                  XCTAssertEqualObjects(returnedError, self.error);
                              }];
}

- (void)testCompletionBlock_shouldContinue_whenStatusCodeIsGreaterThan399 {
    OCMStub([self.mockResponseModel statusCode]).andReturn(400);

    [self setupOrderCheckWorkerShouldContinue];

    [self runCompletionBlockWithRequestModel:self.mockRequestModel
                               responseModel:self.mockResponseModel
                                       error:self.error
                              assertionBlock:^(XCTWaiterResult result, EMSRequestModel *returnedRequestModel, EMSResponseModel *returnedResponseModel, NSError *returnedError, NSOperationQueue *returnedOperationQueue) {
                                  [self assertForOrderWhenWorkerShouldContinue];
                              }];
}

- (void)testCompletionBlock_shouldContinue_whenResponseIsSuccess {
    OCMStub([self.mockResponseModel statusCode]).andReturn(200);
    OCMStub([self.mockResponseModel isSuccess]).andReturn(YES);

    [self setupOrderCheckWorkerShouldContinue];

    [self runCompletionBlockWithRequestModel:self.mockRequestModel
                               responseModel:self.mockResponseModel
                                       error:self.error
                              assertionBlock:^(XCTWaiterResult result, EMSRequestModel *returnedRequestModel, EMSResponseModel *returnedResponseModel, NSError *returnedError, NSOperationQueue *returnedOperationQueue) {
                                  [self assertForOrderWhenWorkerShouldContinue];
                              }];
}

- (void)testCompletionBlock_shouldContinue_whenErrorCodeIsNSURLErrorCannotFindHost {
    _error = [NSError errorWithCode:NSURLErrorCannotFindHost
               localizedDescription:@"NSURLErrorCannotFindHost"];

    [self setupOrderCheckWorkerShouldContinue];

    [self runCompletionBlockWithRequestModel:self.mockRequestModel
                               responseModel:self.mockResponseModel
                                       error:self.error
                              assertionBlock:^(XCTWaiterResult result, EMSRequestModel *returnedRequestModel, EMSResponseModel *returnedResponseModel, NSError *returnedError, NSOperationQueue *returnedOperationQueue) {
                                  [self assertForOrderWhenWorkerShouldContinue];
                              }];
}

- (void)testCompletionBlock_shouldContinue_whenErrorCodeIsNSURLErrorBadURL {
    _error = [NSError errorWithCode:NSURLErrorBadURL
               localizedDescription:@"NSURLErrorBadURL"];

    [self setupOrderCheckWorkerShouldContinue];

    [self runCompletionBlockWithRequestModel:self.mockRequestModel
                               responseModel:self.mockResponseModel
                                       error:self.error
                              assertionBlock:^(XCTWaiterResult result, EMSRequestModel *returnedRequestModel, EMSResponseModel *returnedResponseModel, NSError *returnedError, NSOperationQueue *returnedOperationQueue) {
                                  [self assertForOrderWhenWorkerShouldContinue];
                              }];
}

- (void)testCompletionBlock_shouldContinue_whenErrorCodeIsNSURLErrorUnsupportedURL {
    _error = [NSError errorWithCode:NSURLErrorUnsupportedURL
               localizedDescription:@"NSURLErrorUnsupportedURL"];

    [self setupOrderCheckWorkerShouldContinue];

    [self runCompletionBlockWithRequestModel:self.mockRequestModel
                               responseModel:self.mockResponseModel
                                       error:self.error
                              assertionBlock:^(XCTWaiterResult result, EMSRequestModel *returnedRequestModel, EMSResponseModel *returnedResponseModel, NSError *returnedError, NSOperationQueue *returnedOperationQueue) {
                                  [self assertForOrderWhenWorkerShouldContinue];
                              }];
}

- (void)testCompletionBlock_shouldNotRemoveRequestFromRepository_whenStatusCodeIsLessThan400 {
    OCMStub([self.mockResponseModel statusCode]).andReturn(399);
    OCMReject([self.mockRepository remove:[OCMArg any]]);

    [self runCompletionBlockWithRequestModel:self.mockRequestModel
                               responseModel:self.mockResponseModel
                                       error:self.error
                              assertionBlock:nil];
}

- (void)testCompletionBlock_shouldNotRemoveRequestFromRepository_whenStatusCodeIsGreaterThan499 {
    OCMStub([self.mockResponseModel statusCode]).andReturn(500);
    OCMReject([self.mockRepository remove:[OCMArg any]]);

    [self runCompletionBlockWithRequestModel:self.mockRequestModel
                               responseModel:self.mockResponseModel
                                       error:self.error
                              assertionBlock:nil];
}

- (void)testCompletionBlock_shouldNotRemoveRequestFromRepository_whenStatusCodeIs408 {
    OCMStub([self.mockResponseModel statusCode]).andReturn(408);
    OCMReject([self.mockRepository remove:[OCMArg any]]);

    [self runCompletionBlockWithRequestModel:self.mockRequestModel
                               responseModel:self.mockResponseModel
                                       error:self.error
                              assertionBlock:nil];
}

- (void)testCompletionBlock_shouldNotRemoveRequestFromRepository_whenStatusCodeIs429 {
    OCMStub([self.mockResponseModel statusCode]).andReturn(429);
    OCMReject([self.mockRepository remove:[OCMArg any]]);

    [self runCompletionBlockWithRequestModel:self.mockRequestModel
                               responseModel:self.mockResponseModel
                                       error:self.error
                              assertionBlock:nil];
}

- (void)testCompletionBlock_shouldUnlock {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForUnlock"];
    OCMStub([self.mockWorker unlock]).andDo(^(NSInvocation *invocation) {
        [expectation fulfill];
    });

    [self runCompletionBlockWithRequestModel:self.mockRequestModel
                               responseModel:self.mockResponseModel
                                       error:self.error
                              assertionBlock:nil];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:1];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
}

- (void)testCompletionBlock_shouldUnlockAndNothingElse_whenRetriableError {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForUnlock"];
    OCMReject([self.mockWorker run]);
    OCMReject([self.mockCompletionProxy completionBlock]);

    OCMStub([self.mockResponseModel statusCode]).andReturn(500);
    OCMStub([self.mockWorker unlock]).andDo(^(NSInvocation *invocation) {
        [expectation fulfill];
    });

    [self runCompletionBlockWithRequestModel:self.mockRequestModel
                               responseModel:self.mockResponseModel
                                       error:self.error
                              assertionBlock:nil];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:1];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
}

- (void)runCompletionBlockWithRequestModel:(EMSRequestModel *)requestModel
                             responseModel:(EMSResponseModel *)responseModel
                                     error:(NSError *)error
                            assertionBlock:(AssertionBlock)assertionBlock {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionHandler"];
    __block NSOperationQueue *usedOperationQueue;
    __block EMSRequestModel *returnedRequestModel;
    __block EMSResponseModel *returnedResponseModel;
    __block NSError *returnedError;

    OCMStub([self.mockCompletionProxy completionBlock]).andReturn(^(EMSRequestModel *requestModel, EMSResponseModel *responseModel, NSError *error) {
        usedOperationQueue = [NSOperationQueue currentQueue];
        returnedRequestModel = requestModel;
        returnedResponseModel = responseModel;
        returnedError = error;
        [expectation fulfill];
    });

    self.completionHandlerMiddleware.completionBlock(requestModel, responseModel, error);

    if (assertionBlock) {
        XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                              timeout:1];

        assertionBlock(waiterResult, returnedRequestModel, returnedResponseModel, returnedError, usedOperationQueue);
    }
}

- (void)setupOrderCheckWorkerShouldContinue {
    NSArray *expectedRequestIds = @[@"requestId", @"requestId2"];
    OCMStub([self.mockRepository remove:[[EMSFilterByValuesSpecification alloc] initWithValues:expectedRequestIds
                                                                                        column:REQUEST_COLUMN_NAME_REQUEST_ID]]).andDo(^(NSInvocation *invocation) {
        self.deleteDate = [NSDate date];
    });
    OCMStub([self.mockWorker unlock]).andDo(^(NSInvocation *invocation) {
        self.unlockDate = [NSDate date];
    });
    OCMStub([self.mockWorker run]).andDo(^(NSInvocation *invocation) {
        self.runDate = [NSDate date];
    });
}

- (void)assertForOrderWhenWorkerShouldContinue {
    NSArray *expectedRequestIds = @[@"requestId", @"requestId2"];
    OCMStub([self.mockRepository remove:[[EMSFilterByValuesSpecification alloc] initWithValues:expectedRequestIds
                                                                                        column:REQUEST_COLUMN_NAME_REQUEST_ID]]);
    OCMVerify([self.mockWorker unlock]);
    OCMVerify([self.mockWorker run]);
    OCMVerify([self.mockCompletionProxy completionBlock]);
    XCTAssertTrue([self.deleteDate compare:self.unlockDate] == NSOrderedAscending);
    XCTAssertTrue([self.unlockDate compare:self.runDate] == NSOrderedAscending);
}

@end
