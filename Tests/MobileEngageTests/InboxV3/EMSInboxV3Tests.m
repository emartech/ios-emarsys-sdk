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
#import "EMSInboxResultParser.h"

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
                                 inboxResultParser:nil];
        XCTFail(@"Expected Exception when inboxResultParser is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: inboxResultParser");
    }
}

- (void)testFetchMessages_resultBlock_mustNotBeNil {
    @try {
        [self.inbox fetchMessagesWithResultBlock:nil];
        XCTFail(@"Expected Exception when resultBlock is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: resultBlock");
    }
}

- (void)testFetchMessagesWithResultBlock_success {
    EMSInboxResult *expectedResult = [[EMSInboxResult alloc] init];
    [expectedResult setMessages:@[
            [self responseMessage]
    ]];

    [self setupForSuccess];

    __block EMSInboxResult *result = nil;
    __block NSOperationQueue *returnedOperationQueue = nil;
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.inbox fetchMessagesWithResultBlock:^(EMSInboxResult *inboxResult, NSError *error) {
            result = inboxResult;
            returnedOperationQueue = [NSOperationQueue currentQueue];
            [expectation fulfill];
        }];
    });
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(result, expectedResult);
    XCTAssertEqualObjects(returnedOperationQueue, [NSOperationQueue mainQueue]);
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
    __block NSOperationQueue *returnedOperationQueue = nil;
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.inbox fetchMessagesWithResultBlock:^(EMSInboxResult *inboxResult, NSError *error) {
            result = error;
            returnedOperationQueue = [NSOperationQueue currentQueue];
            [expectation fulfill];
        }];
    });
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(result, expectedError);
    XCTAssertEqualObjects(returnedOperationQueue, [NSOperationQueue mainQueue]);
}

- (void)testAddTag {
    EMSInboxV3 *partialMockInbox = OCMPartialMock(self.inbox);

    NSString *tag = @"testTag";
    NSString *messageId = @"testId1";

    [partialMockInbox addTag:tag
                  forMessage:messageId];

    OCMVerify([partialMockInbox addTag:tag
                            forMessage:messageId
                       completionBlock:nil]);
}

- (void)testAddTag_tag_mustNotBeNil {
    @try {
        [self.inbox addTag:nil
                forMessage:@"testMessageId"];
        XCTFail(@"Expected Exception when tag is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: tag");
    }
}

- (void)testAddTag_messageId_mustNotBeNil {
    @try {
        [self.inbox addTag:@"testTag"
                forMessage:nil];
        XCTFail(@"Expected Exception when messageId is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: messageId");
    }
}

- (void)testAddTagCompletionBlock {
    NSString *tag = @"testTag";
    NSString *lowerCasedTag = @"testtag";
    NSString *messageId = @"testId1";
    EMSCompletionBlock completionBlock = ^(NSError *error) {
    };
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);

    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:@"inbox:tag:add"
                                                          eventAttributes:(@{
                                                                  @"messageId": messageId,
                                                                  @"tag": lowerCasedTag
                                                          })
                                                                eventType:EventTypeInternal]).andReturn(mockRequestModel);

    [self.inbox addTag:tag
            forMessage:messageId
       completionBlock:completionBlock];

    OCMVerify([self.mockRequestFactory createEventRequestModelWithEventName:@"inbox:tag:add"
                                                            eventAttributes:(@{
                                                                    @"messageId": messageId,
                                                                    @"tag": lowerCasedTag
                                                            })
                                                                  eventType:EventTypeInternal]);
    OCMVerify([self.mockRequestManager submitRequestModel:mockRequestModel
                                      withCompletionBlock:completionBlock]);
}

- (void)testRemoveTag {
    EMSInboxV3 *partialMockInbox = OCMPartialMock(self.inbox);

    NSString *tag = @"testTag";
    NSString *messageId = @"testId1";

    [partialMockInbox removeTag:tag
                    fromMessage:messageId];

    OCMVerify([partialMockInbox removeTag:tag
                              fromMessage:messageId
                          completionBlock:nil]);
}

