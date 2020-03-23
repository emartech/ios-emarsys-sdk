//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSInboxResult.h"
#import "EMSMessage.h"
#import "EMSRequestModel.h"
#import "EMSResponseModel.h"
#import "EMSInboxResultParser.h"

@interface EMSInboxResultParserTests : XCTestCase

@property(nonatomic, strong) EMSInboxResultParser *parser;

@end

@implementation EMSInboxResultParserTests

- (void)setUp {
    _parser = [[EMSInboxResultParser alloc] init];
}

- (void)testParseFromResponse {
    NSString *bodyString = @"{\n"
                           "  \"count\": 2,\n"
                           "  \"messages\": [\n"
                           "    {\n"
                           "        \"id\": \"ef14afa4\",\n"
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
                           "    },\n"
                           "    {\n"
                           "        \"id\": \"testId2\",\n"
                           "        \"multichannelId\": 22,\n"
                           "        \"campaignId\": \"campaignId2\",\n"
                           "        \"title\": \"title2\",\n"
                           "        \"body\": \"body2\",\n"
                           "        \"imageUrl\": \"https://example.com/image2.jpg\",\n"
                           "        \"action\": \"https://example.com/image2.jpg\",\n"
                           "        \"receivedAt\": 2222,\n"
                           "        \"updatedAt\": 2222,\n"
                           "        \"ttl\": 250,\n"
                           "        \"tags\": [\"tag21\", \"tag22\"],\n"
                           "        \"sourceId\": 212345555,\n"
                           "        \"sourceRunId\": \"sourceRunId2\",\n"
                           "        \"sourceType\": \"sourceType2\",\n"
                           "    }\n"
                           "  ]\n"
                           "}";

    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];

    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([mockRequestModel requestId]).andReturn(@"testRequestModelId");
    EMSResponseModel *mockResponseModel = OCMClassMock([EMSResponseModel class]);
    NSDictionary *parsedBody = [NSJSONSerialization JSONObjectWithData:bodyData
                                                               options:0
                                                                 error:nil];
    OCMStub([mockResponseModel parsedBody]).andReturn(parsedBody);


    EMSInboxResult *expectedResult = [EMSInboxResult alloc];
    EMSMessage *message1 = [[EMSMessage alloc] initWithId:@"ef14afa4"
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
                                               sourceType:@"sourceType"];
    EMSMessage *message2 = [[EMSMessage alloc] initWithId:@"testId2"
                                           multichannelId:@(22)
                                               campaignId:@"campaignId2"
                                                    title:@"title2"
                                                     body:@"body2"
                                                 imageUrl:@"https://example.com/image2.jpg"
                                                   action:@"https://example.com/image2.jpg"
                                               receivedAt:@(2222)
                                                updatedAt:@(2222)
                                                      ttl:@(250)
                                                     tags:@[@"tag21", @"tag22"]
                                                 sourceId:@(212345555)
                                              sourceRunId:@"sourceRunId2"
                                               sourceType:@"sourceType2"];
    [expectedResult setMessages:@[message1, message2]];

    EMSInboxResult *result = [self.parser parseFromResponse:mockResponseModel];

    XCTAssertEqualObjects(result, expectedResult);
}

- (void)testParseFromResponse_whenMessagesAreMissing {
    NSString *bodyString = @"{\n"
                           "  \"count\": 2\n"
                           "}";

    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];

    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([mockRequestModel requestId]).andReturn(@"testRequestModelId");
    EMSResponseModel *mockResponseModel = OCMClassMock([EMSResponseModel class]);
    NSDictionary *parsedBody = [NSJSONSerialization JSONObjectWithData:bodyData
                                                               options:0
                                                                 error:nil];
    OCMStub([mockResponseModel parsedBody]).andReturn(parsedBody);


    EMSInboxResult *expectedResult = [EMSInboxResult alloc];

    EMSInboxResult *result = [self.parser parseFromResponse:mockResponseModel];

    XCTAssertEqualObjects(result, expectedResult);
}

- (void)testParseFromResponse_whenThereAreNoMessages {
    NSString *bodyString = @"{\n"
                           "  \"count\": 2\n"
                           "  \"messages\": []\n"
                           "}";

    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];

    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([mockRequestModel requestId]).andReturn(@"testRequestModelId");
    EMSResponseModel *mockResponseModel = OCMClassMock([EMSResponseModel class]);
    NSDictionary *parsedBody = [NSJSONSerialization JSONObjectWithData:bodyData
                                                               options:0
                                                                 error:nil];
    OCMStub([mockResponseModel parsedBody]).andReturn(parsedBody);


    EMSInboxResult *expectedResult = [EMSInboxResult alloc];

    EMSInboxResult *result = [self.parser parseFromResponse:mockResponseModel];

    XCTAssertEqualObjects(result, expectedResult);
}

@end
