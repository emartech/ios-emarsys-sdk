//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <OCMock/OCMock.h>
#import "EMSRequestModelBuilder.h"
#import "EMSSQLiteHelper.h"
#import "EMSSqliteSchemaHandler.h"
#import "EMSSchemaContract.h"
#import "EMSWorkerProtocol.h"
#import "EMSDefaultWorker.h"
#import "FakeCompletionHandler.h"
#import "FakeConnectionWatchdog.h"
#import "EMSRequestModelRepository.h"
#import "EMSShardRepository.h"
#import "EMSFilterByNothingSpecification.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSCompletionMiddleware.h"
#import "EMSRequestManager.h"
#import "EMSWaiter.h"
#import "EMSRESTClientCompletionProxyFactory.h"
#import "EMSMobileEngageNullSafeBodyParser.h"

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestDB.db"]

@interface OfflineTests : XCTestCase

@property(nonatomic, strong) EMSSQLiteHelper *helper;
@property(nonatomic, strong) EMSRequestModelRepository *requestModelRepository;
@property(nonatomic, strong) EMSShardRepository *shardRepository;
@property(nonatomic, strong) EMSReachability *reachability;

@end

@implementation OfflineTests

- (void)setUp {
    _reachability = [EMSReachability reachabilityForInternetConnectionWithOperationQueue:[self createTestQueue]];
    
    [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                               error:nil];
    _helper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                             schemaDelegate:[EMSSqliteSchemaHandler new]];
    [self.helper open];
    [self.helper executeCommand:SQL_REQUEST_PURGE];
    
    _requestModelRepository = [[EMSRequestModelRepository alloc] initWithDbHelper:self.helper
                                                                   operationQueue:[NSOperationQueue new]];
    _shardRepository = [EMSShardRepository new];
}

- (void)tearDown {
    [self.helper close];
    [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                               error:nil];
}

- (void)testShouldReceive3Response_when3RequestHasBeenSent{
    EMSRequestModel *model1 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"https://denna.gservice.emarsys.net/echo"];
        [builder setMethod:HTTPMethodGET];
    }
                                             timestampProvider:[EMSTimestampProvider new]
                                                  uuidProvider:[EMSUUIDProvider new]];
    EMSRequestModel *model2 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"https://denna.gservice.emarsys.net/echo"];
        [builder setMethod:HTTPMethodGET];
    }
                                             timestampProvider:[EMSTimestampProvider new]
                                                  uuidProvider:[EMSUUIDProvider new]];
    EMSRequestModel *model3 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"https://denna.gservice.emarsys.net/echo"];
        [builder setMethod:HTTPMethodGET];
    }
                                             timestampProvider:[EMSTimestampProvider new]
                                                  uuidProvider:[EMSUUIDProvider new]];
    
    NSOperationQueue *operationQueue = [self createTestQueue];
    FakeConnectionWatchdog *watchdog = [[FakeConnectionWatchdog alloc] initWithOperationQueue:operationQueue
                                                                          connectionResponses:@[@YES, @YES, @YES]
                                                                                 reachability:self.reachability
                                                                                  expectation:nil];
    FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
    EMSRequestManager *manager = [self createRequestManagerWithOperationQueue:operationQueue
                                                                   repository:self.requestModelRepository
                                                                     watchdog:watchdog
                                                                 successBlock:completionHandler.successBlock errorBlock:completionHandler.errorBlock];
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    [expectation setExpectedFulfillmentCount:3];
    [manager submitRequestModel:model1
            withCompletionBlock:^(NSError *error) {
        [expectation fulfill];
    }];
    [manager submitRequestModel:model2
            withCompletionBlock:^(NSError *error) {
        [expectation fulfill];
    }];
    [manager submitRequestModel:model3
            withCompletionBlock:^(NSError *error) {
        [expectation fulfill];
    }];
    
    [EMSWaiter waitForExpectations:@[expectation]];
}

