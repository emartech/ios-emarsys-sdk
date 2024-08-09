//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "EMSRequestManager.h"
#import "EMSSQLiteHelper.h"
#import "EMSSqliteSchemaHandler.h"
#import "EMSSchemaContract.h"
#import "EMSRequestModelRepository.h"
#import "EMSShardRepository.h"
#import "EMSShard.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSWaiter.h"
#import "NSError+EMSCore.h"
#import "EMSDefaultWorker.h"
#import "EMSResponseModel.h"
#import "EMSRESTClientCompletionProxyFactory.h"
#import "EMSOperationQueue.h"
#import "EMSMobileEngageNullSafeBodyParser.h"
#import "XCTestCase+Helper.h"

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestDB.db"]


@interface EMSRequestManagerTests : XCTestCase

@property(nonatomic, strong) EMSSQLiteHelper *helper;
@property(nonatomic, strong) EMSRequestModelRepository *requestModelRepository;
@property(nonatomic, strong) EMSShardRepository *shardRepository;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) NSOperationQueue *queue;

@end

@implementation EMSRequestManagerTests


- (void)setUp {
    _queue = [self createTestOperationQueue];

    EMSSQLiteHelper *helper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                             schemaDelegate:[EMSSqliteSchemaHandler new]];
    [helper open];
    [helper executeCommand:SQL_REQUEST_PURGE];
    self.requestModelRepository = [[EMSRequestModelRepository alloc] initWithDbHelper:helper
                                                                       operationQueue:self.queue];

    self.shardRepository = OCMClassMock([EMSShardRepository class]);
    CoreSuccessBlock successBlock = ^(NSString *requestId, EMSResponseModel *response) {

    };
    CoreErrorBlock errorBlock = ^(NSString *requestId, NSError *error) {

    };
    self.requestManager = [self createRequestManagerWithSuccessBlock:successBlock errorBlock:errorBlock requestRepository:[[EMSRequestModelRepository alloc] initWithDbHelper:helper
                                                                                                                                                               operationQueue:self.queue] shardRepository:self.shardRepository];
}

- (void)tearDown {
    [self tearDownOperationQueue:self.queue];
    [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                               error:nil];
}

- (void)testShouldThrowAnExceptionWhenCoreQueueIsNil {
    @try {
        [[EMSRequestManager alloc] initWithCoreQueue:nil
                                completionMiddleware:OCMClassMock([EMSCompletionMiddleware class])
                                          restClient:OCMClassMock([EMSRESTClient class])
                                              worker:OCMClassMock([EMSDefaultWorker class])
                                   requestRepository:OCMClassMock([EMSRequestModelRepository class])
                                     shardRepository:OCMClassMock([EMSShardRepository class])
                                        proxyFactory:OCMClassMock([EMSRESTClientCompletionProxyFactory class])];
        XCTFail(@"Expected Exception when coreQueue is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: coreQueue");
        XCTAssertNotNil(exception);
    }
}

- (void)testShouldThrowAnExceptionWhenCompletionmiddlewareIsNil {
    @try {
        [[EMSRequestManager alloc] initWithCoreQueue:OCMClassMock([NSOperationQueue class])
                                completionMiddleware:nil
                                          restClient:OCMClassMock([EMSRESTClient class])
                                              worker:OCMClassMock([EMSDefaultWorker class])
                                   requestRepository:OCMClassMock([EMSRequestModelRepository class])
                                     shardRepository:OCMClassMock([EMSShardRepository class])
                                        proxyFactory:OCMClassMock([EMSRESTClientCompletionProxyFactory class])];
        XCTFail(@"Expected Exception when completionMiddleware is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: completionMiddleware");
        XCTAssertNotNil(exception);
    }
}

- (void)testShouldThrowAnExceptionWhenRestclientIsNil {
    @try {
        [[EMSRequestManager alloc] initWithCoreQueue:OCMClassMock([NSOperationQueue class])
                                completionMiddleware:OCMClassMock([EMSCompletionMiddleware class])
                                          restClient:nil
                                              worker:OCMClassMock([EMSDefaultWorker class])
                                   requestRepository:OCMClassMock([EMSRequestModelRepository class])
                                     shardRepository:OCMClassMock([EMSShardRepository class])
                                        proxyFactory:OCMClassMock([EMSRESTClientCompletionProxyFactory class])];
        XCTFail(@"Expected Exception when restClient is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: restClient");
        XCTAssertNotNil(exception);
    }
}

