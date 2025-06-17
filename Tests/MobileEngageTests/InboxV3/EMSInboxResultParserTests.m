//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSInboxResult.h"
#import "EMSRequestModel.h"
#import "EMSResponseModel.h"
#import "EMSInboxResultParser.h"
#import "EMSAppEventActionModel.h"
#import "EMSOpenExternalUrlActionModel.h"
#import "EMSCustomEventActionModel.h"
#import "EMSDismissActionModel.h"

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
                           "        \"campaignId\": \"campaignId\",\n"
                           "        \"collapseId\": \"collapseId\",\n"
                           "        \"title\": \"title\",\n"
                           "        \"body\": \"body\",\n"
                           "        \"imageUrl\": \"https://example.com/image.jpg\",\n"
                           "        \"imageAltText\": \"Image description\",\n"
                           "        \"receivedAt\": 142141412515,\n"
                           "        \"updatedAt\": 142141412599,\n"
                           "        \"expiresAt\": 142141412599,\n"
                           "        \"tags\": [\"tag1\", \"tag2\"],\n"
                           "        \"properties\": {"
                           "            \"key1\": \"value1\","
                           "            \"key2\": \"value2\"},"
                           "         \"ems\":{"
                           "            \"actions\": ["
                           "                {"
                           "                \"id\": \"testId1\","
                           "                \"title\": \"testTitle1\","
                           "                \"type\": \"MEAppEvent\","
                           "                \"name\": \"testName1\","
                           "                \"payload\": {"
                           "                    \"key1\": \"value1\","
                           "                    \"key2\": \"value2\""
                           "                }"
                           "            },"
                           "            {"
                           "                \"id\": \"testId2\","
                           "                \"title\": \"testTitle2\","
                           "                \"type\": \"OpenExternalUrl\","
                           "                \"url\": \"https://www.emarsys.com\""
                           "            }"
                           "        ]"
                           "    },\n"
                           "},\n"
                           "    {\n"
                           "        \"id\": \"testId2\",\n"
                           "        \"campaignId\": \"campaignId2\",\n"
                           "        \"collapseId\": \"collapseId2\",\n"
                           "        \"title\": \"title2\",\n"
                           "        \"body\": \"body2\",\n"
                           "        \"imageUrl\": \"https://example.com/image2.jpg\",\n"
                           "        \"imageAltText\": \"Image description 2\",\n"
                           "        \"receivedAt\": 2222,\n"
                           "        \"updatedAt\": 2222,\n"
                           "        \"expiresAt\": 250,\n"
                           "        \"tags\": [\"tag21\", \"tag22\"],\n"
                           "        \"properties\": {"
                           "            \"key3\": \"value3\","
                           "            \"key4\": \"value4\"},"
                           "        \"ems\":{"
                           "            \"actions\": ["
                           "                {"
                           "                    \"id\": \"testId3\","
                           "                    \"title\": \"testTitle3\","
                           "                    \"type\": \"MECustomEvent\","
                           "                    \"name\": \"testName3\","
                           "                    \"payload\": {"
                           "                        \"key3\": \"value3\","
                           "                        \"key4\": \"value4\""
                           "                    }"
                           "                },"
                           "                {"
                           "                    \"id\": \"testId4\","
                           "                    \"title\": \"testTitle4\","
                           "                    \"type\": \"Dismiss\""
                           "                }"
                           "            ]"
                           "        }\n"
                           "    },\n"
                           "    {\n"
                           "        \"id\": \"testId3\",\n"
                           "        \"campaignId\": \"campaignId3\",\n"
                           "        \"collapseId\": null,\n"
                           "        \"title\": \"title3\",\n"
                           "        \"body\": \"body3\",\n"
                           "        \"imageUrl\": null,\n"
                           "        \"imageAltText\": null,\n"
                           "        \"receivedAt\": 2222,\n"
                           "        \"updatedAt\": null,\n"
                           "        \"expiresAt\": null,\n"
                           "        \"tags\": null,\n"
                           "        \"properties\": null}\n"
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
                                               campaignId:@"campaignId"
                                               collapseId:@"collapseId"
                                                    title:@"title"
                                                     body:@"body"
                                                 imageUrl:@"https://example.com/image.jpg"
                                             imageAltText:@"Image description"
                                               receivedAt:@(142141412515)
                                                updatedAt:@(142141412599)
                                                expiresAt:@(142141412599)
                                                     tags:@[@"tag1", @"tag2"]
                                               properties:@{
                                                       @"key1": @"value1",
                                                       @"key2": @"value2"}
                                                  actions:@[
                                                          [[EMSAppEventActionModel alloc] initWithId:@"testId1"
                                                                                               title:@"testTitle1"
                                                                                                type:@"MEAppEvent"
                                                                                                name:@"testName1"
                                                                                             payload:@{
                                                                                                     @"key1": @"value1",
                                                                                                     @"key2": @"value2"
                                                                                             }],
                                                          [[EMSOpenExternalUrlActionModel alloc] initWithId:@"testId2"
                                                                                                      title:@"testTitle2"
                                                                                                       type:@"OpenExternalUrl"
                                                                                                        url:[[NSURL alloc] initWithString:@"https://www.emarsys.com"]]
                                                  ]];
    EMSMessage *message2 = [[EMSMessage alloc] initWithId:@"testId2"
                                               campaignId:@"campaignId2"
                                               collapseId:@"collapseId2"
                                                    title:@"title2"
                                                     body:@"body2"
                                                 imageUrl:@"https://example.com/image2.jpg"
                                             imageAltText:@"Image description 2"
                                               receivedAt:@(2222)
                                                updatedAt:@(2222)
                                                expiresAt:@(250)
                                                     tags:@[@"tag21", @"tag22"]
                                               properties:@{
                                                       @"key3": @"value3",
                                                       @"key4": @"value4"}
                                                  actions:@[
                                                          [[EMSCustomEventActionModel alloc] initWithId:@"testId3"
                                                                                                  title:@"testTitle3"
                                                                                                   type:@"MECustomEvent"
                                                                                                   name:@"testName3"
                                                                                                payload:@{
                                                                                                        @"key3": @"value3",
                                                                                                        @"key4": @"value4"
                                                                                                }],
                                                          [[EMSDismissActionModel alloc] initWithId:@"testId4"
                                                                                              title:@"testTitle4"
                                                                                               type:@"Dismiss"]
                                                  ]];
    EMSMessage *message3 = [[EMSMessage alloc] initWithId:@"testId3"
                                               campaignId:@"campaignId3"
                                               collapseId:nil
                                                    title:@"title3"
                                                     body:@"body3"
                                                 imageUrl:nil
                                             imageAltText:nil
                                               receivedAt:@(2222)
                                                updatedAt:nil
                                                expiresAt:nil
                                                     tags:nil
                                               properties:nil
                                                  actions:nil];
    [expectedResult setMessages:@[message1, message2, message3]];

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

