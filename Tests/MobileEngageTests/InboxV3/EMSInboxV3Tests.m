//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSInboxV3.h"
#import "EMSRequestFactory.h"
#import "EMSRequestManager.h"
#import "NSError+EMSCore.h"
#import "EMSResponseModel.h"
#import "EMSInboxResult.h"
#import "EMSInboxResultParser.h"
#import "EMSMessage.h"

@interface EMSInboxV3Tests : XCTestCase

@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;
@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) EMSInboxResultParser *mockInboxResultParser;
@property(nonatomic, strong) EMSInboxV3 *inbox;

@end

@implementation EMSInboxV3Tests

- (void)setUp {
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockInboxResultParser = OCMClassMock([EMSInboxResultParser class]);

    _inbox = [[EMSInboxV3 alloc] initWithRequestFactory:self.mockRequestFactory
                                         requestManager:self.mockRequestManager
                                      inboxResultParser:self.mockInboxResultParser];
}

- (void)testInit_requestFactory_mustNotBeNil {
    @try {
        [[EMSInboxV3 alloc] initWithRequestFactory:nil
                                    requestManager:self.mockRequestManager
                                 inboxResultParser:self.mockInboxResultParser];
        XCTFail(@"Expected Exception when requestFactory is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestFactory");
    }
}

- (void)testInit_requestManager_mustNotBeNil {
    @try {
        [[EMSInboxV3 alloc] initWithRequestFactory:self.mockRequestFactory
                                    requestManager:nil
                                 inboxResultParser:self.mockInboxResultParser];
        XCTFail(@"Expected Exception when requestManager is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestManager");
    }
}

- (void)testInit_inboxResultParser_mustNotBeNil {
    @try {
        [[EMSInboxV3 alloc] initWithRequestFactory:self.mockRequestFactory
                                    requestManager:self.mockRequestManager
                                 inboxResultParser:NULL];
        XCTFail(@"Expected Exception when inboxResultParser is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: inboxResultParser");
    }
}

- (void)testFetchMessagesWithResultBlock_success {
    NSString *bodyString = @"{\n"
                           "  \"count\": 1,\n"
                           "  \"messages\": [\n"
                           "    {\n"
                           "        \"initWithId\": \"ef14afa4\",\n"
                           "        \"multichannelId\": 11,\n"
                           "        \"campaignId\": \"campaignId\",\n"
                           "        \"title\": \"title\",\n"
                           "        \"body\": \"body\",\n"
                           "        \"imageUrl\": \"https://example.com/image.jpg\",\n"
                           "        \"action\": \"https://example.com/image.jpg\",\n"
                           "        \"receivedAt\": 142141412515,\n"
                           "        \"updatedAt\": 142141412599,\n"
                           "        \"ttl\": 50,\n"
                           "        \"tags\": [\"tag1\", \"tag2\"],\n"
                           "        \"sourceId\": 12345555,\n"
                           "        \"sourceRunId\": \"sourceRunId\",\n"
                           "        \"sourceType\": \"sourceType\",\n"
                           "    }\n"
                           "  ]\n"
                           "}";

    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];

    EMSInboxResult *expectedResult = [EMSInboxResult alloc];

    [expectedResult setMessages:@[[[EMSMessage alloc] initWithId:@"ef14afa4"
                                                  multichannelId:@(11)
                                                      campaignId:@"campaignId"
                                                           title:@"title"
                                                            body:@"body"
                                                        imageUrl:@"https://example.com/image.jpg"
                                                          action:@"https://example.com/image.jpg"
                                                      receivedAt:@(142141412515)
                                                       updatedAt:@(142141412599)
                                                             ttl:@(50)
                                                            tags:@[@"tag1", @"tag2"]
                                                        sourceId:@(12345555)
                                                     sourceRunId:@"sourceRunId"
                                                      sourceType:@"sourceType"]]];

    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([mockRequestModel requestId]).andReturn(@"testRequestModelId");
    EMSResponseModel *mockResponseModel = OCMClassMock([EMSResponseModel class]);
    OCMStub([mockResponseModel body]).andReturn(bodyData);

    OCMStub([self.mockInboxResultParser parseFromResponse:mockResponseModel]).andReturn(expectedResult);
    OCMStub([self.mockRequestFactory createMessageInboxRequestModel]).andReturn(mockRequestModel);
    OCMStub([self.mockRequestManager submitRequestModelNow:mockRequestModel
                                              successBlock:([OCMArg invokeBlockWithArgs:@"testRequestModelId",
                                                                                        mockResponseModel,
                                                                                        nil])
                                                errorBlock:[OCMArg any]]);

    __block EMSInboxResult *result = nil;

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    [self.inbox fetchMessagesWithResultBlock:^(EMSInboxResult *inboxResult, NSError *error) {
        result = inboxResult;
        [expectation fulfill];
    }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(result, expectedResult);
}

- (void)testFetchMessagesWithResultBlock_failure {
    NSError *expectedError = [NSError errorWithCode:1401
                               localizedDescription:@"testError"];

    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([mockRequestModel requestId]).andReturn(@"testRequestModelId");

    OCMStub([self.mockRequestFactory createMessageInboxRequestModel]).andReturn(mockRequestModel);
    OCMStub([self.mockRequestManager submitRequestModelNow:mockRequestModel
                                              successBlock:[OCMArg any]
                                                errorBlock:([OCMArg invokeBlockWithArgs:@"testRequestModelId",
                                                                                        expectedError,
                                                                                        nil])]);

    __block NSError *result = nil;

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    [self.inbox fetchMessagesWithResultBlock:^(EMSInboxResult *inboxResult, NSError *error) {
        result = error;
        [expectation fulfill];
    }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(result, expectedError);
}

@end