- (void)testShouldThrowAnExceptionWhenWorkerIsNil {
    @try {
        [[EMSRequestManager alloc] initWithCoreQueue:OCMClassMock([NSOperationQueue class])
                                completionMiddleware:OCMClassMock([EMSCompletionMiddleware class])
                                          restClient:OCMClassMock([EMSRESTClient class])
                                              worker:nil
                                   requestRepository:OCMClassMock([EMSRequestModelRepository class])
                                     shardRepository:OCMClassMock([EMSShardRepository class])
                                        proxyFactory:OCMClassMock([EMSRESTClientCompletionProxyFactory class])];
        XCTFail(@"Expected Exception when worker is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: worker");
        XCTAssertNotNil(exception);
    }
}

- (void)testShouldThrowAnExceptionWhenRequestrepositoryIsNil {
    @try {
        [[EMSRequestManager alloc] initWithCoreQueue:OCMClassMock([NSOperationQueue class])
                                completionMiddleware:OCMClassMock([EMSCompletionMiddleware class])
                                          restClient:OCMClassMock([EMSRESTClient class])
                                              worker:OCMClassMock([EMSDefaultWorker class])
                                   requestRepository:nil
                                     shardRepository:OCMClassMock([EMSShardRepository class])
                                        proxyFactory:OCMClassMock([EMSRESTClientCompletionProxyFactory class])];
        XCTFail(@"Expected Exception when requestRepository is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestRepository");
        XCTAssertNotNil(exception);
    }
}

- (void)testShouldThrowAnExceptionWhenShardrepositoryIsNil {
    @try {
        [[EMSRequestManager alloc] initWithCoreQueue:OCMClassMock([NSOperationQueue class])
                                completionMiddleware:OCMClassMock([EMSCompletionMiddleware class])
                                          restClient:OCMClassMock([EMSRESTClient class])
                                              worker:OCMClassMock([EMSDefaultWorker class])
                                   requestRepository:OCMClassMock([EMSRequestModelRepository class])
                                     shardRepository:nil
                                        proxyFactory:OCMClassMock([EMSRESTClientCompletionProxyFactory class])];
        XCTFail(@"Expected Exception when shardRepository is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: shardRepository");
        XCTAssertNotNil(exception);
    }
}

- (void)testShouldThrowAnExceptionWhenProxyfactoryIsNil {
    @try {
        [[EMSRequestManager alloc] initWithCoreQueue:OCMClassMock([NSOperationQueue class])
                                completionMiddleware:OCMClassMock([EMSCompletionMiddleware class])
                                          restClient:OCMClassMock([EMSRESTClient class])
                                              worker:OCMClassMock([EMSDefaultWorker class])
                                   requestRepository:OCMClassMock([EMSRequestModelRepository class])
                                     shardRepository:OCMClassMock([EMSShardRepository class])
                                        proxyFactory:nil];
        XCTFail(@"Expected Exception when proxyFactory is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: proxyFactory");
        XCTAssertNotNil(exception);
    }
}

- (void)testShouldDoNetworkingWithTheGainedEmsrequestmodelAndReturnSuccess {
    NSString *url = @"https://denna.gservice.emarsys.net/echo";

    EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:url];
                [builder setMethod:HTTPMethodGET];
            }
                                            timestampProvider:[EMSTimestampProvider new]
                                                 uuidProvider:[EMSUUIDProvider new]];

    __block NSString *checkableRequestId;

    CoreSuccessBlock successBlock = ^(NSString *requestId, EMSResponseModel *response) {
        checkableRequestId = requestId;
    };
    CoreErrorBlock errorBlock = ^(NSString *requestId, NSError *error) {
        XCTFail(@"Error block has invoked");
    };

    EMSRequestManager *core = [self createRequestManagerWithSuccessBlock:successBlock
                                                              errorBlock:errorBlock
                                                       requestRepository:self.requestModelRepository
                                                         shardRepository:self.shardRepository];

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionBlock"];
    [core submitRequestModel:model
         withCompletionBlock:^(NSError *error) {
             [expectation fulfill];
         }];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation]
                                                    timeout:2];
    XCTAssertEqual(result, XCTWaiterResultCompleted);
}

