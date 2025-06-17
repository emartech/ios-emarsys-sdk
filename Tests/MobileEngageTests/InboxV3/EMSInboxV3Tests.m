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
@property(nonatomic, strong) NSString *testMessageId;

@end

@implementation EMSInboxV3Tests

- (void)setUp {
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockInboxResultParser = OCMClassMock([EMSInboxResultParser class]);

    _inbox = [[EMSInboxV3 alloc] initWithRequestFactory:self.mockRequestFactory
                                         requestManager:self.mockRequestManager
                                      inboxResultParser:self.mockInboxResultParser];
    _testMessageId = [NSString stringWithFormat:@"%d", INT_MAX];
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
    XCTAssertEqualObjects(self.inbox.messages, expectedResult.messages);
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
        self.inbox.messages = @[[self responseMessage]];
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
    XCTAssertNil(self.inbox.messages);
}

- (void)testAddTag {
    EMSInboxV3 *partialMockInbox = OCMPartialMock(self.inbox);

    NSString *tag = @"testTag";

    [partialMockInbox addTag:tag
                  forMessage:self.testMessageId];

    OCMVerify([partialMockInbox addTag:tag
                            forMessage:self.testMessageId
                       completionBlock:nil]);
}

- (void)testAddTag_when_messageIsAvailable_tagIsNotAvailable {
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:[OCMArg any]
                                                          eventAttributes:[OCMArg any]
                                                                eventType:EventTypeInternal]).andReturn(mockRequestModel);
    OCMStub([self.mockRequestManager submitRequestModel:[OCMArg any]
                                    withCompletionBlock:[OCMArg invokeBlock]]);

    NSArray *tags = @[@"nottesttag"];
    EMSMessage *mockMessage = OCMClassMock([EMSMessage class]);
    OCMStub([mockMessage id]).andReturn(self.testMessageId);
    OCMStub([mockMessage tags]).andReturn(tags);
    NSArray *messages = @[mockMessage];

    self.inbox.messages = messages;

    NSString *tag = @"testTag";

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];
    [self.inbox addTag:tag
            forMessage:self.testMessageId
       completionBlock:^(NSError *error) {
           [expectation fulfill];
       }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                           timeout:2];

    OCMVerify([self.mockRequestFactory createEventRequestModelWithEventName:@"inbox:tag:add"
                                                            eventAttributes:(@{
                                                                    @"messageId": self.testMessageId,
                                                                    @"tag": @"testtag"
                                                            })
                                                                  eventType:EventTypeInternal]);
    OCMVerify([self.mockRequestManager submitRequestModel:mockRequestModel
                                      withCompletionBlock:[OCMArg any]]);
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
}

- (void)testAddTag_when_messageIsAvailable_tagIsAvailable {
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:[OCMArg any]
                                                          eventAttributes:[OCMArg any]
                                                                eventType:[OCMArg any]]).andReturn(mockRequestModel);

    NSArray *tags = @[@"testtag"];
    EMSMessage *mockMessage = OCMClassMock([EMSMessage class]);
    OCMStub([mockMessage id]).andReturn(self.testMessageId);
    OCMStub([mockMessage tags]).andReturn(tags);
    NSArray *messages = @[mockMessage];

    self.inbox.messages = messages;

    NSString *tag = @"testTag";

    OCMReject([self.mockRequestFactory createEventRequestModelWithEventName:@"inbox:tag:add"
                                                            eventAttributes:(@{
                                                                    @"messageId": self.testMessageId,
                                                                    @"tag": @"testtag"
                                                            })
                                                                  eventType:EventTypeInternal]);
    OCMReject([self.mockRequestManager submitRequestModel:mockRequestModel
                                      withCompletionBlock:[OCMArg any]]);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];
    [self.inbox addTag:tag
            forMessage:self.testMessageId
       completionBlock:^(NSError *error) {
           [expectation fulfill];
       }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                           timeout:2];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
}

