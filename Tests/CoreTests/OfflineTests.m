//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
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

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestDB.db"]

SPEC_BEGIN(OfflineTests)

        __block EMSSQLiteHelper *helper;
        __block EMSRequestModelRepository *requestModelRepository;
        __block EMSShardRepository *shardRepository;

        id (^requestManager)(NSOperationQueue *operationQueue, id <EMSRequestModelRepositoryProtocol> repository, EMSConnectionWatchdog *watchdog, CoreSuccessBlock successBlock, CoreErrorBlock errorBlock) = ^id(NSOperationQueue *operationQueue, id <EMSRequestModelRepositoryProtocol> repository, EMSConnectionWatchdog *watchdog, CoreSuccessBlock successBlock, CoreErrorBlock errorBlock) {
            EMSCompletionMiddleware *middleware = [[EMSCompletionMiddleware alloc] initWithSuccessBlock:successBlock
                                                                                             errorBlock:errorBlock];

            NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
            [sessionConfiguration setTimeoutIntervalForRequest:30.0];
            [sessionConfiguration setHTTPCookieStorage:nil];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                                  delegate:nil
                                                             delegateQueue:operationQueue];

            EMSRESTClient *restClient = [[EMSRESTClient alloc] initWithSession:session
                                                                         queue:operationQueue
                                                             timestampProvider:[EMSTimestampProvider new]
                                                             additionalHeaders:nil
                                                           requestModelMappers:nil
                                                              responseHandlers:nil];
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
        };

        NSOperationQueue *(^testQueue)(void) = ^NSOperationQueue * {
            NSOperationQueue *queue = [NSOperationQueue new];
            queue.maxConcurrentOperationCount = 1;
            queue.qualityOfService = NSQualityOfServiceUtility;
            return queue;
        };

        void (^assertForItemsCountInDb)(int expectedItemsCount, NSOperationQueue *operationQueue, EMSRequestModelRepository *requestModelRepository) = ^(int expectedItemsCount, NSOperationQueue *operationQueue, EMSRequestModelRepository *requestModelRepository) {
            __block NSArray<EMSRequestModel *> *items = nil;
            XCTestExpectation *itemsExpectation = [[XCTestExpectation alloc] initWithDescription:@"waitForQueryResult"];
            [operationQueue addOperationWithBlock:^{
                items = [requestModelRepository query:[EMSFilterByNothingSpecification new]];
                [itemsExpectation fulfill];
            }];
            [EMSWaiter waitForExpectations:@[itemsExpectation]];

            [[theValue([items count]) should] equal:theValue(expectedItemsCount)];
        };

        describe(@"EMSRequestManager", ^{

            beforeEach(^{
                [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                                           error:nil];
                helper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                        schemaDelegate:[EMSSqliteSchemaHandler new]];
                [helper open];
                [helper executeCommand:SQL_REQUEST_PURGE];

                requestModelRepository = [[EMSRequestModelRepository alloc] initWithDbHelper:helper];
                shardRepository = [EMSShardRepository new];
            });

            afterEach(^{
                [helper close];
                [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                                           error:nil];
            });

            it(@"should receive 3 response, when 3 request has been sent", ^{
                EMSRequestModel *model1 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"https://www.google.com"];
                        [builder setMethod:HTTPMethodGET];
                    }
                                                         timestampProvider:[EMSTimestampProvider new]
                                                              uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model2 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"https://www.yahoo.com"];
                        [builder setMethod:HTTPMethodGET];
                    }
                                                         timestampProvider:[EMSTimestampProvider new]
                                                              uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model3 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"https://www.wolframalpha.com"];
                        [builder setMethod:HTTPMethodGET];
                    }
                                                         timestampProvider:[EMSTimestampProvider new]
                                                              uuidProvider:[EMSUUIDProvider new]];

                NSOperationQueue *operationQueue = testQueue();
                FakeConnectionWatchdog *watchdog = [[FakeConnectionWatchdog alloc] initWithOperationQueue:operationQueue
                                                                                      connectionResponses:@[@YES, @YES, @YES]
                                                                                              expectation:nil];
                FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
                EMSRequestManager *manager = requestManager(operationQueue, requestModelRepository, watchdog, completionHandler.successBlock, completionHandler.errorBlock);

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
            });

            it(@"should receive 0 response, requestModelRepository count 3 when 3 request sent and there is no internet connection", ^{
                EMSRequestModel *model1 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"https://www.google.com"];
                        [builder setMethod:HTTPMethodGET];
                    }
                                                         timestampProvider:[EMSTimestampProvider new]
                                                              uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model2 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"https://www.yahoo.com"];
                        [builder setMethod:HTTPMethodGET];
                    }
                                                         timestampProvider:[EMSTimestampProvider new]
                                                              uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model3 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"https://www.wolframalpha.com"];
                        [builder setMethod:HTTPMethodGET];
                    }
                                                         timestampProvider:[EMSTimestampProvider new]
                                                              uuidProvider:[EMSUUIDProvider new]];

                NSOperationQueue *operationQueue = testQueue();

                XCTestExpectation *watchdogExpectation = [[XCTestExpectation alloc] initWithDescription:@"waitForConnectionWatchdog"];
                [watchdogExpectation setExpectedFulfillmentCount:3];
                FakeConnectionWatchdog *watchdog = [[FakeConnectionWatchdog alloc] initWithOperationQueue:operationQueue
                                                                                      connectionResponses:@[@NO, @NO, @NO]
                                                                                              expectation:watchdogExpectation];
                FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
                EMSRequestManager *manager = requestManager(operationQueue, requestModelRepository, watchdog, completionHandler.successBlock, completionHandler.errorBlock);

                [manager submitRequestModel:model1
                        withCompletionBlock:nil];
                [manager submitRequestModel:model2
                        withCompletionBlock:nil];
                [manager submitRequestModel:model3
                        withCompletionBlock:nil];

                [EMSWaiter waitForExpectations:@[watchdogExpectation]];

                [[watchdog.isConnectedCallCount should] equal:@3];
                [[completionHandler.successCount should] equal:@0];
                [[completionHandler.errorCount should] equal:@0];

                assertForItemsCountInDb(3, operationQueue, requestModelRepository);
            });

            it(@"should receive 2 response, requestModelRepository count 1 when 3 request sent and connections:YES, YES, NO", ^{
                EMSRequestModel *model1 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"https://www.google.com"];
                        [builder setMethod:HTTPMethodGET];
                    }
                                                         timestampProvider:[EMSTimestampProvider new]
                                                              uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model2 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"https://www.yahoo.com"];
                        [builder setMethod:HTTPMethodGET];
                    }
                                                         timestampProvider:[EMSTimestampProvider new]
                                                              uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model3 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"https://www.wolframalpha.com"];
                        [builder setMethod:HTTPMethodGET];
                    }
                                                         timestampProvider:[EMSTimestampProvider new]
                                                              uuidProvider:[EMSUUIDProvider new]];
                NSOperationQueue *operationQueue = testQueue();

                XCTestExpectation *watchdogExpectation = [[XCTestExpectation alloc] initWithDescription:@"waitForConnectionWatchdog"];
                [watchdogExpectation setExpectedFulfillmentCount:3];
                FakeConnectionWatchdog *watchdog = [[FakeConnectionWatchdog alloc] initWithOperationQueue:operationQueue
                                                                                      connectionResponses:@[@YES, @YES, @NO]
                                                                                              expectation:watchdogExpectation];
                FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
                EMSRequestManager *manager = requestManager(operationQueue, requestModelRepository, watchdog, completionHandler.successBlock, completionHandler.errorBlock);

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
                [manager submitRequestModel:model3 withCompletionBlock:nil];

                [EMSWaiter waitForExpectations:@[watchdogExpectation, completionBlockExpectation]];

                [[watchdog.isConnectedCallCount should] equal:@3];
                [[completionHandler.successCount should] equal:@2];
                [[completionHandler.errorCount should] equal:@0];

                assertForItemsCountInDb(1, operationQueue, requestModelRepository);
            });

            it(@"should stop the worker when response is 500", ^{
                EMSRequestModel *model1 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"https://www.google.com"];
                        [builder setMethod:HTTPMethodGET];
                    }
                                                         timestampProvider:[EMSTimestampProvider new]
                                                              uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model2 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:[NSString stringWithFormat:@"https://ems-denna.herokuapp.com%@",
                                                                   @"/customResponseCode/500"]];
                        [builder setMethod:HTTPMethodGET];
                    }
                                                         timestampProvider:[EMSTimestampProvider new]
                                                              uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model3 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"https://www.wolframalpha.com"];
                        [builder setMethod:HTTPMethodGET];
                    }
                                                         timestampProvider:[EMSTimestampProvider new]
                                                              uuidProvider:[EMSUUIDProvider new]];

                NSOperationQueue *operationQueue = testQueue();

                XCTestExpectation *watchdogExpectation = [[XCTestExpectation alloc] initWithDescription:@"waitForConnectionWatchdog"];
                [watchdogExpectation setExpectedFulfillmentCount:2];
                FakeConnectionWatchdog *watchdog = [[FakeConnectionWatchdog alloc] initWithOperationQueue:operationQueue
                                                                                      connectionResponses:@[@YES, @YES, @YES]
                                                                                              expectation:watchdogExpectation];
                FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
                EMSRequestManager *manager = requestManager(operationQueue, requestModelRepository, watchdog, completionHandler.successBlock, completionHandler.errorBlock);

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

                [[watchdog.isConnectedCallCount should] equal:@2];
                [[completionHandler.successCount should] equal:@1];
                [[completionHandler.errorCount should] equal:@0];

                assertForItemsCountInDb(2, operationQueue, requestModelRepository);
            });

            it(@"should not stop the worker when response is 4xx", ^{
                EMSRequestModel *model1 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"https://www.google.com"];
                        [builder setMethod:HTTPMethodGET];
                    }
                                                         timestampProvider:[EMSTimestampProvider new]
                                                              uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model2 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"https://alma.korte.szilva/egyeb/palinkagyumolcsok"];
                        [builder setMethod:HTTPMethodGET];
                    }
                                                         timestampProvider:[EMSTimestampProvider new]
                                                              uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model3 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"https://www.wolframalpha.com"];
                        [builder setMethod:HTTPMethodGET];
                    }
                                                         timestampProvider:[EMSTimestampProvider new]
                                                              uuidProvider:[EMSUUIDProvider new]];

                NSOperationQueue *operationQueue = testQueue();
                operationQueue.maxConcurrentOperationCount = 1;
                XCTestExpectation *watchdogExpectation = [[XCTestExpectation alloc] initWithDescription:@"waitForConnectionWatchdog"];
                [watchdogExpectation setExpectedFulfillmentCount:4];
                FakeConnectionWatchdog *watchdog = [[FakeConnectionWatchdog alloc] initWithOperationQueue:operationQueue
                                                                                      connectionResponses:@[@YES, @YES, @YES]
                                                                                              expectation:watchdogExpectation];
                FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
                EMSRequestManager *manager = requestManager(operationQueue, requestModelRepository, watchdog, completionHandler.successBlock, completionHandler.errorBlock);

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

                [[watchdog.isConnectedCallCount should] equal:@4];
                [[completionHandler.successCount should] equal:@2];
                [[completionHandler.errorCount should] equal:@1];

                assertForItemsCountInDb(0, operationQueue, requestModelRepository);
            });

            it(@"should stop the worker when response is 408", ^{
                EMSRequestModel *model1 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"https://www.google.com"];
                        [builder setMethod:HTTPMethodGET];
                    }
                                                         timestampProvider:[EMSTimestampProvider new]
                                                              uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model2 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:[NSString stringWithFormat:@"https://ems-denna.herokuapp.com%@",
                                                                   @"customResponseCode/408"]];
                        [builder setMethod:HTTPMethodGET];
                    }
                                                         timestampProvider:[EMSTimestampProvider new]
                                                              uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model3 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"https://www.wolframalpha.com"];
                        [builder setMethod:HTTPMethodGET];
                    }
                                                         timestampProvider:[EMSTimestampProvider new]
                                                              uuidProvider:[EMSUUIDProvider new]];

                NSOperationQueue *operationQueue = testQueue();
                XCTestExpectation *watchdogExpectation = [[XCTestExpectation alloc] initWithDescription:@"waitForConnectionWatchdog"];
                [watchdogExpectation setExpectedFulfillmentCount:2];
                FakeConnectionWatchdog *watchdog = [[FakeConnectionWatchdog alloc] initWithOperationQueue:operationQueue
                                                                                      connectionResponses:@[@YES, @YES, @YES]
                                                                                              expectation:watchdogExpectation];
                FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
                EMSRequestManager *manager = requestManager(operationQueue, requestModelRepository, watchdog, completionHandler.successBlock, completionHandler.errorBlock);

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

                [[watchdog.isConnectedCallCount should] equal:@2];
                [[completionHandler.successCount should] equal:@1];
                [[completionHandler.errorCount should] equal:@0];

                assertForItemsCountInDb(2, operationQueue, requestModelRepository);
            });
        });

SPEC_END
