//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MEIAMCleanupResponseHandlerV4.h"
#import "EMSAbstractResponseHandler+Private.h"
#import "EMSUUIDProvider.h"
#import "EMSTimestampProvider.h"
#import "EMSSqliteSchemaHandler.h"
#import "MEExperimental+Test.h"
#import "EMSInnerFeature.h"
#import "EMSFilterByNothingSpecification.h"
#import "EmarsysTestUtils.h"
#import "XCTestCase+Helper.h"

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestMIAMCleanup.db"]

@interface MEIAMCleanupResponseHandlerV4Tests : XCTestCase


@property(nonatomic, strong) MEButtonClickRepository *mockButtonClickRepository;
@property(nonatomic, strong) MEDisplayedIAMRepository *mockDisplayIamRepository;
@property(nonatomic, strong) EMSEndpoint *mockEndpoint;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) EMSSQLiteHelper *dbHelper;
@property(nonatomic, strong) MEIAMCleanupResponseHandlerV4 *responseHandler;
@property(nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation MEIAMCleanupResponseHandlerV4Tests

- (void)setUp {
    _mockButtonClickRepository = OCMClassMock([MEButtonClickRepository class]);
    _mockDisplayIamRepository = OCMClassMock([MEDisplayedIAMRepository class]);
    _mockEndpoint = OCMClassMock([EMSEndpoint class]);

    _timestampProvider = [EMSTimestampProvider new];
    _operationQueue = [self createTestOperationQueue];

    _responseHandler = [[MEIAMCleanupResponseHandlerV4 alloc] initWithButtonClickRepository:self.mockButtonClickRepository
                                                                       displayIamRepository:self.mockDisplayIamRepository
                                                                                   endpoint:self.mockEndpoint];
    _dbHelper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                               schemaDelegate:[EMSSqliteSchemaHandler new]
                                               operationQueue:self.operationQueue];
    [self.dbHelper open];
}

- (void)tearDown {
    [MEExperimental reset];
    [EmarsysTestUtils clearDb:self.dbHelper];
}

- (void)testInit_buttonClickRepository_mustNotBeNil {
    @try {
        [[MEIAMCleanupResponseHandlerV4 alloc] initWithButtonClickRepository:nil
                                                        displayIamRepository:self.mockDisplayIamRepository
                                                                    endpoint:self.mockEndpoint];
        XCTFail(@"Expected Exception when buttonClickRepository is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: buttonClickRepository"]);
    }
}

- (void)testInit_displayIamRepository_mustNotBeNil {
    @try {
        [[MEIAMCleanupResponseHandlerV4 alloc] initWithButtonClickRepository:self.mockButtonClickRepository
                                                        displayIamRepository:nil
                                                                    endpoint:self.mockEndpoint];
        XCTFail(@"Expected Exception when displayedIAMRepository is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: displayedIAMRepository"]);
    }
}

- (void)testInit_endpoint_mustNotBeNil {
    @try {
        [[MEIAMCleanupResponseHandlerV4 alloc] initWithButtonClickRepository:self.mockButtonClickRepository
                                                        displayIamRepository:self.mockDisplayIamRepository
                                                                    endpoint:nil];
        XCTFail(@"Expected Exception when endpoint is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: endpoint"]);
    }
}

- (void)testShouldHandle_should_ReturnYes_whenUrlIsMobileEngage {
    [MEExperimental enableFeature:EMSInnerFeature.eventServiceV4];
    OCMStub([self.mockEndpoint isMobileEngageUrl:[OCMArg any]]).andReturn(YES);

    NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"oldCampaigns": @[@1234, @56789]}
                                                   options:0
                                                     error:nil];
    EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                      headers:@{}
                                                                         body:body
                                                                   parsedBody:nil
                                                                 requestModel:[self createRequestModelWithPayload:@{@"viewedMessages": @[@{}]}]
                                                                    timestamp:[NSDate date]];

    XCTAssertTrue([self.responseHandler shouldHandleResponse:response]);
}