- (void)testShouldReceive0Response_requestModelRepositoryCount3When3RequestSentAndThereIsNoInternetConnection{
    EMSRequestModel *model1 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"https://denna.gservice.emarsys.net/echo"];
        [builder setMethod:HTTPMethodGET];
    }
                                             timestampProvider:[EMSTimestampProvider new]
                                                  uuidProvider:[EMSUUIDProvider new]];
    EMSRequestModel *model2 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"https://denna.gservice.emarsys.net/echo"];
        [builder setMethod:HTTPMethodGET];
    }
                                             timestampProvider:[EMSTimestampProvider new]
                                                  uuidProvider:[EMSUUIDProvider new]];
    EMSRequestModel *model3 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"https://denna.gservice.emarsys.net/echo"];
        [builder setMethod:HTTPMethodGET];
    }
                                             timestampProvider:[EMSTimestampProvider new]
                                                  uuidProvider:[EMSUUIDProvider new]];
    
    NSOperationQueue *operationQueue = [self createTestQueue];
    
    XCTestExpectation *watchdogExpectation = [[XCTestExpectation alloc] initWithDescription:@"waitForConnectionWatchdog"];
    [watchdogExpectation setExpectedFulfillmentCount:3];
    FakeConnectionWatchdog *watchdog = [[FakeConnectionWatchdog alloc] initWithOperationQueue:operationQueue
                                                                          connectionResponses:@[@NO, @NO, @NO]
                                                                                 reachability:self.reachability
                                                                                  expectation:watchdogExpectation];
    FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
    EMSRequestManager *manager = [self createRequestManagerWithOperationQueue:operationQueue
                                                                   repository:self.requestModelRepository
                                                                     watchdog:watchdog
                                                                 successBlock:completionHandler.successBlock errorBlock:completionHandler.errorBlock];
    
    [manager submitRequestModel:model1
            withCompletionBlock:nil];
    [manager submitRequestModel:model2
            withCompletionBlock:nil];
    [manager submitRequestModel:model3
            withCompletionBlock:nil];
    
    [EMSWaiter waitForExpectations:@[watchdogExpectation]];
    
    XCTAssertEqualObjects(watchdog.isConnectedCallCount, @3);
    XCTAssertEqualObjects(completionHandler.successCount, @0);
    XCTAssertEqualObjects(completionHandler.errorCount, @0);
    
    [self assertForItemsCountInDbWithExpectedItemsCount:3
                                         operationQueue:operationQueue
                                 requestModelRepository:self.requestModelRepository];
}

- (void)testShouldReceive2Response_requestModelRepositoryCount1When3RequestSentAndConnectionsAreYES_YES_NO {
    EMSRequestModel *model1 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"https://denna.gservice.emarsys.net/echo"];
        [builder setMethod:HTTPMethodGET];
    }
                                             timestampProvider:[EMSTimestampProvider new]
                                                  uuidProvider:[EMSUUIDProvider new]];
    EMSRequestModel *model2 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"https://denna.gservice.emarsys.net/echo"];
        [builder setMethod:HTTPMethodGET];
    }
                                             timestampProvider:[EMSTimestampProvider new]
                                                  uuidProvider:[EMSUUIDProvider new]];
    EMSRequestModel *model3 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"https://denna.gservice.emarsys.net/echo"];
        [builder setMethod:HTTPMethodGET];
    }
                                             timestampProvider:[EMSTimestampProvider new]
                                                  uuidProvider:[EMSUUIDProvider new]];
    NSOperationQueue *operationQueue = [self createTestQueue];
    
    XCTestExpectation *watchdogExpectation = [[XCTestExpectation alloc] initWithDescription:@"waitForConnectionWatchdog"];
    [watchdogExpectation setExpectedFulfillmentCount:3];
    FakeConnectionWatchdog *watchdog = [[FakeConnectionWatchdog alloc] initWithOperationQueue:operationQueue
                                                                          connectionResponses:@[@YES, @YES, @NO]
                                                                                 reachability:self.reachability
                                                                                  expectation:watchdogExpectation];
    FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
    EMSRequestManager *manager = [self createRequestManagerWithOperationQueue:operationQueue
                                                                   repository:self.requestModelRepository
                                                                     watchdog:watchdog
                                                                 successBlock:completionHandler.successBlock errorBlock:completionHandler.errorBlock];
    
    XCTestExpectation *completionBlockExpectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionBlocks"];
    [completionBlockExpectation setExpectedFulfillmentCount:2];
    [manager submitRequestModel:model1
            withCompletionBlock:^(NSError *error) {
        [completionBlockExpectation fulfill];
    }];
    [manager submitRequestModel:model2
            withCompletionBlock:^(NSError *error) {
        [completionBlockExpectation fulfill];
    }];
    [manager submitRequestModel:model3
            withCompletionBlock:nil];
    
    [EMSWaiter waitForExpectations:@[watchdogExpectation, completionBlockExpectation]];
    
    XCTAssertEqualObjects(watchdog.isConnectedCallCount, @3);
    XCTAssertEqualObjects(completionHandler.successCount, @2);
    XCTAssertEqualObjects(completionHandler.errorCount, @0);
    
    [self assertForItemsCountInDbWithExpectedItemsCount:1
                                         operationQueue:operationQueue
                                 requestModelRepository:self.requestModelRepository];
}