- (void)testParseFromResponse_whenActionUrlIsInvalidInMessages {
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
                           "        \"imageAltText\": \"Image description\",\n"
                           "        \"receivedAt\": 142141412515,\n"
                           "        \"updatedAt\": 142141412599,\n"
                           "        \"expiresAt\": 142141412599,\n"
                           "        \"tags\": [\"tag1\", \"tag2\"],\n"
                           "        \"properties\": {"
                           "            \"key1\": \"value1\","
                           "            \"key2\": \"value2\"},"
                           "         \"ems\":{"
                           "            \"actions\": ["
                           "            {"
                           "                \"id\": \"testId1\","
                           "                \"title\": \"testTitle1\","
                           "                \"type\": \"OpenExternalUrl\","
                           "                \"url\": \"https://www.emarsys.com\""
                           "            },"
                           "            {"
                           "                \"id\": \"testId2\","
                           "                \"title\": \"testTitle2\","
                           "                \"type\": \"OpenExternalUrl\","
                           "                \"url\": \"https://emarsys.invalid||/5%\""
                           "            }"
                           "        ]"
                           "      }\n"
                           "    }\n"
                           "  ]"
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

    EMSMessage *message = [[EMSMessage alloc] initWithId:@"ef14afa4"
                                              campaignId:@"campaignId"
                                              collapseId:@"collapseId"
                                                   title:@"title"
                                                    body:@"body"
                                                imageUrl:@"https://example.com/image.jpg"
                                            imageAltText:@"Image description"
                                              receivedAt:@(142141412515)
                                               updatedAt:@(142141412599)
                                               expiresAt:@(142141412599)
                                                    tags:@[@"tag1", @"tag2"]
                                              properties:@{
                                                      @"key1": @"value1",
                                                      @"key2": @"value2"}
                                                 actions:@[
                                                         [[EMSOpenExternalUrlActionModel alloc] initWithId:@"testId1"
                                                                                                     title:@"testTitle1"
                                                                                                      type:@"OpenExternalUrl"
                                                                                                       url:[[NSURL alloc] initWithString:@"https://www.emarsys.com"]],
                                                         [[EMSOpenExternalUrlActionModel alloc] initWithId:@"testId2"
                                                                                                     title:@"testTitle2"
                                                                                                      type:@"OpenExternalUrl"
                                                                                                       url:[NSURL new]
                                                         ]]];

    [expectedResult setMessages:@[message]];
    EMSInboxResult *result = [self.parser parseFromResponse:mockResponseModel];

    XCTAssertEqualObjects(result, expectedResult);
}

@end
