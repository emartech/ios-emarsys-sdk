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
#import "EMSRequestModelSelectAllSpecification.h"
#import "EMSRESTClient.h"
#import "EMSDefaultWorker+Private.h"
#import "EMSRequestManager+Private.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestDB.db"]

SPEC_BEGIN(OfflineTests)

        __block EMSSQLiteHelper *helper;
        __block EMSRequestModelRepository *repository;

        id (^requestManager)(NSOperationQueue *operationQueue, id <EMSRequestModelRepositoryProtocol> repository, EMSConnectionWatchdog *watchdog, CoreSuccessBlock successBlock, CoreErrorBlock errorBlock) = ^id(NSOperationQueue *operationQueue, id <EMSRequestModelRepositoryProtocol> repository, EMSConnectionWatchdog *watchdog, CoreSuccessBlock successBlock, CoreErrorBlock errorBlock) {
            id <EMSWorkerProtocol> worker = [[EMSDefaultWorker alloc] initWithOperationQueue:operationQueue
                                                                           requestRepository:repository
                                                                          connectionWatchdog:watchdog
                                                                                  restClient:[EMSRESTClient clientWithSuccessBlock:successBlock
                                                                                                                        errorBlock:errorBlock
                                                                                                                     logRepository:nil]];
            return [[EMSRequestManager alloc] initWithOperationQueue:operationQueue
                                                              worker:worker
                                                   requestRepository:repository];
        };

        NSOperationQueue *(^testQueue)() = ^NSOperationQueue * {
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
                [helper executeCommand:SQL_PURGE];

                repository = [[EMSRequestModelRepository alloc] initWithDbHelper:helper];
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
                }                                        timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model2 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:@"https://www.yahoo.com"];
                    [builder setMethod:HTTPMethodGET];
                }                                        timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model3 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:@"https://www.wolframalpha.com"];
                    [builder setMethod:HTTPMethodGET];
                }                                        timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];

                __block NSString *checkableRequestId1;
                __block NSString *checkableRequestId2;
                __block NSString *checkableRequestId3;

                EMSRequestManager *core = [EMSRequestManager managerWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                        if (!checkableRequestId1) {
                            checkableRequestId1 = requestId;
                        } else if (!checkableRequestId2) {
                            checkableRequestId2 = requestId;
                        } else {
                            checkableRequestId3 = requestId;
                        }
                    }                                                     errorBlock:^(NSString *requestId, NSError *error) {
                        fail([NSString stringWithFormat:@"errorBlock: %@", error]);
                    }                                              requestRepository:repository
                                                                       logRepository:nil];
                [core submit:model1];
                [core submit:model2];
                [core submit:model3];

                [[expectFutureValue(checkableRequestId3) shouldEventuallyBeforeTimingOutAfter(30)] equal:model3.requestId];
                [[expectFutureValue(checkableRequestId2) shouldEventuallyBeforeTimingOutAfter(30)] equal:model2.requestId];
                [[expectFutureValue(checkableRequestId1) shouldEventuallyBeforeTimingOutAfter(30)] equal:model1.requestId];
            });

            it(@"should receive 0 response, repository count 3 when 3 request sent and there is no internet connection", ^{
                EMSRequestModel *model1 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:@"https://www.google.com"];
                    [builder setMethod:HTTPMethodGET];
                }                                        timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model2 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:@"https://www.yahoo.com"];
                    [builder setMethod:HTTPMethodGET];
                }                                        timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model3 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:@"https://www.wolframalpha.com"];
                    [builder setMethod:HTTPMethodGET];
                }                                        timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];

                NSOperationQueue *operationQueue = testQueue();
                FakeConnectionWatchdog *watchdog = [[FakeConnectionWatchdog alloc] initWithOperationQueue:operationQueue
                                                                                      connectionResponses:@[@NO, @NO, @NO]];
                FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
                EMSRequestManager *manager = requestManager(operationQueue, repository, watchdog, completionHandler.successBlock, completionHandler.errorBlock);

                [manager submit:model1];
                [manager submit:model2];
                [manager submit:model3];

                [[expectFutureValue(watchdog.isConnectedCallCount) shouldEventually] equal:@3];
                [[expectFutureValue(completionHandler.successCount) shouldEventually] equal:@0];
                [[expectFutureValue(completionHandler.errorCount) shouldEventually] equal:@0];
                NSArray<EMSRequestModel *> *items = [repository query:[EMSRequestModelSelectAllSpecification new]];
                [[expectFutureValue(theValue([items count])) shouldEventually] equal:theValue(3)];
            });

            it(@"should receive 2 response, repository count 1 when 3 request sent and connections:YES, YES, NO", ^{
                EMSRequestModel *model1 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:@"https://www.google.com"];
                    [builder setMethod:HTTPMethodGET];
                }                                        timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model2 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:@"https://www.yahoo.com"];
                    [builder setMethod:HTTPMethodGET];
                }                                        timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model3 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:@"https://www.wolframalpha.com"];
                    [builder setMethod:HTTPMethodGET];
                }                                        timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];
                NSOperationQueue *operationQueue = testQueue();
                FakeConnectionWatchdog *watchdog = [[FakeConnectionWatchdog alloc] initWithOperationQueue:operationQueue
                                                                                      connectionResponses:@[@YES, @YES, @NO]];
                FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
                EMSRequestManager *manager = requestManager(operationQueue, repository, watchdog, completionHandler.successBlock, completionHandler.errorBlock);

                [manager submit:model1];
                [manager submit:model2];
                [manager submit:model3];

                [[expectFutureValue(watchdog.isConnectedCallCount) shouldEventuallyBeforeTimingOutAfter(10)] equal:@3];
                [[expectFutureValue(completionHandler.successCount) shouldEventually] equal:@2];
                [[expectFutureValue(completionHandler.errorCount) shouldEventually] equal:@0];

                NSArray<EMSRequestModel *> *items = [repository query:[EMSRequestModelSelectAllSpecification new]];
                [[expectFutureValue(theValue([items count])) shouldEventually] equal:theValue(1)];
            });

            it(@"should stop the repository when response is 500", ^{
                EMSRequestModel *model1 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:@"https://www.google.com"];
                    [builder setMethod:HTTPMethodGET];
                }                                        timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model2 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:[NSString stringWithFormat:@"https://ems-denna.herokuapp.com%@", @"/error500"]];
                    [builder setMethod:HTTPMethodGET];
                }                                        timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model3 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:@"https://www.wolframalpha.com"];
                    [builder setMethod:HTTPMethodGET];
                }                                        timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];

                NSOperationQueue *operationQueue = testQueue();
                FakeConnectionWatchdog *watchdog = [[FakeConnectionWatchdog alloc] initWithOperationQueue:operationQueue
                                                                                      connectionResponses:@[@YES, @YES, @YES]];
                FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
                EMSRequestManager *manager = requestManager(operationQueue, repository, watchdog, completionHandler.successBlock, completionHandler.errorBlock);

                [manager submit:model1];
                [manager submit:model2];
                [manager submit:model3];

                [[expectFutureValue(watchdog.isConnectedCallCount) shouldEventuallyBeforeTimingOutAfter(10)] equal:@2];
                [[expectFutureValue(completionHandler.successCount) shouldEventually] equal:@1];
                [[expectFutureValue(completionHandler.errorCount) shouldEventually] equal:@0];
                NSArray<EMSRequestModel *> *items = [repository query:[EMSRequestModelSelectAllSpecification new]];
                [[expectFutureValue(theValue([items count])) shouldEventually] equal:theValue(2)];
            });

            it(@"should not stop the repository when response is 4xx", ^{
                EMSRequestModel *model1 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:@"https://www.google.com"];
                    [builder setMethod:HTTPMethodGET];
                }                                        timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model2 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:@"https://alma.korte.szilva/egyeb/palinkagyumolcsok"];
                    [builder setMethod:HTTPMethodGET];
                }                                        timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model3 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:@"https://www.wolframalpha.com"];
                    [builder setMethod:HTTPMethodGET];
                }                                        timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];

                NSOperationQueue *operationQueue = testQueue();
                operationQueue.maxConcurrentOperationCount = 1;
                FakeConnectionWatchdog *watchdog = [[FakeConnectionWatchdog alloc] initWithOperationQueue:operationQueue
                                                                                      connectionResponses:@[@YES, @YES, @YES]];
                FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
                EMSRequestManager *manager = requestManager(operationQueue, repository, watchdog, completionHandler.successBlock, completionHandler.errorBlock);

                [manager submit:model1];
                [manager submit:model2];
                [manager submit:model3];

                [[expectFutureValue(watchdog.isConnectedCallCount) shouldEventuallyBeforeTimingOutAfter(10)] equal:@3];
                [[expectFutureValue(completionHandler.successCount) shouldEventually] equal:@2];
                [[expectFutureValue(completionHandler.errorCount) shouldEventually] equal:@1];
                NSArray<EMSRequestModel *> *items = [repository query:[EMSRequestModelSelectAllSpecification new]];
                [[expectFutureValue(theValue([items count])) shouldEventually] equal:theValue(0)];
            });

            it(@"should stop the repository when response is 408", ^{
                EMSRequestModel *model1 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:@"https://www.google.com"];
                    [builder setMethod:HTTPMethodGET];
                }                                        timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model2 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:[NSString stringWithFormat:@"https://ems-denna.herokuapp.com%@", @"/408"]];
                    [builder setMethod:HTTPMethodGET];
                }                                        timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];
                EMSRequestModel *model3 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:@"https://www.wolframalpha.com"];
                    [builder setMethod:HTTPMethodGET];
                }                                        timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];

                NSOperationQueue *operationQueue = testQueue();
                FakeConnectionWatchdog *watchdog = [[FakeConnectionWatchdog alloc] initWithOperationQueue:operationQueue
                                                                                      connectionResponses:@[@YES, @YES, @YES]];
                FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
                EMSRequestManager *manager = requestManager(operationQueue, repository, watchdog, completionHandler.successBlock, completionHandler.errorBlock);

                [manager submit:model1];
                [manager submit:model2];
                [manager submit:model3];

                [[expectFutureValue(watchdog.isConnectedCallCount) shouldEventuallyBeforeTimingOutAfter(10)] equal:@2];
                [[expectFutureValue(completionHandler.successCount) shouldEventually] equal:@1];
                [[expectFutureValue(completionHandler.errorCount) shouldEventually] equal:@0];
                NSArray<EMSRequestModel *> *items = [repository query:[EMSRequestModelSelectAllSpecification new]];
                [[expectFutureValue(theValue([items count])) shouldEventually] equal:theValue(2)];
            });
        });

SPEC_END
