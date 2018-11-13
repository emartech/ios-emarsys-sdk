//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
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
#import "MELogRepository.h"

#define DennaUrl(ending) [NSString stringWithFormat:@"https://ems-denna.herokuapp.com%@", ending];
#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestDB.db"]
#define DB_PATH [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"EMSSQLiteQueueDB.db"]

SPEC_BEGIN(DennaTest)

        NSString *error500 = DennaUrl(@"/error500");
        NSString *echo = DennaUrl(@"/echo");
        NSDictionary *inputHeaders = @{@"Header1": @"value1", @"Header2": @"value2"};
        NSDictionary *payload = @{@"key1": @"val1", @"key2": @"val2", @"key3": @"val3"};

        void (^shouldEventuallySucceed)(EMSRequestModel *model, NSString *method, NSDictionary<NSString *, NSString *> *headers, NSDictionary<NSString *, id> *body) = ^(EMSRequestModel *model, NSString *method, NSDictionary<NSString *, NSString *> *headers, NSDictionary<NSString *, id> *body) {
            __block NSString *checkableRequestId;
            __block NSString *resultMethod;
            __block BOOL expectedSubsetOfResultHeaders;
            __block NSDictionary<NSString *, id> *resultPayload;

            NSOperationQueue *queue = [NSOperationQueue new];
            queue.maxConcurrentOperationCount = 1;
            queue.qualityOfService = NSQualityOfServiceUtility;

            EMSCompletionMiddleware *middleware = [[EMSCompletionMiddleware alloc] initWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                    checkableRequestId = requestId;
                    NSDictionary<NSString *, id> *returnedPayload = [NSJSONSerialization JSONObjectWithData:response.body
                                                                                                    options:NSJSONReadingAllowFragments
                                                                                                      error:nil];
                    NSLog(@"RequestId: %@, responsePayload: %@", requestId, returnedPayload);
                    resultMethod = returnedPayload[@"method"];
                    expectedSubsetOfResultHeaders = [returnedPayload[@"headers"] subsetOfDictionary:headers];
                    resultPayload = returnedPayload[@"body"];

                }
                                                                                             errorBlock:^(NSString *requestId, NSError *error) {
                                                                                                 NSLog(@"ERROR!");
                                                                                                 fail(@"errorblock invoked");
                                                                                             }];
            EMSRequestModelRepository *requestRepository = [[EMSRequestModelRepository alloc] initWithDbHelper:[[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                                                                                                              schemaDelegate:[EMSSqliteSchemaHandler new]]];
            EMSShardRepository *shardRepository = [EMSShardRepository new];
            EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:queue
                                                                      requestRepository:requestRepository
                                                                     connectionWatchdog:[[EMSConnectionWatchdog alloc] initWithOperationQueue:queue]
                                                                             restClient:[EMSRESTClient clientWithSuccessBlock:middleware.successBlock
                                                                                                                   errorBlock:middleware.errorBlock
                                                                                                                logRepository:[MELogRepository new]]
                                                                             errorBlock:middleware.errorBlock];
            EMSRequestManager *core = [[EMSRequestManager alloc] initWithCoreQueue:queue
                                                              completionMiddleware:middleware
                                                                        restClient:NULL
                                                                            worker:worker
                                                                 requestRepository:requestRepository
                                                                   shardRepository:shardRepository];
            [core submitRequestModel:model
                 withCompletionBlock:nil];

            [[expectFutureValue(resultMethod) shouldEventuallyBeforeTimingOutAfter(10.0)] equal:method];
            [[theValue(expectedSubsetOfResultHeaders) shouldEventuallyBeforeTimingOutAfter(10.0)] equal:theValue(YES)];
            if (body) {
                [[expectFutureValue(resultPayload) shouldEventuallyBeforeTimingOutAfter(10.0)] equal:body];
            }
            [[expectFutureValue(model.requestId) shouldEventuallyBeforeTimingOutAfter(10.0)] equal:checkableRequestId];
        };


        describe(@"EMSRequestManager", ^{

            beforeEach(^{
                [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:DB_PATH error:nil];
            });

            it(@"should invoke errorBlock when calling error500 on Denna", ^{
                EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:error500];
                        [builder setMethod:HTTPMethodGET];
                    }
                                                        timestampProvider:[EMSTimestampProvider new]
                                                             uuidProvider:[EMSUUIDProvider new]];
                NSOperationQueue *queue = [NSOperationQueue new];
                queue.maxConcurrentOperationCount = 1;
                queue.qualityOfService = NSQualityOfServiceUtility;

                EMSCompletionMiddleware *middleware = [[EMSCompletionMiddleware alloc] initWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                        NSLog(@"ERROR!");
                        fail(@"successBlock invoked :'(");
                    }
                                                                                                 errorBlock:^(NSString *requestId, NSError *error) {
                                                                                                     NSLog(@"ERROR!");
                                                                                                     fail(@"errorblock invoked");
                                                                                                 }];
                EMSRequestModelRepository *requestRepository = [[EMSRequestModelRepository alloc] initWithDbHelper:[[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                                                                                                                  schemaDelegate:[EMSSqliteSchemaHandler new]]];
                EMSShardRepository *shardRepository = [EMSShardRepository new];
                EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:queue
                                                                          requestRepository:requestRepository
                                                                         connectionWatchdog:[[EMSConnectionWatchdog alloc] initWithOperationQueue:queue]
                                                                                 restClient:[EMSRESTClient clientWithSuccessBlock:middleware.successBlock
                                                                                                                       errorBlock:middleware.errorBlock
                                                                                                                    logRepository:[MELogRepository new]]
                                                                                 errorBlock:middleware.errorBlock];
                EMSRequestManager *core = [[EMSRequestManager alloc] initWithCoreQueue:queue
                                                                  completionMiddleware:middleware
                                                                            restClient:NULL
                                                                                worker:worker
                                                                     requestRepository:requestRepository
                                                                       shardRepository:shardRepository];
                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [core submitRequestModel:model
                     withCompletionBlock:^(NSError *error) {
                         [expectation fulfill];
                     }];
                XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation]
                                                                timeout:10];
                [[theValue(result) should] equal:theValue(XCTWaiterResultTimedOut)];
            });

            it(@"should respond with the GET request's headers/body", ^{
                EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:echo];
                        [builder setMethod:HTTPMethodGET];
                        [builder setHeaders:inputHeaders];
                    }
                                                        timestampProvider:[EMSTimestampProvider new]
                                                             uuidProvider:[EMSUUIDProvider new]];
                shouldEventuallySucceed(model, @"GET", inputHeaders, nil);
            });

            it(@"should respond with the POST request's headers/body", ^{
                EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:echo];
                        [builder setMethod:HTTPMethodPOST];
                        [builder setHeaders:inputHeaders];
                        [builder setPayload:payload];
                    }
                                                        timestampProvider:[EMSTimestampProvider new]
                                                             uuidProvider:[EMSUUIDProvider new]];
                shouldEventuallySucceed(model, @"POST", inputHeaders, payload);
            });

            it(@"should respond with the DELETE request's headers/body", ^{
                EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:echo];
                        [builder setMethod:HTTPMethodDELETE];
                        [builder setHeaders:inputHeaders];
                    }
                                                        timestampProvider:[EMSTimestampProvider new]
                                                             uuidProvider:[EMSUUIDProvider new]];
                shouldEventuallySucceed(model, @"DELETE", inputHeaders, nil);
            });


        });

SPEC_END
