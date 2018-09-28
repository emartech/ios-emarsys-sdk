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

            EMSRequestManager *core = [EMSRequestManager managerWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                        checkableRequestId = requestId;
                        NSDictionary<NSString *, id> *returnedPayload = [NSJSONSerialization JSONObjectWithData:response.body
                                                                                                        options:NSJSONReadingAllowFragments
                                                                                                          error:nil];
                        NSLog(@"RequestId: %@, responsePayload: %@", requestId, returnedPayload);
                        resultMethod = returnedPayload[@"method"];
                        expectedSubsetOfResultHeaders = [returnedPayload[@"headers"] subsetOfDictionary:headers];
                        resultPayload = returnedPayload[@"body"];
                    }                                                 errorBlock:^(NSString *requestId, NSError *error) {
                        NSLog(@"ERROR!");
                        fail(@"errorblock invoked");
                    }                                          requestRepository:[[EMSRequestModelRepository alloc] initWithDbHelper:[[EMSSQLiteHelper alloc] initWithDefaultDatabase]]
                                                                 shardRepository:[EMSShardRepository new]
                                                                   logRepository:nil];
            [core submitRequestModel:model withCompletionBlock:nil];

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
                }                                       timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];

                __block NSString *checkableRequestId;

                EMSRequestManager *core = [EMSRequestManager managerWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                            NSLog(@"ERROR!");
                            fail(@"successBlock invoked :'(");
                        }                                                 errorBlock:^(NSString *requestId, NSError *error) {
                            checkableRequestId = requestId;
                            NSLog(@"ERROR!");
                            fail(@"errorBlock invoked :'(");
                        }                                          requestRepository:[[EMSRequestModelRepository alloc] initWithDbHelper:[[EMSSQLiteHelper alloc] initWithDefaultDatabase]]
                                                                     shardRepository:[EMSShardRepository new]
                                                                       logRepository:nil];

                [core submitRequestModel:model withCompletionBlock:nil];
                [[expectFutureValue(checkableRequestId) shouldEventually] beNil];
            });

            it(@"should respond with the GET request's headers/body", ^{
                EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:echo];
                    [builder setMethod:HTTPMethodGET];
                    [builder setHeaders:inputHeaders];
                }                                       timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];
                shouldEventuallySucceed(model, @"GET", inputHeaders, nil);
            });

            it(@"should respond with the POST request's headers/body", ^{
                EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:echo];
                    [builder setMethod:HTTPMethodPOST];
                    [builder setHeaders:inputHeaders];
                    [builder setPayload:payload];
                }                                       timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];
                shouldEventuallySucceed(model, @"POST", inputHeaders, payload);
            });

            it(@"should respond with the DELETE request's headers/body", ^{
                EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:echo];
                    [builder setMethod:HTTPMethodDELETE];
                    [builder setHeaders:inputHeaders];
                }                                       timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];
                shouldEventuallySucceed(model, @"DELETE", inputHeaders, nil);
            });


        });

SPEC_END