- (void)testShouldHandle_should_ReturnNo_whenUrlIsMobileEngage_andNotV4 {
    OCMStub([self.mockEndpoint isMobileEngageUrl:[OCMArg any]]).andReturn(YES);

    NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"oldCampaigns": @[@1234, @56789]}
                                                   options:0
                                                     error:nil];
    EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                      headers:@{}
                                                                         body:body
                                                                   parsedBody:nil
                                                                 requestModel:[self createRequestModelWithPayload:nil]
                                                                    timestamp:[NSDate date]];

    XCTAssertFalse([self.responseHandler shouldHandleResponse:response]);
}

- (void)testShouldHandle_should_ReturnNo_statusCodeIsNot2xx {
    [MEExperimental enableFeature:EMSInnerFeature.eventServiceV4];
    OCMStub([self.mockEndpoint isMobileEngageUrl:[OCMArg any]]).andReturn(YES);

    NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"oldCampaigns": @[@1234, @56789]}
                                                   options:0
                                                     error:nil];
    EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:300
                                                                      headers:@{}
                                                                         body:body
                                                                   parsedBody:nil
                                                                 requestModel:[self createRequestModelWithPayload:@{@"viewedMessages": @[@{}]}]
                                                                    timestamp:[NSDate date]];

    XCTAssertFalse([self.responseHandler shouldHandleResponse:response]);
}

- (void)testShouldHandle_should_ReturnNo_whenUrlIsMobileEngage_andViewedMessagesIsEmptyArray {
    [MEExperimental enableFeature:EMSInnerFeature.eventServiceV4];
    OCMStub([self.mockEndpoint isMobileEngageUrl:[OCMArg any]]).andReturn(YES);

    NSData *body = [NSJSONSerialization dataWithJSONObject:@{}
                                                   options:0
                                                     error:nil];
    EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                      headers:@{}
                                                                         body:body
                                                                   parsedBody:nil
                                                                 requestModel:[self createRequestModelWithPayload:@{@"viewedMessages": @[]}]
                                                                    timestamp:[NSDate date]];

    XCTAssertFalse([self.responseHandler shouldHandleResponse:response]);
}

- (void)testShouldHandle_should_ReturnYes_whenUrlIsMobileEngage_andClicksIsNotEmptyArray {
    [MEExperimental enableFeature:EMSInnerFeature.eventServiceV4];
    OCMStub([self.mockEndpoint isMobileEngageUrl:[OCMArg any]]).andReturn(YES);

    NSData *body = [NSJSONSerialization dataWithJSONObject:@{}
                                                   options:0
                                                     error:nil];
    EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                      headers:@{}
                                                                         body:body
                                                                   parsedBody:nil
                                                                 requestModel:[self createRequestModelWithPayload:@{@"clicks": @[@{}]}]
                                                                    timestamp:[NSDate date]];

    XCTAssertTrue([self.responseHandler shouldHandleResponse:response]);
}

- (void)testHandleResponse_removeClicks {
    MEButtonClickRepository *repository = [[MEButtonClickRepository alloc] initWithDbHelper:_dbHelper];

    [repository add:[[MEButtonClick alloc] initWithCampaignId:@"id1"
                                                     buttonId:@"b"
                                                    timestamp:[NSDate date]]];
    [repository add:[[MEButtonClick alloc] initWithCampaignId:@"id2"
                                                     buttonId:@"b"
                                                    timestamp:[NSDate date]]];
    [repository add:[[MEButtonClick alloc] initWithCampaignId:@"id3"
                                                     buttonId:@"b"
                                                    timestamp:[NSDate date]]];
    [repository add:[[MEButtonClick alloc] initWithCampaignId:@"id4"
                                                     buttonId:@"b"
                                                    timestamp:[NSDate date]]];


    NSData *body = [NSJSONSerialization dataWithJSONObject:@{}
                                                   options:0
                                                     error:nil];
    EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                      headers:@{}
                                                                         body:body
                                                                   parsedBody:nil
                                                                 requestModel:[self createRequestModelWithPayload:@{
                                                                         @"clicks": @[
                                                                                 @{
                                                                                         @"campaignId": @"id2"
                                                                                 },
                                                                                 @{
                                                                                         @"campaignId": @"id4"
                                                                                 }
                                                                         ]
                                                                 }]
                                                                    timestamp:[NSDate date]];

    _responseHandler = [[MEIAMCleanupResponseHandlerV4 alloc] initWithButtonClickRepository:repository
                                                                       displayIamRepository:self.mockDisplayIamRepository
                                                                                   endpoint:self.mockEndpoint];

    [self.responseHandler handleResponse:response];

    NSArray<MEButtonClick *> *clicks = [repository query:[EMSFilterByNothingSpecification new]];

    XCTAssertEqual([clicks count], 2);
    XCTAssertEqualObjects([clicks[0] campaignId], @"id1");
    XCTAssertEqualObjects([clicks[1] campaignId], @"id3");
}