- (void)testShouldStopTheWorkerWhenResponseIs500{
    EMSRequestModel *model1 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"https://denna.gservice.emarsys.net/echo"];
        [builder setMethod:HTTPMethodGET];
    }
                                             timestampProvider:[EMSTimestampProvider new]
                                                  uuidProvider:[EMSUUIDProvider new]];
    EMSRequestModel *model2 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:[NSString stringWithFormat:@"https://denna.gservice.emarsys.net%@",
                         @"/customResponseCode/500"]];
        [builder setMethod:HTTPMethodGET];
    }
                                             timestampProvider:[EMSTimestampProvider new]
                                                  uuidProvider:[EMSUUIDProvider new]];
    EMSRequestModel *model3 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"https://denna.gservice.emarsys.net/echo"];
        [builder setMethod:HTTPMethodGET];
    }
                                             timestampProvider:[EMSTimestampProvider new]
                                                  uuidProvider:[EMSUUIDProvider new]];
    
    NSOperationQueue *operationQueue = [self createTestQueue];
    
    XCTestExpectation *watchdogExpectation = [[XCTestExpectation alloc] initWithDescription:@"waitForConnectionWatchdog"];
    [watchdogExpectation setExpectedFulfillmentCount:2];
    FakeConnectionWatchdog *watchdog = [[FakeConnectionWatchdog alloc] initWithOperationQueue:operationQueue
                                                                          connectionResponses:@[@YES, @YES, @YES]
                                                                                 reachability:self.reachability
                                                                                  expectation:watchdogExpectation];
    FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
    EMSRequestManager *manager = [self createRequestManagerWithOperationQueue:operationQueue
                                                                   repository:self.requestModelRepository
                                                                     watchdog:watchdog
                                                                 successBlock:completionHandler.successBlock errorBlock:completionHandler.errorBlock];
    
    XCTestExpectation *completionBlockExpectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionBlocks"];
    [completionBlockExpectation setExpectedFulfillmentCount:1];
    [manager submitRequestModel:model1
            withCompletionBlock:^(NSError *error) {
        [completionBlockExpectation fulfill];
    }];
    [manager submitRequestModel:model2
            withCompletionBlock:nil];
    [manager submitRequestModel:model3
            withCompletionBlock:nil];
    
    [EMSWaiter waitForExpectations:@[watchdogExpectation, completionBlockExpectation]];
    
    XCTAssertEqualObjects(watchdog.isConnectedCallCount, @2);
    XCTAssertEqualObjects(completionHandler.successCount, @1);
    XCTAssertEqualObjects(completionHandler.errorCount, @0);
    
    [self assertForItemsCountInDbWithExpectedItemsCount:2
                                         operationQueue:operationQueue
                                 requestModelRepository:self.requestModelRepository];
}