- (void)testAddTag_when_messageIsNotAvailable_tagIsNotAvailable {
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:[OCMArg any]
                                                          eventAttributes:[OCMArg any]
                                                                eventType:[OCMArg any]]).andReturn(mockRequestModel);

    NSArray *tags = @[@"nottesttag"];
    EMSMessage *mockMessage = OCMClassMock([EMSMessage class]);
    OCMStub([mockMessage id]).andReturn(@"notTestMessageId");
    OCMStub([mockMessage tags]).andReturn(tags);
    NSArray *messages = @[mockMessage];

    self.inbox.messages = messages;

    NSString *tag = @"testTag";

    OCMReject([self.mockRequestFactory createEventRequestModelWithEventName:@"inbox:tag:add"
                                                            eventAttributes:(@{
                                                                    @"messageId": self.testMessageId,
                                                                    @"tag": @"testtag"
                                                            })
                                                                  eventType:EventTypeInternal]);
    OCMReject([self.mockRequestManager submitRequestModel:mockRequestModel
                                      withCompletionBlock:[OCMArg any]]);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];
    [self.inbox addTag:tag
            forMessage:self.testMessageId
       completionBlock:^(NSError *error) {
           [expectation fulfill];
       }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);

}

- (void)testAddTag_tag_mustNotBeNil {
    @try {
        [self.inbox addTag:nil
                forMessage:self.testMessageId];
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
    EMSCompletionBlock completionBlock = ^(NSError *error) {
    };
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);

    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:@"inbox:tag:add"
                                                          eventAttributes:(@{
                                                                  @"messageId": self.testMessageId,
                                                                  @"tag": lowerCasedTag
                                                          })
                                                                eventType:EventTypeInternal]).andReturn(mockRequestModel);

    [self.inbox addTag:tag
            forMessage:self.testMessageId
       completionBlock:completionBlock];

    OCMVerify([self.mockRequestFactory createEventRequestModelWithEventName:@"inbox:tag:add"
                                                            eventAttributes:(@{
                                                                    @"messageId": self.testMessageId,
                                                                    @"tag": lowerCasedTag
                                                            })
                                                                  eventType:EventTypeInternal]);
    OCMVerify([self.mockRequestManager submitRequestModel:mockRequestModel
                                      withCompletionBlock:completionBlock]);
}

- (void)testRemoveTag {
    EMSInboxV3 *partialMockInbox = OCMPartialMock(self.inbox);

    NSString *tag = @"testTag";

    [partialMockInbox removeTag:tag
                    fromMessage:self.testMessageId];

    OCMVerify([partialMockInbox removeTag:tag
                              fromMessage:self.testMessageId
                          completionBlock:nil]);
}

- (void)testRemoveTag_tag_mustNotBeNil {
    @try {
        [self.inbox removeTag:nil
                  fromMessage:self.testMessageId];
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
    EMSCompletionBlock completionBlock = ^(NSError *error) {
    };
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);

    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:@"inbox:tag:remove"
                                                          eventAttributes:(@{
                                                                  @"messageId": self.testMessageId,
                                                                  @"tag": lowerCasedTag
                                                          })
                                                                eventType:EventTypeInternal]).andReturn(mockRequestModel);

    [self.inbox removeTag:tag
              fromMessage:self.testMessageId
          completionBlock:completionBlock];

    OCMVerify([self.mockRequestFactory createEventRequestModelWithEventName:@"inbox:tag:remove"
                                                            eventAttributes:(@{
                                                                    @"messageId": self.testMessageId,
                                                                    @"tag": lowerCasedTag
                                                            })
                                                                  eventType:EventTypeInternal]);
    OCMVerify([self.mockRequestManager submitRequestModel:mockRequestModel
                                      withCompletionBlock:completionBlock]);
}