- (void)testHandleResponse_removeDisplays {
    MEDisplayedIAMRepository *repository = [[MEDisplayedIAMRepository alloc] initWithDbHelper:_dbHelper];

    [repository add:[[MEDisplayedIAM alloc] initWithCampaignId:@"id2a"
                                                     timestamp:[NSDate date]]];
    [repository add:[[MEDisplayedIAM alloc] initWithCampaignId:@"id1a"
                                                     timestamp:[NSDate date]]];
    [repository add:[[MEDisplayedIAM alloc] initWithCampaignId:@"id3a"
                                                     timestamp:[NSDate date]]];
    [repository add:[[MEDisplayedIAM alloc] initWithCampaignId:@"id4a"
                                                     timestamp:[NSDate date]]];


    NSData *body = [NSJSONSerialization dataWithJSONObject:@{}
                                                   options:0
                                                     error:nil];
    EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                      headers:@{}
                                                                         body:body
                                                                   parsedBody:nil
                                                                 requestModel:[self createRequestModelWithPayload:@{
                                                                         @"viewedMessages": @[
                                                                                 @{
                                                                                         @"campaignId": @"id2a"
                                                                                 },
                                                                                 @{
                                                                                         @"campaignId": @"id4a"
                                                                                 }
                                                                         ]
                                                                 }]
                                                                    timestamp:[NSDate date]];

    _responseHandler = [[MEIAMCleanupResponseHandlerV4 alloc] initWithButtonClickRepository:self.mockButtonClickRepository
                                                                       displayIamRepository:repository
                                                                                   endpoint:self.mockEndpoint];

    [self.responseHandler handleResponse:response];

    NSArray<MEDisplayedIAM *> *displays = [repository query:[EMSFilterByNothingSpecification new]];

    XCTAssertEqual([displays count], 2);
    XCTAssertEqualObjects([displays[0] campaignId], @"id1a");
    XCTAssertEqualObjects([displays[1] campaignId], @"id3a");
}

- (void)testHandleResponse_when_callRepositoryOnce {
    OCMReject([self.mockButtonClickRepository remove:[OCMArg any]]);

    NSData *body = [NSJSONSerialization dataWithJSONObject:@{}
                                                   options:0
                                                     error:nil];
    EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                      headers:@{}
                                                                         body:body
                                                                   parsedBody:nil
                                                                 requestModel:[self createRequestModelWithPayload:@{
                                                                         @"viewedMessages": @[
                                                                                 @{
                                                                                         @"campaignId": @"id2a"
                                                                                 },
                                                                                 @{
                                                                                         @"campaignId": @"id4a"
                                                                                 }
                                                                         ]
                                                                 }]
                                                                    timestamp:[NSDate date]];

    [self.responseHandler handleResponse:response];

    OCMVerify([self.mockDisplayIamRepository remove:[OCMArg any]]);
}

- (EMSRequestModel *)createRequestModelWithPayload:(NSDictionary *)payload {
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"https://mobile-events.eservice.emarsys.net/v4/devices/meid/events"];
                [builder setPayload:payload];
            }
                          timestampProvider:self.timestampProvider
                               uuidProvider:[EMSUUIDProvider new]];
}

@end