- (void)testShouldDoNetworkingWithTheGainedEmsrequestmodelAndReturnSuccessInCompletionBlock {
    NSString *url = @"https://denna.gservice.emarsys.net/echo";

    EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:url];
                [builder setMethod:HTTPMethodGET];
            }
                                            timestampProvider:[EMSTimestampProvider new]
                                                 uuidProvider:[EMSUUIDProvider new]];

    CoreSuccessBlock successBlock = ^(NSString *requestId, EMSResponseModel *response) {

    };
    CoreErrorBlock errorBlock = ^(NSString *requestId, NSError *error) {
        XCTFail(@"Error block has invoked");
    };
    EMSRequestManager *core = [self createRequestManagerWithSuccessBlock:successBlock errorBlock:errorBlock requestRepository:self.requestModelRepository shardRepository:[EMSShardRepository new]];

    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    __block NSError *returnedError = [NSError errorWithCode:500
                                       localizedDescription:@"completion block not called!"];
    [core submitRequestModel:model
         withCompletionBlock:^(NSError *error) {
             returnedError = error;
             [exp fulfill];
         }];

    [EMSWaiter waitForExpectations:@[exp]
                           timeout:30];
    XCTAssertNil(returnedError);
}

- (void)testShouldDoNetworkingWithTheGainedEmsrequestmodelAndReturnFailure {
    NSString *url = @"https://denna.gservice.emarsys.net/customResponseCode/404";

    EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:url];
                [builder setMethod:HTTPMethodGET];
            }
                                            timestampProvider:[EMSTimestampProvider new]
                                                 uuidProvider:[EMSUUIDProvider new]];

    __block NSString *checkableRequestId;
    __block NSError *checkableError;

    CoreSuccessBlock successBlock = ^(NSString *requestId, EMSResponseModel *response) {
        XCTFail(@"Success block has invoked");
    };
    CoreErrorBlock errorBlock = ^(NSString *requestId, NSError *error) {
        checkableRequestId = requestId;
        checkableError = error;
    };
    EMSRequestManager *core = [self createRequestManagerWithSuccessBlock:successBlock errorBlock:errorBlock requestRepository:self.requestModelRepository shardRepository:[EMSShardRepository new]];

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionBlock"];
    [core submitRequestModel:model
         withCompletionBlock:^(NSError *error) {
             [expectation fulfill];
         }];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation]
                                                    timeout:2];
    XCTAssertEqual(result, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(checkableRequestId, model.requestId);
    XCTAssertNotNil(checkableError);
}

- (void)testShouldNotDoNetworkingWithTheGainedEmsrequestmodelAndReturnWithExpectedError {
    NSString *url = @"https://denna.gservice.emarsys.net/customResponseCode/404";

    EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:url];
                [builder setMethod:HTTPMethodGET];
            }
                                            timestampProvider:[EMSTimestampProvider new]
                                                 uuidProvider:[EMSUUIDProvider new]];

    CoreSuccessBlock successBlock = ^(NSString *requestId, EMSResponseModel *response) {
        XCTFail(@"Success block has invoked");
    };
    CoreErrorBlock errorBlock = ^(NSString *requestId, NSError *error) {
    };
    EMSRequestManager *core = [self createRequestManagerWithSuccessBlock:successBlock errorBlock:errorBlock requestRepository:self.requestModelRepository shardRepository:[EMSShardRepository new]];

    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    __block NSError *returnedError = nil;
    [core submitRequestModel:model
         withCompletionBlock:^(NSError *error) {
             returnedError = error;
             [exp fulfill];
         }];

    [EMSWaiter waitForExpectations:@[exp]
                           timeout:30];
    XCTAssertNotNil(returnedError);
}

- (void)testShouldThrowAnExceptionWhenShardmodelIsNil {
    @try {
        [self.requestManager submitShard:nil];
        XCTFail(@"Expected exception when shardModel is nil");
    } @catch (NSException *exception) {
        XCTAssertNotNil(exception);
    }
}

- (void)testShouldSaveShardViaShardrepository {
    EMSShard *shard = OCMClassMock([EMSShard class]);

    [self.requestManager submitShard:shard];

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    [self.queue addOperationWithBlock:^{
        [expectation fulfill];
    }];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation]
                                                    timeout:2];
    XCTAssertEqual(result, XCTWaiterResultCompleted);

    OCMVerify([self.shardRepository add:shard]);
}

