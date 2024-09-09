//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSRequestModel.h"
#import "EMSRequestManager.h"
#import "EMSResponseModel.h"
#import "NSDictionary+EMSCore.h"
#import "EMSSQLiteHelper.h"
#import "EMSRequestModelRepository.h"
#import "EMSShardRepository.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSDefaultWorker.h"
#import "EMSSqliteSchemaHandler.h"
#import "EMSOperationQueue.h"
#import "EMSRESTClientCompletionProxyFactory.h"
#import "EMSMobileEngageNullSafeBodyParser.h"
#import "XCTestCase+Helper.h"
#import "EmarsysTestUtils.h"

#define DennaUrl(ending) [NSString stringWithFormat:@"https://denna.gservice.emarsys.net%@", ending];
#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestDB.db"]

@interface DennaTest : XCTestCase

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSOperationQueue *dbQueue;
@property (nonatomic, strong) EMSSQLiteHelper *dbHelper;

@end

@implementation DennaTest

- (void)setUp {
    [super setUp];
    self.queue = [self createTestOperationQueue];
    self.dbQueue = [self createTestOperationQueue];
    self.dbHelper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                   schemaDelegate:[EMSSqliteSchemaHandler new]
                                                   operationQueue:self.dbQueue];
    [self.dbHelper open];
}

- (void)tearDown {
    [EmarsysTestUtils tearDownOperationQueue:self.queue];
    [EmarsysTestUtils clearDb:self.dbHelper];
    [super tearDown];
}

- (void)testError500 {
    NSString *error500 = DennaUrl(@"/customResponseCode/500");
    
    EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:error500];
        [builder setMethod:HTTPMethodGET];
    }
                                            timestampProvider:[EMSTimestampProvider new]
                                                 uuidProvider:[EMSUUIDProvider new]];
    
    EMSCompletionMiddleware *middleware = [[EMSCompletionMiddleware alloc] initWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
        XCTFail(@"successBlock invoked :'(");
    }
                                                                                     errorBlock:^(NSString *requestId, NSError *error) {
        NSLog(@"ERROR!");
        XCTFail(@"errorblock invoked");
    }];
    
    EMSRequestModelRepository *requestRepository = [[EMSRequestModelRepository alloc] initWithDbHelper:self.dbHelper
                                                                                        operationQueue:self.queue];
    EMSShardRepository *shardRepository = [EMSShardRepository new];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setTimeoutIntervalForRequest:30.0];
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
    EMSRequestManager *core = [[EMSRequestManager alloc] initWithCoreQueue:self.queue
                                                      completionMiddleware:middleware
                                                                restClient:restClient
                                                                    worker:worker
                                                         requestRepository:requestRepository
                                                           shardRepository:shardRepository
                                                              proxyFactory:proxyFactory];
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    [core submitRequestModel:model
         withCompletionBlock:^(NSError *error) {
        [expectation fulfill];
    }];
    
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:10];
    XCTAssertEqual(result, XCTWaiterResultTimedOut);
}

- (void)testShouldRespondWithGetRequestHeadersBody {
    NSString *echo = DennaUrl(@"/echo");
    NSDictionary *inputHeaders = @{@"header1": @"value1", @"header2": @"value2"};
    
    EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:echo];
        [builder setMethod:HTTPMethodGET];
        [builder setHeaders:inputHeaders];
    }
                                            timestampProvider:[EMSTimestampProvider new]
                                                 uuidProvider:[EMSUUIDProvider new]];
    
    [self shouldEventuallySucceed:model method:@"GET" headers:inputHeaders body:nil];
}

- (void)testShouldRespondWithPostRequestHeadersBody {
    NSString *echo = DennaUrl(@"/echo");
    NSDictionary *inputHeaders = @{@"header1": @"value1", @"header2": @"value2"};
    NSDictionary *payload = @{@"key1": @"val1", @"key2": @"val2", @"key3": @"val3"};
    
    EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:echo];
        [builder setMethod:HTTPMethodPOST];
        [builder setHeaders:inputHeaders];
        [builder setPayload:payload];
    }
                                            timestampProvider:[EMSTimestampProvider new]
                                                 uuidProvider:[EMSUUIDProvider new]];
    
    [self shouldEventuallySucceed:model method:@"POST" headers:inputHeaders body:payload];
}

