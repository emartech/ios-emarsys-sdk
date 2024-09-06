//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSFilterByTypeSpecification.h"
#import "EMSFilterByNothingSpecification.h"
#import "EMSRequestModelRepository.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSSQLiteHelper.h"
#import "EMSSqliteSchemaHandler.h"
#import "EMSSchemaContract.h"
#import "XCTestCase+Helper.h"
#import "EmarsysTestUtils.h"

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestDB.db"]

@interface EMSFilterByTypeSpecificationTests : XCTestCase

@property(nonatomic, strong) EMSRequestModelRepository *repository;
@property(nonatomic, strong) NSOperationQueue *queue;
@property(nonatomic, strong) NSOperationQueue *dbQueue;
@property(nonatomic, strong) EMSSQLiteHelper *dbHelper;

@end

@implementation EMSFilterByTypeSpecificationTests

- (void)setUp {
    _queue = [self createTestOperationQueue];
    _dbQueue = [self createTestOperationQueue];
    _dbHelper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                               schemaDelegate:[EMSSqliteSchemaHandler new]
                                               operationQueue:self.dbQueue];
    [self.dbHelper open];
    _repository = [[EMSRequestModelRepository alloc] initWithDbHelper:self.dbHelper
                                                       operationQueue:self.queue];
}

- (void)tearDown {
    [EmarsysTestUtils tearDownOperationQueue:self.queue];
    [EmarsysTestUtils clearDb:self.dbHelper];
}

- (void)testQueryShouldReturnWithTheExactRequstModels {
    EMSRequestModel *requestModel1 = [self createRequestModelWithUrl:@"https://www.emarsys.com" payload:@{@"key1": @"value1"}];
    EMSRequestModel *requestModel2 = [self createRequestModelWithUrl:@"https://www.google.com" payload:@{@"key2": @"value2"}];
    EMSRequestModel *requestModel3 = [self createRequestModelWithUrl:@"https://www.emarsys.com" payload:@{@"key3": @"value3"}];
    EMSRequestModel *requestModel4 = [self createRequestModelWithUrl:@"https://www.something.com" payload:@{@"key4": @"value4"}];
    
    NSArray *expectedRequestModels = @[requestModel1, requestModel3];
    
    [self.repository add:requestModel1];
    [self.repository add:requestModel2];
    [self.repository add:requestModel3];
    [self.repository add:requestModel4];
    
    NSArray *result = [self.repository query:[[EMSFilterByTypeSpecification alloc] initWitType:@"https://www.emarsys.com"
                                                                                        column:REQUEST_COLUMN_NAME_URL]];
    
    XCTAssertEqualObjects(result, expectedRequestModels);
}


- (void)testRemoveShouldDeleteEverything {
    EMSRequestModel *requestModel1 = [self createRequestModelWithUrl:@"https://www.emarsys.com" payload:@{@"key1": @"value1"}];
    EMSRequestModel *requestModel2 = [self createRequestModelWithUrl:@"https://www.google.com" payload:@{@"key2": @"value2"}];
    EMSRequestModel *requestModel3 = [self createRequestModelWithUrl:@"https://www.emarsys.com" payload:@{@"key3": @"value3"}];
    EMSRequestModel *requestModel4 = [self createRequestModelWithUrl:@"https://www.something.com" payload:@{@"key4": @"value4"}];
    
    NSArray *expectedRequestModels = @[requestModel2, requestModel4];
    
    [self.repository add:requestModel1];
    [self.repository add:requestModel2];
    [self.repository add:requestModel3];
    [self.repository add:requestModel4];
    
    [self.repository remove:[[EMSFilterByTypeSpecification alloc] initWitType:@"https://www.emarsys.com"
                                                                       column:REQUEST_COLUMN_NAME_URL]];
    NSArray *result = [self.repository query:[EMSFilterByNothingSpecification new]];
    
    XCTAssertEqualObjects(result, expectedRequestModels);
}

- (EMSRequestModel *)createRequestModelWithUrl:(NSString *)url
                                       payload:(NSDictionary *)payload {
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:url];
        [builder setMethod:HTTPMethodPOST];
        [builder setPayload:payload];
    }
                          timestampProvider:[EMSTimestampProvider new]
                               uuidProvider:[EMSUUIDProvider new]];
}

@end