- (void)testShouldThrowExceptionWhenSuccessblockIsNil {
    @try {
        [self.requestManager submitRequestModelNow:OCMClassMock([EMSRequestModel class])
                                      successBlock:nil
                                        errorBlock:^(NSString *requestId, NSError *error) {
                                        }];
        XCTFail(@"Expected exception when successBlock is nil");
    } @catch (NSException *exception) {
        XCTAssertNotNil(exception);
    }
}

- (void)testShouldThrowExceptionWhenErrorblockIsNil {
    @try {
        [self.requestManager submitRequestModelNow:OCMClassMock([EMSRequestModel class])
                                      successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                      }
                                        errorBlock:nil];
        XCTFail(@"Expected exception when errorBlock is nil");
    } @catch (NSException *exception) {
        XCTAssertNotNil(exception);
    }
}

- (void)testShouldInvokeRestclientWithTheGivenRequestmodelAndSuccessblockAndErrorblock {
    EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *_Nonnull builder) {
                [builder setUrl:@"https://denna.gservice.emarsys.net/echo"];
            }
                                                   timestampProvider:[EMSTimestampProvider new]
                                                        uuidProvider:[EMSUUIDProvider new]];
    EMSRESTClientCompletionProxyFactory *mockProxyFactory = OCMClassMock([EMSRESTClientCompletionProxyFactory class]);
    EMSCoreCompletionHandler *completionHandler = OCMClassMock([EMSCoreCompletionHandler class]);

    OCMStub([mockProxyFactory createWithWorker:[OCMArg isNil]
                                  successBlock:[OCMArg isNotNil]
                                    errorBlock:[OCMArg isNotNil]]).andReturn(completionHandler);

    CoreSuccessBlock successBlock = ^(NSString *requestId, EMSResponseModel *response) {
    };
    CoreErrorBlock errorBlock = ^(NSString *requestId, NSError *error) {
    };

    EMSRequestModelRepository *requestRepository = OCMClassMock([EMSRequestModelRepository class]);

    EMSCompletionMiddleware *middleware = OCMClassMock([EMSCompletionMiddleware class]);
    EMSRESTClient *restClient = OCMClassMock([EMSRESTClient class]);

    EMSDefaultWorker *worker = OCMClassMock([EMSDefaultWorker class]);
    EMSRequestManager *core = [[EMSRequestManager alloc] initWithCoreQueue:self.queue
                                                      completionMiddleware:middleware
                                                                restClient:restClient
                                                                    worker:worker
                                                         requestRepository:requestRepository
                                                           shardRepository:self.shardRepository
                                                              proxyFactory:mockProxyFactory];
    [core submitRequestModelNow:requestModel
                   successBlock:successBlock
                     errorBlock:errorBlock];

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    [self.queue addOperationWithBlock:^{
        [expectation fulfill];
    }];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation]
                                                    timeout:2];
    XCTAssertEqual(result, XCTWaiterResultCompleted);

    OCMVerify([restClient executeWithRequestModel:requestModel
                              coreCompletionProxy:completionHandler]);
}


- (void)testShouldThrowExceptionWhenRequestmodelIsNilWithoutCallbacks {
    @try {
        [self.requestManager submitRequestModelNow:nil];
        XCTFail(@"Expected exception when requestModel is nil");
    } @catch (NSException *exception) {
        XCTAssertNotNil(exception);
    }
}

