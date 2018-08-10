//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSRequestManager.h"
#import "EMSRequestModelBuilder.h"
#import "EMSSQLiteHelper.h"
#import "EMSSqliteQueueSchemaHandler.h"
#import "EMSSchemaContract.h"
#import "EMSRequestModelRepository.h"
#import "EMSShardRepository.h"
#import "EMSShard.h"
#import "FakeLogRepository.h"
#import "EMSReachability.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSWaiter.h"


#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestDB.db"]

SPEC_BEGIN(EMSRequestManagerTests)
        __block EMSSQLiteHelper *helper;
        __block EMSRequestModelRepository *requestModelRepository;

        describe(@"EMSRequestManager", ^{
            __block EMSRequestManager *requestManager;
            __block EMSShardRepository *shardRepository;

            beforeEach(^{
                helper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                        schemaDelegate:[EMSSqliteQueueSchemaHandler new]];
                [helper open];
                [helper executeCommand:SQL_REQUEST_PURGE];
                requestModelRepository = [[EMSRequestModelRepository alloc] initWithDbHelper:helper];

                shardRepository = [EMSShardRepository mock];
                requestManager = [EMSRequestManager managerWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {

                        }                                        errorBlock:^(NSString *requestId, NSError *error) {

                        }                                 requestRepository:[[EMSRequestModelRepository alloc] initWithDbHelper:[[EMSSQLiteHelper alloc] initWithDefaultDatabase]]
                                                            shardRepository:shardRepository
                                                              logRepository:nil];
            });

            afterEach(^{
                [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                                           error:nil];
            });

            it(@"should do networking with the gained EMSRequestModel and return success", ^{
                NSString *url = @"https://www.google.com";

                EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:url];
                    [builder setMethod:HTTPMethodGET];
                }                                       timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];

                __block NSString *checkableRequestId;

                EMSRequestManager *core = [EMSRequestManager managerWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                            checkableRequestId = requestId;
                        }                                                 errorBlock:^(NSString *requestId, NSError *error) {
                            NSLog(@"ERROR: %@", error);
                            fail([NSString stringWithFormat:@"errorBlock: %@", error]);
                        }                                          requestRepository:requestModelRepository
                                                                     shardRepository:[EMSShardRepository new]
                                                                       logRepository:nil];

                [core submitRequestModel:model];

                [[checkableRequestId shouldEventually] equal:model.requestId];
            });

            it(@"should do networking with the gained EMSRequestModel and return failure", ^{
                NSString *url = @"https://alma.korte.szilva/egyeb/palinkagyumolcsok";

                EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:url];
                    [builder setMethod:HTTPMethodGET];
                }                                       timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];

                __block NSString *checkableRequestId;
                __block NSError *checkableError;

                EMSRequestManager *core = [EMSRequestManager managerWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                            fail([NSString stringWithFormat:@"SuccessBlock: %@", response]);
                        }                                                 errorBlock:^(NSString *requestId, NSError *error) {
                            checkableRequestId = requestId;
                            checkableError = error;
                        }                                          requestRepository:requestModelRepository
                                                                     shardRepository:[EMSShardRepository new]
                                                                       logRepository:nil];
                [core submitRequestModel:model];

                [[checkableRequestId shouldEventually] equal:model.requestId];
                [[checkableError shouldNotEventually] beNil];
            });

            it(@"should throw an exception, when requestModel is nil", ^{
                @try {
                    [requestManager submitRequestModel:nil];
                    fail(@"Expected exception when requestModel is nil");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw an exception, when shardModel is nil", ^{
                @try {
                    [requestManager submitShard:nil];
                    fail(@"Expected exception when shardModel is nil");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should save shard via shardRepository", ^{
                EMSShard *shard = [EMSShard mock];

                [[shardRepository shouldEventually] receive:@selector(add:) withArguments:shard];

                [requestManager submitShard:shard];
            });

        });

        describe(@"Core", ^{
            it(@"should not crash when EMSRequestManager created on Thread A and Reachability is Offline and there are lot of request in the queue and Reachability goes offline and still a lot of requests triggering", ^{

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForExpectation"];
                __block NSInteger successCount = 0;
                __block NSInteger errorCount = 0;


                EMSSQLiteHelper *dbHelper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                                           schemaDelegate:[EMSSqliteQueueSchemaHandler new]];
                EMSRequestModelRepository *repository = [[EMSRequestModelRepository alloc] initWithDbHelper:dbHelper];
                EMSRequestManager *requestManager = [EMSRequestManager managerWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                            successCount++;
                            if (successCount + errorCount >= 100) {
                                [exp fulfill];
                            }

                            if (successCount == 30) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    EMSReachability *reachabilityOfflineMock = [EMSReachability nullMock];
                                    [[reachabilityOfflineMock should] receive:@selector(currentReachabilityStatus) andReturn:theValue(NotReachable) withCountAtLeast:0];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:kEMSReachabilityChangedNotification object:reachabilityOfflineMock];
                                });
                            }

                            if (successCount == 70) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    EMSReachability *reachabilityOnlineMock = [EMSReachability nullMock];
                                    [[reachabilityOnlineMock should] receive:@selector(currentReachabilityStatus) andReturn:theValue(ReachableViaWiFi) withCountAtLeast:0];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:kEMSReachabilityChangedNotification object:reachabilityOnlineMock];
                                });
                            }
                        }
                                                                                    errorBlock:^(NSString *requestId, NSError *error) {
                                                                                        errorCount++;
                                                                                        if (successCount + errorCount >= 100) {
                                                                                            [exp fulfill];
                                                                                        }
                                                                                    }
                                                                             requestRepository:repository
                                                                               shardRepository:[EMSShardRepository new]
                                                                                 logRepository:[FakeLogRepository new]];


                for (int i = 0; i < 100; ++i) {
                    EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"https://ems-denna.herokuapp.com/echo"];
                        [builder setMethod:HTTPMethodGET];
                    }                                       timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];
                    [requestManager submitRequestModel:model];
                }

                EMSReachability *reachabilityOnlineMock = [EMSReachability nullMock];
                [[reachabilityOnlineMock should] receive:@selector(currentReachabilityStatus) andReturn:theValue(ReachableViaWiFi) withCountAtLeast:0];
                [[NSNotificationCenter defaultCenter] postNotificationName:kEMSReachabilityChangedNotification object:reachabilityOnlineMock];

                [EMSWaiter waitForExpectations:@[exp] timeout:60];
                [[theValue(successCount) should] equal:theValue(100)];
                [[theValue(errorCount) should] equal:theValue(0)];
            });
        });

SPEC_END