- (void)testShouldNotStopTheWorkerWhenResponseIs4xx {
    EMSRequestModel *model1 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"https://denna.gservice.emarsys.net/echo"];
        [builder setMethod:HTTPMethodGET];
    }
                                             timestampProvider:[EMSTimestampProvider new]
                                                  uuidProvider:[EMSUUIDProvider new]];
    EMSRequestModel *model2 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"https://denna.gservice.emarsys.net/customResponseCode/404"];
        [builder setMethod:HTTPMethodGET];
    }
                                             timestampProvider:[EMSTimestampProvider new]
                                                  uuidProvider:[EMSUUIDProvider new]];
    EMSRequestModel *model3 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"https://denna.gservice.emarsys.net/echo"];
        [builder setMethod:HTTPMethodGET];
    }
                                             timestampProvider:[EMSTimestampProvider new]
                                                  uuidProvider:[EMSUUIDProvider new]];
    
    NSOperationQueue *operationQueue = [self createTestQueue];
    operationQueue.maxConcurrentOperationCount = 1;
    XCTestExpectation *watchdogExpectation = [[XCTestExpectation alloc] initWithDescription:@"waitForConnectionWatchdog"];
    [watchdogExpectation setExpectedFulfillmentCount:4];
    FakeConnectionWatchdog *watchdog = [[FakeConnectionWatchdog alloc] initWithOperationQueue:operationQueue
                                                                          connectionResponses:@[@YES, @YES, @YES]
                                                                                 reachability:self.reachability
                                                                                  expectation:watchdogExpectation];
    FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
    EMSRequestManager *manager = [self createRequestManagerWithOperationQueue:operationQueue
                                                                   repository:self.requestModelRepository
                                                                     watchdog:watchdog
                                                                 successBlock:completionHandler.successBlock errorBlock:completionHandler.errorBlock];
    
    XCTestExpectation *completionBlockExpectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionBlocks"];
    completionBlockExpectation.expectedFulfillmentCount = 2;
    
    [manager submitRequestModel:model1
            withCompletionBlock:^(NSError *error) {
        [completionBlockExpectation fulfill];
    }];
    [manager submitRequestModel:model2
            withCompletionBlock:nil];
    [manager submitRequestModel:model3
            withCompletionBlock:^(NSError *error) {
        [completionBlockExpectation fulfill];
    }];
    
    [EMSWaiter waitForExpectations:@[watchdogExpectation, completionBlockExpectation]];
    
    XCTAssertEqualObjects(watchdog.isConnectedCallCount, @4);
    XCTAssertEqualObjects(completionHandler.successCount, @2);
    XCTAssertEqualObjects(completionHandler.errorCount, @1);
    
    [self assertForItemsCountInDbWithExpectedItemsCount:0
                                         operationQueue:operationQueue
                                 requestModelRepository:self.requestModelRepository];
}

- (void)testShouldStopTheWorkerWhenResponseIs408 {
    EMSRequestModel *model1 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"https://denna.gservice.emarsys.net/echo"];
        [builder setMethod:HTTPMethodGET];
    }
                                             timestampProvider:[EMSTimestampProvider new]
                                                  uuidProvider:[EMSUUIDProvider new]];
    EMSRequestModel *model2 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:[NSString stringWithFormat:@"https://denna.gservice.emarsys.net%@",
                         @"customResponseCode/408"]];
        [builder setMethod:HTTPMethodGET];
    }
                                             timestampProvider:[EMSTimestampProvider new]
                                                  uuidProvider:[EMSUUIDProvider new]];
    EMSRequestModel *model3 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"https://denna.gservice.emarsys.net/echo"];
        [builder setMethod:HTTPMethodGET];
    }
                                             timestampProvider:[EMSTimestampProvider new]
                                                  uuidProvider:[EMSUUIDProvider new]];
    
    NSOperationQueue *operationQueue = [self createTestQueue];
    XCTestExpectation *watchdogExpectation = [[XCTestExpectation alloc] initWithDescription:@"waitForConnectionWatchdog"];
    [watchdogExpectation setExpectedFulfillmentCount:2];
    FakeConnectionWatchdog *watchdog = [[FakeConnectionWatchdog alloc] initWithOperationQueue:operationQueue
                                                                          connectionResponses:@[@YES, @YES, @YES]
                                                                                 reachability:self.reachability
                                                                                  expectation:watchdogExpectation];
    FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
    EMSRequestManager *manager = [self createRequestManagerWithOperationQueue:operationQueue
                                                                   repository:self.requestModelRepository
                                                                     watchdog:watchdog
                                                                 successBlock:completionHandler.successBlock errorBlock:completionHandler.errorBlock];
    
    XCTestExpectation *completionBlockExpectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionBlocks"];
    completionBlockExpectation.expectedFulfillmentCount = 1;
    
    [manager submitRequestModel:model1
            withCompletionBlock:^(NSError *error) {
        [completionBlockExpectation fulfill];
    }];
    [manager submitRequestModel:model2
            withCompletionBlock:nil];
    [manager submitRequestModel:model3
            withCompletionBlock:nil];
    
    [EMSWaiter waitForExpectations:@[watchdogExpectation, completionBlockExpectation]];
    
    XCTAssertEqualObjects(watchdog.isConnectedCallCount, @2);
    XCTAssertEqualObjects(completionHandler.successCount, @1);
    XCTAssertEqualObjects(completionHandler.errorCount, @0);
    
    [self assertForItemsCountInDbWithExpectedItemsCount:2
                                         operationQueue:operationQueue
                                 requestModelRepository:self.requestModelRepository];
}

