//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSRequestModelBuilder.h"
#import "EMSSQLiteHelper.h"
#import "EMSSqliteQueueSchemaHandler.h"
#import "EMSSchemaContract.h"
#import "EMSWorkerProtocol.h"
#import "EMSDefaultWorker.h"
#import "FakeCompletionHandler.h"
#import "FakeConnectionWatchdog.h"
#import "EMSRequestModelRepository.h"
#import "EMSShardRepository.h"
#import "EMSRequestModelSelectAllSpecification.h"
#import "EMSRESTClient.h"
#import "EMSDefaultWorker+Private.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSCompletionMiddleware.h"
#import "EMSRequestManager.h"
#import "EMSWaiter.h"

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestDB.db"]

SPEC_BEGIN(OfflineTests)

        __block EMSSQLiteHelper *helper;
        __block EMSRequestModelRepository *requestModelRepository;
        __block EMSShardRepository *shardRepository;

        id (^requestManager)(NSOperationQueue *operationQueue, id <EMSRequestModelRepositoryProtocol> repository, EMSConnectionWatchdog *watchdog, CoreSuccessBlock successBlock, CoreErrorBlock errorBlock) = ^id(NSOperationQueue *operationQueue, id <EMSRequestModelRepositoryProtocol> repository, EMSConnectionWatchdog *watchdog, CoreSuccessBlock successBlock, CoreErrorBlock errorBlock) {
            EMSCompletionMiddleware *middleware = [[EMSCompletionMiddleware alloc] initWithSuccessBlock:successBlock
                                                                                             errorBlock:errorBlock];
            id <EMSWorkerProtocol> worker = [[EMSDefaultWorker alloc] initWithOperationQueue:operationQueue
                                                                           requestRepository:repository
                                                                          connectionWatchdog:watchdog
                                                                                  restClient:[EMSRESTClient clientWithSuccessBlock:middleware.successBlock
                                                                                                                        errorBlock:middleware.errorBlock
                                                                                                                     logRepository:nil]];
            return [[EMSRequestManager alloc] initWithCoreQueue:operationQueue
                                           completionMiddleware:middleware
                                                         worker:worker
                                              requestRepository:repository
                                                shardRepository:[EMSShardRepository new]];
        };

        NSOperationQueue *(^testQueue)(void) = ^NSOperationQueue * {
            NSOperationQueue *queue = [NSOperationQueue new];
            queue.maxConcurrentOperationCount = 1;
            queue.qualityOfService = NSQualityOfServiceUtility;
            return queue;
        };


        describe(@"EMSRequestManager", ^{

            beforeEach(^{
                [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                                           error:nil];
                helper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                        schemaDelegate:[EMSSqliteQueueSchemaHandler new]];
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
                                                                                      connectionResponses:@[@YES, @YES, @YES]];
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
                XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation]
                                                                timeout:20];
                [[theValue(result) should] equal:theValue(XCTWaiterResultCompleted)];
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
                FakeConnectionWatchdog *watchdog = [[FakeConnectionWatchdog alloc] initWithOperationQueue:operationQueue
                                                                                      connectionResponses:@[@NO, @NO, @NO]];
                FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
                EMSRequestManager *manager = requestManager(operationQueue, requestModelRepository, watchdog, completionHandler.successBlock, completionHandler.errorBlock);

                [manager submitRequestModel:model1 withCompletionBlock:nil];
                [manager submitRequestModel:model2 withCompletionBlock:nil];
                [manager submitRequestModel:model3 withCompletionBlock:nil];

                [[expectFutureValue(watchdog.isConnectedCallCount) shouldEventually] equal:@3];
                [[expectFutureValue(completionHandler.successCount) shouldEventually] equal:@0];
                [[expectFutureValue(completionHandler.errorCount) shouldEventually] equal:@0];
                NSArray<EMSRequestModel *> *items = [requestModelRepository query:[EMSRequestModelSelectAllSpecification new]];
                [[expectFutureValue(theValue([items count])) shouldEventually] equal:theValue(3)];
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
                FakeConnectionWatchdog *watchdog = [[FakeConnectionWatchdog alloc] initWithOperationQueue:operationQueue
                                                                                      connectionResponses:@[@YES, @YES, @NO]];
                FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
                EMSRequestManager *manager = requestManager(operationQueue, requestModelRepository, watchdog, completionHandler.successBlock, completionHandler.errorBlock);

                [manager submitRequestModel:model1 withCompletionBlock:nil];
                [manager submitRequestModel:model2 withCompletionBlock:nil];
                [manager submitRequestModel:model3 withCompletionBlock:nil];

                [[expectFutureValue(watchdog.isConnectedCallCount) shouldEventuallyBeforeTimingOutAfter(10)] equal:@3];
                [[expectFutureValue(completionHandler.successCount) shouldEventually] equal:@2];
                [[expectFutureValue(completionHandler.errorCount) shouldEventually] equal:@0];

                NSArray<EMSRequestModel *> *items = [requestModelRepository query:[EMSRequestModelSelectAllSpecification new]];
                [[expectFutureValue(theValue([items count])) shouldEventually] equal:theValue(1)];
            });

            it(@"should stop the requestModelRepository when response is 500", ^{
                EMSRequestModel *model1 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"https://www.google.com"];
                        [builder setMethod:HTTPMethodGET];
                    }
                                                         timestampProvider:[EMSTimestampProvider new]
                                                              uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model2 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:[NSString stringWithFormat:@"https://ems-denna.herokuapp.com%@", @"/error500"]];
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
                                                                                      connectionResponses:@[@YES, @YES, @YES]];
                FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
                EMSRequestManager *manager = requestManager(operationQueue, requestModelRepository, watchdog, completionHandler.successBlock, completionHandler.errorBlock);

                [manager submitRequestModel:model1 withCompletionBlock:nil];
                [manager submitRequestModel:model2 withCompletionBlock:nil];
                [manager submitRequestModel:model3 withCompletionBlock:nil];

                [[expectFutureValue(watchdog.isConnectedCallCount) shouldEventuallyBeforeTimingOutAfter(10)] equal:@2];
                [[expectFutureValue(completionHandler.successCount) shouldEventually] equal:@1];
                [[expectFutureValue(completionHandler.errorCount) shouldEventually] equal:@0];
                NSArray<EMSRequestModel *> *items = [requestModelRepository query:[EMSRequestModelSelectAllSpecification new]];
                [[expectFutureValue(theValue([items count])) shouldEventually] equal:theValue(2)];
            });

            xit(@"should not stop the requestModelRepository when response is 4xx", ^{ //TODO: restclient callback order
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
                FakeConnectionWatchdog *watchdog = [[FakeConnectionWatchdog alloc] initWithOperationQueue:operationQueue
                                                                                      connectionResponses:@[@YES, @YES, @YES]];
                FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
                EMSRequestManager *manager = requestManager(operationQueue, requestModelRepository, watchdog, completionHandler.successBlock, completionHandler.errorBlock);

                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResults"];
                expectation.expectedFulfillmentCount = 3;

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

                [EMSWaiter waitForExpectations:@[expectation]
                                       timeout:300];

                [[watchdog.isConnectedCallCount should] equal:@3];
                [[completionHandler.successCount should] equal:@2];
                [[completionHandler.errorCount should] equal:@1];
                NSArray<EMSRequestModel *> *items = [requestModelRepository query:[EMSRequestModelSelectAllSpecification new]];
                [[theValue([items count]) should] equal:theValue(0)];
            });

            it(@"should stop the requestModelRepository when response is 408", ^{
                EMSRequestModel *model1 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"https://www.google.com"];
                        [builder setMethod:HTTPMethodGET];
                    }
                                                         timestampProvider:[EMSTimestampProvider new]
                                                              uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model2 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:[NSString stringWithFormat:@"https://ems-denna.herokuapp.com%@", @"/408"]];
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
                                                                                      connectionResponses:@[@YES, @YES, @YES]];
                FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
                EMSRequestManager *manager = requestManager(operationQueue, requestModelRepository, watchdog, completionHandler.successBlock, completionHandler.errorBlock);

                [manager submitRequestModel:model1 withCompletionBlock:nil];
                [manager submitRequestModel:model2 withCompletionBlock:nil];
                [manager submitRequestModel:model3 withCompletionBlock:nil];

                [[expectFutureValue(watchdog.isConnectedCallCount) shouldEventuallyBeforeTimingOutAfter(10)] equal:@2];
                [[expectFutureValue(completionHandler.successCount) shouldEventually] equal:@1];
                [[expectFutureValue(completionHandler.errorCount) shouldEventually] equal:@0];
                NSArray<EMSRequestModel *> *items = [requestModelRepository query:[EMSRequestModelSelectAllSpecification new]];
                [[expectFutureValue(theValue([items count])) shouldEventually] equal:theValue(2)];
            });
        });

SPEC_END