- (void)testShouldInvokeRestclientWithTheGivenParameters {
    EMSRequestModel *requestModel = OCMClassMock([EMSRequestModel class]);
    EMSRESTClientCompletionProxyFactory *mockProxyFactory = OCMClassMock([EMSRESTClientCompletionProxyFactory class]);
    EMSCoreCompletionHandler *completionHandler = OCMClassMock([EMSCoreCompletionHandler class]);

    OCMStub([mockProxyFactory createWithWorker:[OCMArg any]
                                  successBlock:[OCMArg any]
                                    errorBlock:[OCMArg any]]).andReturn(completionHandler);

    EMSRequestModelRepository *requestRepository = OCMClassMock([EMSRequestModelRepository class]);

    EMSCompletionMiddleware *middleware = OCMClassMock([EMSCompletionMiddleware class]);
    EMSRESTClient *restClient = OCMClassMock([EMSRESTClient class]);

    EMSDefaultWorker *worker = OCMClassMock([EMSDefaultWorker class]);
    EMSRequestManager *core = [[EMSRequestManager alloc] initWithCoreQueue:self.queue
                                                      completionMiddleware:middleware
                                                                restClient:restClient
                                                                    worker:worker
                                                         requestRepository:requestRepository
                                                           shardRepository:self.shardRepository
                                                              proxyFactory:mockProxyFactory];

    [core submitRequestModelNow:requestModel];

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    [self.queue addOperationWithBlock:^{
        [expectation fulfill];
    }];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation]
                                                    timeout:2];
    XCTAssertEqual(result, XCTWaiterResultCompleted);

    OCMVerify([restClient executeWithRequestModel:requestModel
                              coreCompletionProxy:completionHandler]);
}

- (void)testSubmitRequestModel_shouldReturnWithError_whenRequestModel_isNil {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionBlock"];
    __block NSError *returnedError = nil;
    [self.requestManager submitRequestModel:nil
                        withCompletionBlock:^(NSError *error) {
                            returnedError = error;
                            [expectation fulfill];
                        }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNotNil(returnedError);
    XCTAssertEqual(returnedError.code, -1412);
    XCTAssertEqualObjects(returnedError.localizedDescription, @"Cannot send request - Missing ApplicationCode");
}

- (void)testSubmitRequestModelNow_shouldReturnWithError_whenRequestModel_isNil {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionBlock"];
    __block NSError *returnedError = nil;
    [self.requestManager submitRequestModelNow:nil
                                  successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                  } errorBlock:^(NSString *requestId, NSError *error) {
                returnedError = error;
                [expectation fulfill];
            }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNotNil(returnedError);
    XCTAssertEqual(returnedError.code, -1412);
    XCTAssertEqualObjects(returnedError.localizedDescription, @"Cannot send request - Missing ApplicationCode");
}

- (EMSRequestManager *)createRequestManagerWithSuccessBlock:(CoreSuccessBlock)successBlock
                                                 errorBlock:(CoreErrorBlock)errorBlock
                                          requestRepository:(EMSRequestModelRepository *)requestRepository
                                            shardRepository:(EMSShardRepository *)shardRepository {
    EMSCompletionMiddleware *middleware = [[EMSCompletionMiddleware alloc] initWithSuccessBlock:successBlock
                                                                                     errorBlock:errorBlock];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setTimeoutIntervalForRequest:60.0];
    [sessionConfiguration setHTTPCookieStorage:nil];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                          delegate:nil
                                                     delegateQueue:self.queue];

    EMSMobileEngageNullSafeBodyParser *mobileEngageNullSafeBodyParser = [[EMSMobileEngageNullSafeBodyParser alloc] initWithEndpoint:OCMClassMock([EMSEndpoint class])];

    EMSRESTClient *restClient = [[EMSRESTClient alloc] initWithSession:session
                                                                 queue:self.queue
                                                     timestampProvider:[EMSTimestampProvider new]
                                                     additionalHeaders:nil
                                                   requestModelMappers:nil
                                                      responseHandlers:nil
                                                mobileEngageBodyParser:mobileEngageNullSafeBodyParser];
    EMSRESTClientCompletionProxyFactory *proxyFactory = [[EMSRESTClientCompletionProxyFactory alloc] initWithRequestRepository:requestRepository
                                                                                                                operationQueue:self.queue
                                                                                                           defaultSuccessBlock:middleware.successBlock
                                                                                                             defaultErrorBlock:middleware.errorBlock];

    EMSConnectionWatchdog *connectionWatchdog = [[EMSConnectionWatchdog alloc] initWithOperationQueue:self.queue];

    EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:self.queue
                                                              requestRepository:requestRepository
                                                             connectionWatchdog:connectionWatchdog
                                                                     restClient:restClient
                                                                     errorBlock:middleware.errorBlock
                                                                   proxyFactory:proxyFactory];
    return [[EMSRequestManager alloc] initWithCoreQueue:self.queue
                                   completionMiddleware:middleware
                                             restClient:restClient
                                                 worker:worker
                                      requestRepository:requestRepository
                                        shardRepository:shardRepository
                                           proxyFactory:proxyFactory];
}

@end