- (void)testRemoveTag_tag_mustNotBeNil {
    @try {
        [self.inbox removeTag:nil
                  fromMessage:@"testMessageId"];
        XCTFail(@"Expected Exception when tag is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: tag");
    }
}

- (void)testRemoveTag_messageId_mustNotBeNil {
    @try {
        [self.inbox removeTag:@"testTag"
                  fromMessage:nil];
        XCTFail(@"Expected Exception when messageId is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: messageId");
    }
}

- (void)testRemoveTagCompletionBlock {
    NSString *tag = @"testTag";
    NSString *lowerCasedTag = @"testtag";
    NSString *messageId = @"testId1";
    EMSCompletionBlock completionBlock = ^(NSError *error) {
    };
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);

    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:@"inbox:tag:remove"
                                                          eventAttributes:(@{
                                                                  @"messageId": messageId,
                                                                  @"tag": lowerCasedTag
                                                          })
                                                                eventType:EventTypeInternal]).andReturn(mockRequestModel);

    [self.inbox removeTag:tag
              fromMessage:messageId
          completionBlock:completionBlock];

    OCMVerify([self.mockRequestFactory createEventRequestModelWithEventName:@"inbox:tag:remove"
                                                            eventAttributes:(@{
                                                                    @"messageId": messageId,
                                                                    @"tag": lowerCasedTag
                                                            })
                                                                  eventType:EventTypeInternal]);
    OCMVerify([self.mockRequestManager submitRequestModel:mockRequestModel
                                      withCompletionBlock:completionBlock]);
}

- (EMSResponseModel *)responseModel {
    NSString *bodyString = @"{\n"
                           "  \"count\": 1,\n"
                           "  \"messages\": [\n"
                           "    {\n"
                           "        \"id\": \"ef14afa4\",\n"
                           "        \"campaignId\": \"campaignId\",\n"
                           "        \"collapseId\": \"collapseId\",\n"
                           "        \"title\": \"title\",\n"
                           "        \"body\": \"body\",\n"
                           "        \"imageUrl\": \"https://example.com/image.jpg\",\n"
                           "        \"receivedAt\": 142141412515,\n"
                           "        \"updatedAt\": 142141412599,\n"
                           "        \"expiresAt\": 142141412659,\n"
                           "        \"tags\": [\"tag1\", \"tag2\"],\n"
                           "        \"properties\": {"
                           "            \"key1\": \"value1\","
                           "            \"key2\": \"value2\"}"
                           "    }\n"
                           "  ]\n"
                           "}";

    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];


    EMSResponseModel *mockResponseModel = OCMClassMock([EMSResponseModel class]);
    OCMStub([mockResponseModel body]).andReturn(bodyData);
    return mockResponseModel;
}

- (EMSRequestModel *)requestModel {
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([mockRequestModel requestId]).andReturn(@"testRequestModelId");
    return mockRequestModel;
}

- (EMSMessage *)responseMessage {
    return [[EMSMessage alloc] initWithId:@"ef14afa4"
                               campaignId:@"campaignId"
                               collapseId:@"collapseId"
                                    title:@"title"
                                     body:@"body"
                                 imageUrl:@"https://example.com/image.jpg"
                               receivedAt:@(142141412515)
                                updatedAt:@(142141412599)
                                expiresAt:@(142141412659)
                                     tags:@[@"tag1", @"tag2"]
                               properties:@{
                                       @"key1": @"value1",
                                       @"key2": @"value2"}];
}

- (void)setupForSuccess {
    EMSInboxResult *parsedMessages = [[EMSInboxResult alloc] init];
    [parsedMessages setMessages:@[[self responseMessage]]];

    EMSResponseModel *responseModel = [self responseModel];
    EMSRequestModel *requestModel = [self requestModel];

    OCMStub([self.mockInboxResultParser parseFromResponse:responseModel]).andReturn(parsedMessages);
    OCMStub([self.mockRequestFactory createMessageInboxRequestModel]).andReturn(requestModel);
    OCMStub([self.mockRequestManager submitRequestModelNow:requestModel
                                              successBlock:([OCMArg invokeBlockWithArgs:@"testRequestModelId",
                                                                                        responseModel,
                                                                                        nil])
                                                errorBlock:[OCMArg any]]);
}

@end