- (void)testRemoveTag_when_messageIsAvailable_tagIsAvailable {
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:[OCMArg any]
                                                          eventAttributes:[OCMArg any]
                                                                eventType:EventTypeInternal]).andReturn(mockRequestModel);
    OCMStub([self.mockRequestManager submitRequestModel:[OCMArg any]
                                    withCompletionBlock:[OCMArg invokeBlock]]);

    NSArray *tags = @[@"testtag"];
    EMSMessage *mockMessage = OCMClassMock([EMSMessage class]);
    OCMStub([mockMessage id]).andReturn(self.testMessageId);
    OCMStub([mockMessage tags]).andReturn(tags);
    NSArray *messages = @[mockMessage];

    self.inbox.messages = messages;

    NSString *tag = @"testTag";

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];
    [self.inbox removeTag:tag
            fromMessage:self.testMessageId
       completionBlock:^(NSError *error) {
           [expectation fulfill];
       }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);


    OCMVerify([self.mockRequestFactory createEventRequestModelWithEventName:@"inbox:tag:remove"
                                                            eventAttributes:(@{
                                                                    @"messageId": self.testMessageId,
                                                                    @"tag": @"testtag"
                                                            })
                                                                  eventType:EventTypeInternal]);
    OCMVerify([self.mockRequestManager submitRequestModel:mockRequestModel
                                      withCompletionBlock:[OCMArg any]]);
}

- (void)testRemoveTag_when_messageIsAvailable_tagIsNotAvailable {
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:[OCMArg any]
                                                          eventAttributes:[OCMArg any]
                                                                eventType:[OCMArg any]]).andReturn(mockRequestModel);

    NSArray *tags = @[@"nottesttag"];
    EMSMessage *mockMessage = OCMClassMock([EMSMessage class]);
    OCMStub([mockMessage id]).andReturn(self.testMessageId);
    OCMStub([mockMessage tags]).andReturn(tags);
    NSArray *messages = @[mockMessage];

    self.inbox.messages = messages;

    NSString *tag = @"testTag";

    OCMReject([self.mockRequestFactory createEventRequestModelWithEventName:@"inbox:tag:remove"
                                                            eventAttributes:(@{
                                                                    @"messageId": self.testMessageId,
                                                                    @"tag": @"testtag"
                                                            })
                                                                  eventType:EventTypeInternal]);
    OCMReject([self.mockRequestManager submitRequestModel:mockRequestModel
                                      withCompletionBlock:[OCMArg any]]);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];
    [self.inbox removeTag:tag
              fromMessage:self.testMessageId
          completionBlock:^(NSError *error) {
              [expectation fulfill];
          }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);

}

- (void)testRemoveTag_when_messageIsNotAvailable_tagIsNotAvailable {
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:[OCMArg any]
                                                          eventAttributes:[OCMArg any]
                                                                eventType:[OCMArg any]]).andReturn(mockRequestModel);

    NSArray *tags = @[@"nottesttag"];
    EMSMessage *mockMessage = OCMClassMock([EMSMessage class]);
    OCMStub([mockMessage id]).andReturn(@"notTestMessageId");
    OCMStub([mockMessage tags]).andReturn(tags);
    NSArray *messages = @[mockMessage];

    self.inbox.messages = messages;

    NSString *tag = @"testTag";

    OCMReject([self.mockRequestFactory createEventRequestModelWithEventName:@"inbox:tag:remove"
                                                            eventAttributes:(@{
                                                                    @"messageId": self.testMessageId,
                                                                    @"tag": @"testtag"
                                                            })
                                                                  eventType:EventTypeInternal]);
    OCMReject([self.mockRequestManager submitRequestModel:mockRequestModel
                                      withCompletionBlock:[OCMArg any]]);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];
    [self.inbox removeTag:tag
              fromMessage:self.testMessageId
          completionBlock:^(NSError *error) {
              [expectation fulfill];
          }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);

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
                             imageAltText:@"Image description"
                               receivedAt:@(142141412515)
                                updatedAt:@(142141412599)
                                expiresAt:@(142141412659)
                                     tags:@[@"tag1", @"tag2"]
                               properties:@{
                                       @"key1": @"value1",
                                       @"key2": @"value2"}
                                  actions:nil];
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
