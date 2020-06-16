//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSTimestampProvider.h"
#import "EMSRequestModelBuilder.h"
#import "MEIAMCleanupResponseHandler.h"
#import "EMSAbstractResponseHandler+Private.h"
#import "EMSFilterByNothingSpecification.h"
#import "EMSSqliteSchemaHandler.h"
#import "EMSUUIDProvider.h"

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestMIAMCleanup.db"]

@interface MEIAMCleanupResponseHandlerTests : XCTestCase

@property(nonatomic, strong) MEButtonClickRepository *mockButtonClickRepository;
@property(nonatomic, strong) MEDisplayedIAMRepository *mockDisplayIamRepository;
@property(nonatomic, strong) EMSEndpoint *mockEndpoint;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) EMSRequestModel *requestModel;
@property(nonatomic, strong) EMSSQLiteHelper *dbHelper;
@property(nonatomic, strong) MEIAMCleanupResponseHandler *responseHandler;

@end

@implementation MEIAMCleanupResponseHandlerTests

- (void)setUp {
    _mockButtonClickRepository = OCMClassMock([MEButtonClickRepository class]);
    _mockDisplayIamRepository = OCMClassMock([MEDisplayedIAMRepository class]);
    _mockEndpoint = OCMClassMock([EMSEndpoint class]);

    _timestampProvider = [EMSTimestampProvider new];
    _requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"https://mobile-events.eservice.emarsys.net/v3/devices/meid/events"];
            }
                                   timestampProvider:self.timestampProvider
                                        uuidProvider:[EMSUUIDProvider new]];

    _responseHandler = [[MEIAMCleanupResponseHandler alloc] initWithButtonClickRepository:self.mockButtonClickRepository
                                                                     displayIamRepository:self.mockDisplayIamRepository
                                                                                 endpoint:self.mockEndpoint];

    [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                               error:nil];
    _dbHelper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                               schemaDelegate:[EMSSqliteSchemaHandler new]];
    [self.dbHelper open];
}

- (void)tearDown {
    [self.dbHelper close];
}

- (void)testInit_buttonClickRepository_mustNotBeNil {
    @try {
        [[MEIAMCleanupResponseHandler alloc] initWithButtonClickRepository:nil
                                                      displayIamRepository:self.mockDisplayIamRepository
                                                                  endpoint:self.mockEndpoint];
        XCTFail(@"Expected Exception when buttonClickRepository is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: buttonClickRepository"]);
    }
}

- (void)testInit_displayIamRepository_mustNotBeNil {
    @try {
        [[MEIAMCleanupResponseHandler alloc] initWithButtonClickRepository:self.mockButtonClickRepository
                                                      displayIamRepository:nil
                                                                  endpoint:self.mockEndpoint];
        XCTFail(@"Expected Exception when displayedIAMRepository is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: displayedIAMRepository"]);
    }
}

- (void)testInit_endpoint_mustNotBeNil {
    @try {
        [[MEIAMCleanupResponseHandler alloc] initWithButtonClickRepository:self.mockButtonClickRepository
                                                      displayIamRepository:self.mockDisplayIamRepository
                                                                  endpoint:nil];
        XCTFail(@"Expected Exception when endpoint is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: endpoint"]);
    }
}

- (void)testShouldHandleResponse_returnYes {
    OCMStub([self.mockEndpoint isV3url:[OCMArg any]]).andReturn(YES);

    NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"oldCampaigns": @[@1234, @56789]}
                                                   options:0
                                                     error:nil];
    EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                      headers:@{}
                                                                         body:body
                                                                 requestModel:self.requestModel
                                                                    timestamp:[NSDate date]];

    XCTAssertTrue([self.responseHandler shouldHandleResponse:response]);
}

- (void)testShouldHandleResponse_returnNo_notV3Url {
    OCMStub([self.mockEndpoint isV3url:[OCMArg any]]).andReturn(NO);

    EMSRequestModel *nonV3EventRequestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"https://www.emarsys.com"];
            }
                                                             timestampProvider:[EMSTimestampProvider new]
                                                                  uuidProvider:[EMSUUIDProvider new]];

    NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"oldCampaigns": @[@1234, @56789, @"245678"]}
                                                   options:0
                                                     error:nil];
    EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                      headers:@{}
                                                                         body:body
                                                                 requestModel:nonV3EventRequestModel
                                                                    timestamp:[NSDate date]];

    XCTAssertFalse([self.responseHandler shouldHandleResponse:response]);
}

- (void)testShouldHandleResponse_returnNo_oldMessagesArrayIsEmpty {
    OCMStub([self.mockEndpoint isV3url:[OCMArg any]]).andReturn(YES);

    NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"oldCampaigns": @[]}
                                                   options:0
                                                     error:nil];
    EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                      headers:@{}
                                                                         body:body
                                                                 requestModel:self.requestModel
                                                                    timestamp:[NSDate date]];

    XCTAssertFalse([self.responseHandler shouldHandleResponse:response]);
}

- (void)testShouldHandleResponse_returnNo_noOldMessages {
    OCMStub([self.mockEndpoint isV3url:[OCMArg any]]).andReturn(YES);
    NSData *body = [NSJSONSerialization dataWithJSONObject:@{
                    @"nothing": @[@"something"]

            }
                                                   options:0
                                                     error:nil];
    EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                      headers:@{}
                                                                         body:body
                                                                 requestModel:self.requestModel
                                                                    timestamp:[NSDate date]];

    XCTAssertFalse([self.responseHandler shouldHandleResponse:response]);
}

- (void)testShouldHandleResponse_returnNo_oldMessagesNotAnArray {
    OCMStub([self.mockEndpoint isV3url:[OCMArg any]]).andReturn(YES);
    NSData *body = [NSJSONSerialization dataWithJSONObject:@{
                    @"oldCampaigns": @{@"1234": @56789}

            }
                                                   options:0
                                                     error:nil];
    EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                      headers:@{}
                                                                         body:body
                                                                 requestModel:self.requestModel
                                                                    timestamp:[NSDate date]];

    XCTAssertFalse([self.responseHandler shouldHandleResponse:response]);
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


    NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"oldCampaigns": @[@"id2", @"id4"]}
                                                   options:0
                                                     error:nil];
    EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                      headers:@{}
                                                                         body:body
                                                                 requestModel:self.requestModel
                                                                    timestamp:[NSDate date]];

    _responseHandler = [[MEIAMCleanupResponseHandler alloc] initWithButtonClickRepository:repository
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


    NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"oldCampaigns": @[@"id2a", @"id4a"]}
                                                   options:0
                                                     error:nil];
    EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                      headers:@{}
                                                                         body:body
                                                                 requestModel:self.requestModel
                                                                    timestamp:[NSDate date]];

    _responseHandler = [[MEIAMCleanupResponseHandler alloc] initWithButtonClickRepository:self.mockButtonClickRepository
                                                                     displayIamRepository:repository
                                                                                 endpoint:self.mockEndpoint];

    [self.responseHandler handleResponse:response];

    NSArray<MEDisplayedIAM *> *displays = [repository query:[EMSFilterByNothingSpecification new]];

    XCTAssertEqual([displays count], 2);
    XCTAssertEqualObjects([displays[0] campaignId], @"id1a");
    XCTAssertEqualObjects([displays[1] campaignId], @"id3a");
}

@end
