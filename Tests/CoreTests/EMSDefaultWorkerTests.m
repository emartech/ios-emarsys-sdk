//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSDefaultWorker.h"
#import "EMSDefaultWorker+Private.h"
#import "TestUtils.h"
#import "FakeCompletionHandler.h"
#import "EMSSQLiteHelper.h"
#import "EMSSqliteSchemaHandler.h"
#import "EMSRequestModelRepository.h"
#import "EMSFilterByNothingSpecification.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSRESTClientCompletionProxyFactory.h"
#import "EMSCoreCompletionHandlerMiddleware.h"

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestDB.db"]

SPEC_BEGIN(EMSDefaultWorkerTests)

        void (^successBlock)(NSString *, EMSResponseModel *) =^(NSString *requestId, EMSResponseModel *response) {
        };
        void (^errorBlock)(NSString *, NSError *) =^(NSString *requestId, NSError *error) {
        };

        __block EMSSQLiteHelper *helper;
        __block EMSRequestModelRepository *repository;


        describe(@"init", ^{

            beforeEach(^{
                helper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                        schemaDelegate:[EMSSqliteSchemaHandler new]];
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
                                                             restClient:[EMSRESTClient new]
                                                             errorBlock:^(NSString *requestId, NSError *error) {
                                                             }
                                                           proxyFactory:[EMSRESTClientCompletionProxyFactory nullMock]];
            };

            it(@"should not return nil", ^{
                [[createWorker() shouldNot] beNil];
            });

            itShouldThrowException(@"should throw exception, when operationQueue is nil", ^{
                (void) [[EMSDefaultWorker alloc] initWithOperationQueue:nil
                                                      requestRepository:repository
                                                     connectionWatchdog:[EMSConnectionWatchdog mock]
                                                             restClient:[EMSRESTClient mock]
                                                             errorBlock:errorBlock
                                                           proxyFactory:[EMSRESTClientCompletionProxyFactory nullMock]];
            });

            itShouldThrowException(@"should throw exception, when requestModelRepository is nil", ^{
                (void) [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue mock]
                                                      requestRepository:nil
                                                     connectionWatchdog:[EMSConnectionWatchdog mock]
                                                             restClient:[EMSRESTClient mock]
                                                             errorBlock:errorBlock
                                                           proxyFactory:[EMSRESTClientCompletionProxyFactory nullMock]];
            });

            itShouldThrowException(@"should throw exception, when watchdog is nil", ^{
                (void) [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue mock]
                                                      requestRepository:repository
                                                     connectionWatchdog:nil
                                                             restClient:[EMSRESTClient new]
                                                             errorBlock:errorBlock
                                                           proxyFactory:[EMSRESTClientCompletionProxyFactory nullMock]];
            });

            itShouldThrowException(@"should throw exception, when restClient is nil", ^{
                (void) [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue mock]
                                                      requestRepository:repository
                                                     connectionWatchdog:[EMSConnectionWatchdog new]
                                                             restClient:nil
                                                             errorBlock:errorBlock
                                                           proxyFactory:[EMSRESTClientCompletionProxyFactory nullMock]];
            });

            itShouldThrowException(@"should throw exception, when restClient is nil", ^{
                (void) [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue mock]
                                                      requestRepository:repository
                                                     connectionWatchdog:[EMSConnectionWatchdog new]
                                                             restClient:[EMSRESTClient new]
                                                             errorBlock:nil
                                                           proxyFactory:[EMSRESTClientCompletionProxyFactory nullMock]];
            });

            itShouldThrowException(@"should throw exception, when restClient is nil", ^{
                (void) [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue mock]
                                                      requestRepository:repository
                                                     connectionWatchdog:[EMSConnectionWatchdog new]
                                                             restClient:[EMSRESTClient new]
                                                             errorBlock:errorBlock
                                                           proxyFactory:nil];
            });

            it(@"should initialize worker as unlocked", ^{
                EMSDefaultWorker *worker = createWorker();

                [[theValue([worker isLocked]) should] beNo];
            });

        });

        describe(@"run", ^{

            beforeEach(^{
                helper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                        schemaDelegate:[EMSSqliteSchemaHandler new]];
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
                EMSRESTClientCompletionProxyFactory *mockProxyFactory = [EMSRESTClientCompletionProxyFactory nullMock];
                EMSCoreCompletionHandlerMiddleware *middleware = [EMSCoreCompletionHandlerMiddleware mock];

                [mockProxyFactory stub:@selector(createWithWorker:successBlock:errorBlock:)
                             andReturn:middleware];

                EMSConnectionWatchdog *watchdog = [EMSConnectionWatchdog new];
                [watchdog stub:@selector(isConnected)
                     andReturn:theValue(YES)];

                [repository add:requestModel(@"https://url1.com", nil, NO)];

                EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue new]
                                                                          requestRepository:repository
                                                                         connectionWatchdog:watchdog
                                                                                 restClient:[EMSRESTClient new]
                                                                                 errorBlock:^(NSString *requestId, NSError *error) {
                                                                                 }
                                                                               proxyFactory:mockProxyFactory];
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
                                                                                 restClient:[EMSRESTClient new]
                                                                                 errorBlock:^(NSString *requestId, NSError *error) {
                                                                                 }
                                                                               proxyFactory:[EMSRESTClientCompletionProxyFactory nullMock]];
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
                                                                                 restClient:[EMSRESTClient new]
                                                                                 errorBlock:^(NSString *requestId, NSError *error) {
                                                                                 }
                                                                               proxyFactory:[EMSRESTClientCompletionProxyFactory nullMock]];
                [worker run];
            });

            it(@"should invoke isEmpty on requestModelRepository, when its running", ^{
                EMSRequestModelRepository *repositoryMock = [EMSRequestModelRepository mock];
                EMSConnectionWatchdog *watchdogMock = [EMSConnectionWatchdog mock];
                EMSRESTClient *restClient = [EMSRESTClient new];

                [watchdogMock stub:@selector(setConnectionChangeListener:)];

                EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue new]
                                                                          requestRepository:repositoryMock
                                                                         connectionWatchdog:watchdogMock
                                                                                 restClient:restClient
                                                                                 errorBlock:^(NSString *requestId, NSError *error) {
                                                                                 }
                                                                               proxyFactory:[EMSRESTClientCompletionProxyFactory nullMock]];
                [[watchdogMock should] receive:@selector(isConnected)
                                     andReturn:theValue(YES)];
                [[repositoryMock should] receive:@selector(isEmpty)
                                       andReturn:theValue(NO)];

                [[worker should] receive:@selector(nextNonExpiredModel)];
                [worker run];
            });

            it(@"should invoke executeWithRequestModel:coreCompletionProxy: on Restclient, when its running", ^{
                EMSRequestModelRepository *repositoryMock = [EMSRequestModelRepository mock];
                EMSConnectionWatchdog *watchdogMock = [EMSConnectionWatchdog mock];
                EMSRESTClient *clientMock = [EMSRESTClient mock];
                EMSRESTClientCompletionProxyFactory *mockProxyFactory = [EMSRESTClientCompletionProxyFactory nullMock];
                EMSCoreCompletionHandlerMiddleware *middleware = [EMSCoreCompletionHandlerMiddleware mock];

                [mockProxyFactory stub:@selector(createWithWorker:successBlock:errorBlock:)
                             andReturn:middleware];
                [watchdogMock stub:@selector(setConnectionChangeListener:)];

                EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue new]
                                                                          requestRepository:repositoryMock
                                                                         connectionWatchdog:watchdogMock
                                                                                 restClient:clientMock
                                                                                 errorBlock:^(NSString *requestId, NSError *error) {
                                                                                 }
                                                                               proxyFactory:mockProxyFactory];
                [[watchdogMock should] receive:@selector(isConnected)
                                     andReturn:theValue(YES)];
                [[repositoryMock should] receive:@selector(isEmpty)
                                       andReturn:theValue(NO)];

                EMSRequestModel *expectedModel = requestModel(@"https://url1.com", nil, NO);

                [[worker should] receive:@selector(nextNonExpiredModel)
                               andReturn:expectedModel];

                KWCaptureSpy *requestSpy = [clientMock captureArgument:@selector(executeWithRequestModel:coreCompletionProxy:)
                                                               atIndex:0];
                KWCaptureSpy *completionProxySpy = [clientMock captureArgument:@selector(executeWithRequestModel:coreCompletionProxy:)
                                                                       atIndex:1];
                [worker run];

                EMSRequestModel *capturedModel = requestSpy.argument;
                EMSRequestModel *capturedCompletionProxy = completionProxySpy.argument;

                [[expectedModel should] equal:capturedModel];
                [[middleware should] equal:capturedCompletionProxy];
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

                EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue new]
                                                                          requestRepository:repository
                                                                         connectionWatchdog:watchDog
                                                                                 restClient:clientMock
                                                                                 errorBlock:errorBlock
                                                                               proxyFactory:[EMSRESTClientCompletionProxyFactory nullMock]];

                [worker setConnectionWatchdog:watchDog];
                [worker setClient:clientMock];

                KWCaptureSpy *requestSpy = [clientMock captureArgument:@selector(executeWithRequestModel:coreCompletionProxy:)
                                                               atIndex:0];
                [worker run];

                EMSRequestModel *model = requestSpy.argument;
                [[model.requestId should] equal:expectedModel.requestId];

                NSArray<EMSRequestModel *> *items = [repository query:[EMSFilterByNothingSpecification new]];
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
                [[clientMock should] receive:@selector(executeWithRequestModel:coreCompletionProxy:)
                               withArguments:expectedModel, kw_any()];

                FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
                EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue new]
                                                                          requestRepository:repository
                                                                         connectionWatchdog:watchDog
                                                                                 restClient:clientMock
                                                                                 errorBlock:completionHandler.errorBlock
                                                                               proxyFactory:[EMSRESTClientCompletionProxyFactory nullMock]];
                [worker run];

                [[expectFutureValue(completionHandler.successCount) shouldEventually] equal:theValue(0)];
                [[expectFutureValue(completionHandler.errorCount) shouldEventually] equal:theValue(3)];
            });

            it(@"should unlock if only expired models were in the requestModelRepository", ^{
                [repository add:requestModel(@"https://url1.com", nil, YES)];
                [repository add:requestModel(@"https://url1.com", nil, YES)];
                [repository add:requestModel(@"https://url1.com", nil, YES)];

                EMSConnectionWatchdog *watchDog = [EMSConnectionWatchdog mock];
                [watchDog stub:@selector(isConnected) andReturn:theValue(YES)];
                [watchDog stub:@selector(setConnectionChangeListener:)];

                FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
                EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue new]
                                                                          requestRepository:repository
                                                                         connectionWatchdog:watchDog
                                                                                 restClient:[EMSRESTClient nullMock]
                                                                                 errorBlock:errorBlock
                                                                               proxyFactory:[EMSRESTClientCompletionProxyFactory nullMock]];

                [worker run];

                [[theValue([worker isLocked]) should] beNo];
            });
        });


        describe(@"LockableProtocol", ^{

            id (^createWorker)() = ^id() {
                return [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue new]
                                                      requestRepository:[EMSRequestModelRepository mock]
                                                     connectionWatchdog:[EMSConnectionWatchdog new]
                                                             restClient:[EMSRESTClient new]
                                                             errorBlock:^(NSString *requestId, NSError *error) {
                                                             }
                                                           proxyFactory:[EMSRESTClientCompletionProxyFactory nullMock]];
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
                                                                                 restClient:[EMSRESTClient new]
                                                                                 errorBlock:^(NSString *requestId, NSError *error) {
                                                                                 }
                                                                               proxyFactory:[EMSRESTClientCompletionProxyFactory nullMock]];
                [[worker should] equal:watchdog.connectionChangeListener];
            });

            it(@"should invoke run, when connectionStatus is connected", ^{
                EMSConnectionWatchdog *mockWatchdog = [EMSConnectionWatchdog mock];
                [mockWatchdog stub:@selector(setConnectionChangeListener:)];
                [[mockWatchdog should] receive:@selector(isConnected)];

                EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:[NSOperationQueue new]
                                                                          requestRepository:[EMSRequestModelRepository nullMock]
                                                                         connectionWatchdog:mockWatchdog
                                                                                 restClient:[EMSRESTClient new]
                                                                                 errorBlock:^(NSString *requestId, NSError *error) {
                                                                                 }
                                                                               proxyFactory:[EMSRESTClientCompletionProxyFactory nullMock]];
                [worker unlock];
                [worker connectionChangedToNetworkStatus:ReachableViaWiFi
                                        connectionStatus:YES];
            });

        });

SPEC_END