- (void)testShouldRespondWithPutRequestHeadersBody {
    NSString *echo = DennaUrl(@"/echo");
    NSDictionary *inputHeaders = @{@"header1": @"value1", @"header2": @"value2"};
    NSDictionary *payload = @{@"key1": @"val1", @"key2": @"val2", @"key3": @"val3"};
    
    EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:echo];
        [builder setMethod:HTTPMethodPUT];
        [builder setHeaders:inputHeaders];
        [builder setPayload:payload];
    }
                                            timestampProvider:[EMSTimestampProvider new]
                                                 uuidProvider:[EMSUUIDProvider new]];
    
    [self shouldEventuallySucceed:model method:@"PUT" headers:inputHeaders body:payload];
}

- (void)testShouldRespondWithDeleteRequestHeadersBody {
    NSString *echo = DennaUrl(@"/echo");
    NSDictionary *inputHeaders = @{@"header1": @"value1", @"header2": @"value2"};
    
    EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:echo];
        [builder setMethod:HTTPMethodDELETE];
        [builder setHeaders:inputHeaders];
    }
                                            timestampProvider:[EMSTimestampProvider new]
                                                 uuidProvider:[EMSUUIDProvider new]];
    
    [self shouldEventuallySucceed:model method:@"DELETE" headers:inputHeaders body:nil];
}

- (void)shouldEventuallySucceed:(EMSRequestModel *)model
                         method:(NSString *)method
                        headers:(NSDictionary<NSString *, NSString *> *)headers
                           body:(NSDictionary<NSString *, id> *)body {
    __block NSString *checkableRequestId;
    __block NSString *resultMethod;
    __block BOOL expectedSubsetOfResultHeaders;
    __block NSDictionary<NSString *, id> *resultPayload;
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForMiddleware"];
    EMSCompletionMiddleware *middleware = [[EMSCompletionMiddleware alloc] initWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
        checkableRequestId = requestId;
        NSDictionary<NSString *, id> *returnedPayload = [NSJSONSerialization JSONObjectWithData:response.body
                                                                                        options:NSJSONReadingFragmentsAllowed
                                                                                          error:nil];
        NSLog(@"RequestId: %@, responsePayload: %@", requestId, returnedPayload);
        resultMethod = returnedPayload[@"method"];
        expectedSubsetOfResultHeaders = [returnedPayload[@"headers"] subsetOfDictionary:headers];
        resultPayload = returnedPayload[@"body"];
        [expectation fulfill];
    }
                                                                                     errorBlock:^(NSString *requestId, NSError *error) {
        NSLog(@"ERROR!");
        XCTFail(@"errorblock invoked");
    }];
    
    EMSRequestModelRepository *requestRepository = [[EMSRequestModelRepository alloc] initWithDbHelper:self.dbHelper
                                                                                        operationQueue:self.queue];
    EMSShardRepository *shardRepository = [EMSShardRepository new];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setTimeoutIntervalForRequest:30.0];
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
    EMSRequestManager *core = [[EMSRequestManager alloc] initWithCoreQueue:self.queue
                                                      completionMiddleware:middleware
                                                                restClient:restClient
                                                                    worker:worker
                                                         requestRepository:requestRepository
                                                           shardRepository:shardRepository
                                                              proxyFactory:proxyFactory];
    [core submitRequestModel:model
         withCompletionBlock:nil];
    
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation] 
                                                          timeout:10.0];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(resultMethod, method);
    XCTAssertEqual(expectedSubsetOfResultHeaders, YES);
    if (body) {
        XCTAssertEqualObjects(resultPayload, body);
    }
    XCTAssertEqualObjects(model.requestId, checkableRequestId);
}

@end
