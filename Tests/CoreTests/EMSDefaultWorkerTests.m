//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSDefaultWorker.h"
#import "EMSDefaultWorker+Private.h"
#import "TestUtils.h"
#import "EMSRequestModelBuilder.h"
#import "FakeCompletionHandler.h"
#import "EMSSQLiteHelper.h"
#import "EMSSqliteQueueSchemaHandler.h"
#import "EMSRequestModelRepository.h"
#import "EMSRequestModelSelectAllSpecification.h"
#import "FakeLogRepository.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestDB.db"]

SPEC_BEGIN(EMSDefaultWorkerTests)

        void (^successBlock)(NSString *, EMSResponseModel *)=^(NSString *requestId, EMSResponseModel *response) {
        };
        void (^errorBlock)(NSString *, NSError *)=^(NSString *requestId, NSError *error) {
        };

        __block EMSSQLiteHelper *helper;
        __block EMSRequestModelRepository *repository;


        describe(@"init", ^{

            beforeEach(^{
                helper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                        schemaDelegate:[EMSSqliteQueueSchemaHandler new]];
                [helper open];
                repository = [[EMSRequestModelRepository alloc] initWithDbHelper:helper];
            });

            afterEach(^{
                [helper close];
                [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                                           error:nil];
            });


            id (^createWorker)() = ^id() {
                return [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue new]
                                                      requestRepository:repository
                                                     connectionWatchdog:[EMSConnectionWatchdog new]
                                                             restClient:[EMSRESTClient new]];
            };

            it(@"should not return nil", ^{
                [[createWorker() shouldNot] beNil];
            });

            itShouldThrowException(@"should throw exception, when repository is nil", ^{
                [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue mock]
                                               requestRepository:nil
                                                   logRepository:[FakeLogRepository mock]
                                                    successBlock:successBlock
                                                      errorBlock:errorBlock];
            });


            itShouldThrowException(@"should throw exception, when watchdog is nil", ^{
                [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue mock]
                                               requestRepository:repository
                                              connectionWatchdog:nil
                                                      restClient:[EMSRESTClient new]];
            });


            itShouldThrowException(@"should throw exception, when restClient is nil", ^{
                [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue mock]
                                               requestRepository:repository
                                              connectionWatchdog:[EMSConnectionWatchdog new]
                                                      restClient:nil];
            });

            it(@"should initialize worker as unlocked", ^{
                EMSDefaultWorker *worker = createWorker();

                [[theValue([worker isLocked]) should] beNo];
            });

            it(@"should create restClient with logRepository", ^{
                FakeLogRepository *fakeLogRepository = [FakeLogRepository new];
                EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue currentQueue]
                                                                          requestRepository:[EMSRequestModelRepository mock]
                                                                              logRepository:fakeLogRepository
                                                                               successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                                                               } errorBlock:^(NSString *requestId, NSError *error) {
                    }];
                [[fakeLogRepository should] equal:worker.client.logRepository];
            });

        });

        describe(@"run", ^{


            beforeEach(^{
                helper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                        schemaDelegate:[EMSSqliteQueueSchemaHandler new]];
                [helper open];
                repository = [[EMSRequestModelRepository alloc] initWithDbHelper:helper];
            });

            afterEach(^{
                [helper close];
                [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                                           error:nil];
            });

            id (^requestModel)(NSString *url, NSDictionary *payload, BOOL expired) = ^id(NSString *url, NSDictionary *payload, BOOL expired) {
                return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:url];
                    [builder setMethod:HTTPMethodPOST];
                    [builder setPayload:payload];
                    if (expired) {
                        [builder setExpiry:-1];
                    }
                }                     timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];
            };

            it(@"should lock", ^{
                EMSConnectionWatchdog *watchdog = [EMSConnectionWatchdog new];
                [watchdog stub:@selector(isConnected)
                     andReturn:theValue(YES)];

                [repository add:requestModel(@"https://url1.com", nil, NO)];

                EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue new]
                                                                          requestRepository:repository
                                                                         connectionWatchdog:watchdog
                                                                                 restClient:[EMSRESTClient new]];
                [worker unlock];
                [worker run];

                [[theValue([worker isLocked]) should] beYes];
                [[theValue([worker isLocked]) should] beYes];
            });

            it(@"should not invoke isConnected on connectionWatchdog, when locked", ^{
                EMSConnectionWatchdog *mockWatchdog = [EMSConnectionWatchdog mock];
                [mockWatchdog stub:@selector(setConnectionChangeListener:)];
                [[mockWatchdog shouldNot] receive:@selector(isConnected)];

                EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue new]
                                                                          requestRepository:repository
                                                                         connectionWatchdog:mockWatchdog
                                                                                 restClient:[EMSRESTClient new]];
                [worker lock];
                [worker run];
            });

            it(@"should invoke isConnected on connectionWatchdog, when not locked", ^{
                EMSConnectionWatchdog *mockWatchdog = [EMSConnectionWatchdog mock];
                [mockWatchdog stub:@selector(setConnectionChangeListener:)];
                [[mockWatchdog should] receive:@selector(isConnected)];

                EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue new]
                                                                          requestRepository:repository
                                                                         connectionWatchdog:mockWatchdog
                                                                                 restClient:[EMSRESTClient new]];
                [worker run];
            });

            it(@"should invoke peek on repository, when its running", ^{
                EMSRequestModelRepository *repositoryMock = [EMSRequestModelRepository mock];
                EMSConnectionWatchdog *watchdogMock = [EMSConnectionWatchdog mock];
                EMSRESTClient *restClient = [EMSRESTClient new];

                [watchdogMock stub:@selector(setConnectionChangeListener:)];
                [restClient stub:@selector(executeTaskWithOfflineCallbackStrategyWithRequestModel:onComplete:)];

                EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue new]
                                                                          requestRepository:repositoryMock
                                                                         connectionWatchdog:watchdogMock
                                                                                 restClient:restClient];
                [[watchdogMock should] receive:@selector(isConnected)
                                     andReturn:theValue(YES)];
                [[repositoryMock should] receive:@selector(isEmpty)
                                       andReturn:theValue(NO)];

                [[worker should] receive:@selector(nextNonExpiredModel)];
                [worker run];
            });

            it(@"should invoke executeTaskWithOfflineCallbackStrategyWithRequestModel:onComplete: on Restclient, when its running", ^{
                EMSRequestModelRepository *repositoryMock = [EMSRequestModelRepository mock];
                EMSConnectionWatchdog *watchdogMock = [EMSConnectionWatchdog mock];
                EMSRESTClient *clientMock = [EMSRESTClient mock];

                [watchdogMock stub:@selector(setConnectionChangeListener:)];

                EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue new]
                                                                          requestRepository:repositoryMock
                                                                         connectionWatchdog:watchdogMock
                                                                                 restClient:clientMock];
                [[watchdogMock should] receive:@selector(isConnected)
                                     andReturn:theValue(YES)];
                [[repositoryMock should] receive:@selector(isEmpty)
                                       andReturn:theValue(NO)];

                EMSRequestModel *expectedModel = requestModel(@"https://url1.com", nil, NO);

                [[worker should] receive:@selector(nextNonExpiredModel)
                               andReturn:expectedModel];
                KWCaptureSpy *requestSpy = [clientMock captureArgument:@selector(executeTaskWithOfflineCallbackStrategyWithRequestModel:onComplete:)
                                                               atIndex:0];
                [worker run];

                EMSRequestModel *capturedModel = requestSpy.argument;
                [[expectedModel should] equal:capturedModel];
            });

            it(@"should unlock after onComplete called with false", ^{
                EMSRequestModelRepository *repositoryMock = [EMSRequestModelRepository mock];
                EMSConnectionWatchdog *watchdogMock = [EMSConnectionWatchdog mock];
                EMSRESTClient *clientMock = [EMSRESTClient mock];

                [watchdogMock stub:@selector(setConnectionChangeListener:)];

                EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue new]
                                                                          requestRepository:repositoryMock
                                                                         connectionWatchdog:watchdogMock
                                                                                 restClient:clientMock];
                [[watchdogMock should] receive:@selector(isConnected)
                                     andReturn:theValue(YES)];
                [[repositoryMock should] receive:@selector(isEmpty)
                                       andReturn:theValue(NO)];

                EMSRequestModel *expectedModel = requestModel(@"https://url1.com", nil, NO);

                [[worker should] receive:@selector(nextNonExpiredModel)
                               andReturn:expectedModel];
                KWCaptureSpy *completionSpy = [clientMock captureArgument:@selector(executeTaskWithOfflineCallbackStrategyWithRequestModel:onComplete:)
                                                                  atIndex:1];
                [worker run];

                EMSRestClientCompletionBlock capturedBlock = completionSpy.argument;

                capturedBlock(false);

                [[theValue([worker isLocked]) should] beNo];
            });

            it(@"should unlock and rerun after onComplete called with true", ^{
                EMSRequestModelRepository *repositoryMock = [EMSRequestModelRepository mock];
                EMSConnectionWatchdog *watchdogMock = [EMSConnectionWatchdog mock];
                EMSRESTClient *clientMock = [EMSRESTClient mock];

                [watchdogMock stub:@selector(setConnectionChangeListener:)];

                NSOperationQueue *queue = [NSOperationQueue currentQueue];
                queue.maxConcurrentOperationCount = 1;
                EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:queue
                                                                          requestRepository:repositoryMock
                                                                         connectionWatchdog:watchdogMock
                                                                                 restClient:clientMock];
                [[watchdogMock should] receive:@selector(isConnected)
                                     andReturn:theValue(YES)];
                [[repositoryMock should] receive:@selector(isEmpty)
                                       andReturn:theValue(NO)];

                EMSRequestModel *expectedModel = requestModel(@"https://url1.com", nil, NO);

                [[worker should] receive:@selector(nextNonExpiredModel)
                               andReturn:expectedModel];
                KWCaptureSpy *completionSpy = [clientMock captureArgument:@selector(executeTaskWithOfflineCallbackStrategyWithRequestModel:onComplete:)
                                                                  atIndex:1];
                [worker run];

                EMSRestClientCompletionBlock capturedBlock = completionSpy.argument;

                [[repositoryMock should] receive:@selector(remove:)];

                capturedBlock(true);

                [[worker shouldEventually] receive:@selector(run)];

                [[theValue([worker isLocked]) should] beNo];
            });

            it(@"should get rid of expired requestModels", ^{
                EMSRequestModel *expectedModel = requestModel(@"https://url123.com", nil, NO);
                [repository add:requestModel(@"https://url1.com", nil, YES)];
                [repository add:requestModel(@"https://url1.com", nil, YES)];
                [repository add:requestModel(@"https://url1.com", nil, YES)];
                [repository add:expectedModel];

                EMSConnectionWatchdog *watchDog = [EMSConnectionWatchdog mock];
                [watchDog stub:@selector(isConnected) andReturn:theValue(YES)];
                [watchDog stub:@selector(setConnectionChangeListener:)];

                EMSRESTClient *clientMock = [EMSRESTClient mock];

                FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
                EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue currentQueue]
                                                                          requestRepository:repository
                                                                              logRepository:nil
                                                                               successBlock:completionHandler.successBlock
                                                                                 errorBlock:completionHandler.errorBlock];
                [worker setConnectionWatchdog:watchDog];
                [worker setClient:clientMock];

                KWCaptureSpy *requestSpy = [clientMock captureArgument:@selector(executeTaskWithOfflineCallbackStrategyWithRequestModel:onComplete:)
                                                               atIndex:0];
                [worker run];

                EMSRequestModel *model = requestSpy.argument;
                [[model.requestId should] equal:expectedModel.requestId];

                NSArray<EMSRequestModel *> *items = [repository query:[EMSRequestModelSelectAllSpecification new]];
                [[theValue([items count]) should] equal:theValue(1)];

                EMSRequestModel *poppedModel = [items firstObject];
                [[poppedModel.requestId should] equal:expectedModel.requestId];
            });

            it(@"should report as error when request is expired", ^{
                EMSRequestModel *expectedModel = requestModel(@"https://url123.com", nil, NO);
                [repository add:requestModel(@"https://url1.com", nil, YES)];
                [repository add:requestModel(@"https://url1.com", nil, YES)];
                [repository add:requestModel(@"https://url1.com", nil, YES)];
                [repository add:expectedModel];

                EMSConnectionWatchdog *watchDog = [EMSConnectionWatchdog mock];
                [watchDog stub:@selector(isConnected) andReturn:theValue(YES)];
                [watchDog stub:@selector(setConnectionChangeListener:)];

                EMSRESTClient *clientMock = [EMSRESTClient mock];
                [[clientMock should] receive:@selector(executeTaskWithOfflineCallbackStrategyWithRequestModel:onComplete:)
                               withArguments:expectedModel, kw_any()];

                FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
                EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue currentQueue]
                                                                          requestRepository:repository
                                                                              logRepository:nil
                                                                               successBlock:completionHandler.successBlock
                                                                                 errorBlock:completionHandler.errorBlock];
                [worker setClient:clientMock];

                [worker run];

                [[expectFutureValue(completionHandler.successCount) shouldEventually] equal:theValue(0)];
                [[expectFutureValue(completionHandler.errorCount) shouldEventually] equal:theValue(3)];
            });

            it(@"should unlock if only expired models were in the repository", ^{
                [repository add:requestModel(@"https://url1.com", nil, YES)];
                [repository add:requestModel(@"https://url1.com", nil, YES)];
                [repository add:requestModel(@"https://url1.com", nil, YES)];

                EMSConnectionWatchdog *watchDog = [EMSConnectionWatchdog mock];
                [watchDog stub:@selector(isConnected) andReturn:theValue(YES)];
                [watchDog stub:@selector(setConnectionChangeListener:)];

                FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
                EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue currentQueue]
                                                                          requestRepository:repository
                                                                              logRepository:nil
                                                                               successBlock:completionHandler.successBlock
                                                                                 errorBlock:completionHandler.errorBlock];

                [worker run];

                [[theValue([worker isLocked]) should] beNo];
            });
        });


        describe(@"LockableProtocol", ^{

            id (^createWorker)() = ^id() {
                return [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue new]
                                                      requestRepository:[EMSRequestModelRepository mock]
                                                     connectionWatchdog:[EMSConnectionWatchdog new]
                                                             restClient:[EMSRESTClient new]];
            };

            it(@"isLocked should return YES after calling lock", ^{
                EMSDefaultWorker *worker = createWorker();
                [worker unlock];
                [worker lock];
                [[theValue([worker isLocked]) should] beYes];
            });

            it(@"isLocked should return NO after calling unlock", ^{
                EMSDefaultWorker *worker = createWorker();
                [worker lock];
                [worker unlock];
                [[theValue([worker isLocked]) should] beNo];
            });

        });

        describe(@"ConnectionWatchdog", ^{

            it(@"DefaultWorker should implement the connectionChangeListener by default", ^{
                EMSConnectionWatchdog *watchdog = [EMSConnectionWatchdog new];
                EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue new]
                                                                          requestRepository:[EMSRequestModelRepository mock]
                                                                         connectionWatchdog:watchdog
                                                                                 restClient:[EMSRESTClient new]];
                [[worker should] equal:watchdog.connectionChangeListener];
            });

            it(@"should invoke run, when connectionStatus is connected", ^{
                EMSConnectionWatchdog *mockWatchdog = [EMSConnectionWatchdog mock];
                [mockWatchdog stub:@selector(setConnectionChangeListener:)];
                [[mockWatchdog should] receive:@selector(isConnected)];

                EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue new]
                                                                          requestRepository:[EMSRequestModelRepository mock]
                                                                         connectionWatchdog:mockWatchdog
                                                                                 restClient:[EMSRESTClient new]];
                [worker unlock];
                [worker connectionChangedToNetworkStatus:ReachableViaWiFi
                                        connectionStatus:YES];
            });

        });

SPEC_END
