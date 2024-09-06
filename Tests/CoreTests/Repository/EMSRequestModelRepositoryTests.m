//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSRequestModelBuilder.h"
#import "EMSSQLiteHelper.h"
#import "EMSRequestModelRepositoryProtocol.h"
#import "EMSRequestModelRepository.h"
#import "EMSSqliteSchemaHandler.h"
#import "EMSQueryOldestRowSpecification.h"
#import "EMSFilterByNothingSpecification.h"
#import "EMSFilterByValuesSpecification.h"
#import "EMSCompositeRequestModel.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSSchemaContract.h"
#import "EMSRequestModel+RequestIds.h"
#import "FakeDbHelper.h"
#import "EmarsysTestUtils.h"
#import "XCTestCase+Helper.h"

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestDB.db"]

SPEC_BEGIN(EMSRequestModelRepositoryTests)

        __block EMSSQLiteHelper *helper;
        __block id <EMSRequestModelRepositoryProtocol> repository;
        __block NSOperationQueue *testQueue;
        __block NSOperationQueue *queue;

        beforeAll(^{
            testQueue = [self createTestOperationQueue];
            queue = [self createTestOperationQueue];
            helper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                    schemaDelegate:[EMSSqliteSchemaHandler new]
                                                    operationQueue:queue];
            [helper open];
            repository = [[EMSRequestModelRepository alloc] initWithDbHelper:helper
                                                              operationQueue:testQueue];
        });

        afterEach(^{
            [testQueue cancelAllOperations];
            [testQueue waitUntilAllOperationsAreFinished];
            [EmarsysTestUtils clearDb:helper];
        });


        id (^requestModel)(NSString *url, NSDictionary *payload) = ^id(NSString *url, NSDictionary *payload) {
            return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:url];
                        [builder setMethod:HTTPMethodPOST];
                        [builder setPayload:payload];
                    }
                                  timestampProvider:[EMSTimestampProvider new]
                                       uuidProvider:[EMSUUIDProvider new]];
        };

        id (^requestModelWithTTL)(NSString *url, NSTimeInterval ttl) = ^id(NSString *url, NSTimeInterval ttl) {
            return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:url];
                        [builder setMethod:HTTPMethodGET];
                        [builder setExpiry:ttl];
                    }
                                  timestampProvider:[EMSTimestampProvider new]
                                       uuidProvider:[EMSUUIDProvider new]];
        };

        describe(@"init", ^{

            it(@"sqliteHelper must not be nil", ^{
                @try {
                    [[EMSRequestModelRepository alloc] initWithDbHelper:nil
                                                         operationQueue:[NSOperationQueue mock]];
                    fail(@"Expected exception when sqliteHelper is nil");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: sqliteHelper"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"operationQueue must not be nil", ^{
                @try {
                    [[EMSRequestModelRepository alloc] initWithDbHelper:[EMSRequestModelRepository mock]
                                                         operationQueue:nil];
                    fail(@"Expected exception when operationQueue is nil");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: operationQueue"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });
        });

        describe(@"query", ^{
            it(@"should return empty array when the table is isEmpty", ^{
                NSArray<EMSRequestModel *> *result = [repository query:[EMSQueryOldestRowSpecification new]];
                [[result should] beEmpty];
            });
        });

        describe(@"add", ^{
            it(@"should not accept nil", ^{
                @try {
                    [repository add:nil];
                    fail(@"Expected Exception when model is nil!");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should handle models when payload contain not encodable data", ^{
                NSDate *date = [NSDate date];

                EMSRequestModel *expectedModel = [[EMSRequestModel alloc] initWithRequestId:@"testRequestId"
                                                                                  timestamp:date
                                                                                     expiry:0
                                                                                        url:[NSURL URLWithString:@"https://www.emarsys.com"]
                                                                                     method:@"POST"
                                                                                    payload:nil
                                                                                    headers:@{}
                                                                                     extras:@{}];

                void (^blockName)() = ^void() {
                };

                EMSRequestModel *modelToInsert = [[EMSRequestModel alloc] initWithRequestId:@"testRequestId"
                                                                                  timestamp:date
                                                                                     expiry:0
                                                                                        url:[NSURL URLWithString:@"https://www.emarsys.com"]
                                                                                     method:@"POST"
                                                                                    payload:@{@"block": blockName}
                                                                                    headers:@{}
                                                                                     extras:@{}];

                [repository add:modelToInsert];

                NSArray<EMSRequestModel *> *result = [repository query:[EMSQueryOldestRowSpecification new]];
                [[result.firstObject should] equal:expectedModel];
            });

            it(@"should insert the requestModel to the requestModelRepository", ^{
                EMSRequestModel *expectedModel = requestModel(@"https://url1.com", @{@"key1": @"value1"});
                [repository add:expectedModel];
                NSArray<EMSRequestModel *> *result = [repository query:[EMSQueryOldestRowSpecification new]];
                [[result.firstObject should] equal:expectedModel];
            });
        });

        describe(@"delete", ^{
            it(@"should delete the model from the table", ^{
                EMSRequestModel *expectedModel = requestModel(@"https://url1.com", @{@"key1": @"value1"});
                [repository add:expectedModel];
                [repository remove:[[EMSFilterByValuesSpecification alloc] initWithValues:@[expectedModel.requestId]
                                                                                   column:REQUEST_COLUMN_NAME_REQUEST_ID]];
                NSArray<EMSRequestModel *> *result = [repository query:[EMSQueryOldestRowSpecification new]];
                [[result should] beEmpty];
            });
        });


        describe(@"EMSRequestModelFirstSelectSpecification", ^{

            it(@"should keep the order of the elements", ^{
                EMSRequestModel *firstModel = requestModelWithTTL(@"https://url2.com", 58);
                EMSRequestModel *secondModel = requestModelWithTTL(@"https://url2.com", 57);

                [repository add:firstModel];
                [repository add:secondModel];

                EMSRequestModel *result1 = [repository query:[EMSQueryOldestRowSpecification new]].firstObject;
                [repository remove:[[EMSFilterByValuesSpecification alloc] initWithValues:@[firstModel.requestId]
                                                                                   column:REQUEST_COLUMN_NAME_REQUEST_ID]];
                EMSRequestModel *result2 = [repository query:[EMSQueryOldestRowSpecification new]].firstObject;
                [repository remove:[[EMSFilterByValuesSpecification alloc] initWithValues:@[secondModel.requestId]
                                                                                   column:REQUEST_COLUMN_NAME_REQUEST_ID]];

                [[result1 should] equal:firstModel];
                [[result2 should] equal:secondModel];
            });
        });

        describe(@"EMSFilterByNothingSpecification", ^{

            it(@"should return all of the models", ^{
                EMSRequestModel *firstModel = requestModelWithTTL(@"https://url2.com", 58);
                EMSRequestModel *secondModel = requestModelWithTTL(@"https://url2.com", 57);
                EMSRequestModel *thirdModel = requestModelWithTTL(@"https://url3.com", 59);

                [repository add:firstModel];
                [repository add:secondModel];
                [repository add:thirdModel];

                NSArray *results = [repository query:[EMSFilterByNothingSpecification new]];

                [[theValue([results count]) should] equal:theValue(3)];
            });
        });


        describe(@"EMSRequestModelDeleteByIdsSpecification", ^{

            it(@"should delete the correct requestmodel", ^{
                EMSRequestModel *firstModel = requestModelWithTTL(@"https://url2.com", 58);
                EMSRequestModel *secondModel = requestModelWithTTL(@"https://url2.com", 57);
                EMSRequestModel *thirdModel = requestModelWithTTL(@"https://url3.com", 59);

                [repository add:firstModel];
                [repository add:secondModel];
                [repository add:thirdModel];

                [repository remove:[[EMSFilterByValuesSpecification alloc] initWithValues:@[secondModel.requestId]
                                                                                   column:REQUEST_COLUMN_NAME_REQUEST_ID]];

                NSArray *results = [repository query:[EMSFilterByNothingSpecification new]];
                [[results[0] should] equal:firstModel];
                [[results[1] should] equal:thirdModel];
            });

            it(@"should delete the original requestmodels for the composit request model", ^{
                EMSRequestModel *firstModel = requestModelWithTTL(@"https://url2.com", 58);
                EMSRequestModel *secondModel = requestModelWithTTL(@"https://url2.com", 57);
                EMSRequestModel *thirdModel = requestModelWithTTL(@"https://url3.com", 59);
                EMSRequestModel *fourthModel = requestModelWithTTL(@"https://url4.com", 88);

                [repository add:firstModel];
                [repository add:secondModel];
                [repository add:thirdModel];
                [repository add:fourthModel];

                EMSCompositeRequestModel *compositeRequestModel = [EMSCompositeRequestModel new];
                compositeRequestModel.originalRequests = @[firstModel, thirdModel];

                [repository remove:[[EMSFilterByValuesSpecification alloc] initWithValues:compositeRequestModel.requestIds
                                                                                   column:REQUEST_COLUMN_NAME_REQUEST_ID]];

                NSArray *results = [repository query:[EMSFilterByNothingSpecification new]];
                [[theValue([results count]) should] equal:theValue(2)];
                [[results[0] should] equal:secondModel];
                [[results[1] should] equal:fourthModel];
            });

        });


SPEC_END
