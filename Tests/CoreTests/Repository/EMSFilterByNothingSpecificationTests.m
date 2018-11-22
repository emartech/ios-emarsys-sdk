//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSFilterByNothingSpecification.h"
#import "EMSRequestModelRepository.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSSQLiteHelper.h"
#import "EMSSqliteSchemaHandler.h"

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestDB.db"]

@interface EMSFilterByNothingSpecificationTests : XCTestCase

@property(nonatomic, strong) EMSRequestModelRepository *repository;

@end

@implementation EMSFilterByNothingSpecificationTests

- (void)setUp {
    [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                               error:nil];
    EMSSQLiteHelper *helper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                             schemaDelegate:[EMSSqliteSchemaHandler new]];
    [helper open];
    _repository = [[EMSRequestModelRepository alloc] initWithDbHelper:helper];
}

- (void)testQueryShouldReturnWithAllOfTheRequestModels {
    EMSRequestModel *requestModel1 = [self createRequestModelWithUrl:@"https://www.emarsys.com" payload:@{@"key1": @"value1"}];
    EMSRequestModel *requestModel2 = [self createRequestModelWithUrl:@"https://www.emarsys.com" payload:@{@"key2": @"value2"}];
    EMSRequestModel *requestModel3 = [self createRequestModelWithUrl:@"https://www.emarsys.com" payload:@{@"key3": @"value3"}];
    EMSRequestModel *requestModel4 = [self createRequestModelWithUrl:@"https://www.emarsys.com" payload:@{@"key4": @"value4"}];
    
    NSArray *expectedRequestModels = @[requestModel1, requestModel2, requestModel3, requestModel4];
    
    [self.repository add:requestModel1];
    [self.repository add:requestModel2];
    [self.repository add:requestModel3];
    [self.repository add:requestModel4];
    
    NSArray *result = [self.repository query:[EMSFilterByNothingSpecification new]];
    
    XCTAssertEqualObjects(result, expectedRequestModels);
}


- (void)testRemoveShouldDeleteEverything {
    EMSRequestModel *requestModel1 = [self createRequestModelWithUrl:@"https://www.emarsys.com" payload:@{@"key1": @"value1"}];
    EMSRequestModel *requestModel2 = [self createRequestModelWithUrl:@"https://www.emarsys.com" payload:@{@"key2": @"value2"}];
    EMSRequestModel *requestModel3 = [self createRequestModelWithUrl:@"https://www.emarsys.com" payload:@{@"key3": @"value3"}];
    EMSRequestModel *requestModel4 = [self createRequestModelWithUrl:@"https://www.emarsys.com" payload:@{@"key4": @"value4"}];
    
    NSArray *expectedRequestModels = @[];
    
    [self.repository add:requestModel1];
    [self.repository add:requestModel2];
    [self.repository add:requestModel3];
    [self.repository add:requestModel4];
    
    [self.repository remove:[EMSFilterByNothingSpecification new]];
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