- (EMSRequestManager *)createRequestManagerWithOperationQueue:(NSOperationQueue *)operationQueue
                                                   repository:(id <EMSRequestModelRepositoryProtocol>)repository
                                                     watchdog:(EMSConnectionWatchdog *)watchdog
                                                 successBlock:(CoreSuccessBlock)successBlock
                                                   errorBlock:(CoreErrorBlock)errorBlock {
    EMSCompletionMiddleware *middleware = [[EMSCompletionMiddleware alloc] initWithSuccessBlock:successBlock
                                                                                     errorBlock:errorBlock];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setTimeoutIntervalForRequest:60.0];
    [sessionConfiguration setHTTPCookieStorage:nil];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                          delegate:nil
                                                     delegateQueue:operationQueue];
    
    EMSMobileEngageNullSafeBodyParser *mobileEngageNullSafeBodyParser = [[EMSMobileEngageNullSafeBodyParser alloc] initWithEndpoint:OCMClassMock([EMSEndpoint class])];
    
    EMSRESTClient *restClient = [[EMSRESTClient alloc] initWithSession:session
                                                                 queue:operationQueue
                                                     timestampProvider:[EMSTimestampProvider new]
                                                     additionalHeaders:nil
                                                   requestModelMappers:nil
                                                      responseHandlers:nil
                                                mobileEngageBodyParser:mobileEngageNullSafeBodyParser];
    EMSRESTClientCompletionProxyFactory *proxyFactory = [[EMSRESTClientCompletionProxyFactory alloc] initWithRequestRepository:repository
                                                                                                                operationQueue:operationQueue
                                                                                                           defaultSuccessBlock:middleware.successBlock
                                                                                                             defaultErrorBlock:middleware.errorBlock];
    EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:operationQueue
                                                              requestRepository:repository
                                                             connectionWatchdog:watchdog
                                                                     restClient:restClient
                                                                     errorBlock:middleware.errorBlock
                                                                   proxyFactory:proxyFactory];
    
    return [[EMSRequestManager alloc] initWithCoreQueue:operationQueue
                                   completionMiddleware:middleware
                                             restClient:restClient
                                                 worker:worker
                                      requestRepository:repository
                                        shardRepository:[EMSShardRepository new]
                                           proxyFactory:proxyFactory];
}

- (NSOperationQueue *)createTestQueue {
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = 1;
    queue.qualityOfService = NSQualityOfServiceUtility;
    return queue;
}

- (void)assertForItemsCountInDbWithExpectedItemsCount:(int)expectedItemsCount
                                       operationQueue:(NSOperationQueue *)operationQueue
                               requestModelRepository:(EMSRequestModelRepository *)requestModelRepository {
    __block NSArray<EMSRequestModel *> *items = nil;
    XCTestExpectation *itemsExpectation = [[XCTestExpectation alloc] initWithDescription:@"waitForQueryResult"];
    [operationQueue addOperationWithBlock:^{
        items = [requestModelRepository query:[EMSFilterByNothingSpecification new]];
        [itemsExpectation fulfill];
    }];
    [EMSWaiter waitForExpectations:@[itemsExpectation]];
    XCTAssertEqual([items count], expectedItemsCount);
}

@end
