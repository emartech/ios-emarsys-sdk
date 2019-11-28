//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSResponseModel.h"
#import "EMSRemoteConfigResponseMapper.h"
#import "EMSRemoteConfig.h"

@interface EMSRemoteConfigResponseMapperTests : XCTestCase

@end

@implementation EMSRemoteConfigResponseMapperTests

- (void)testMap {
    EMSRemoteConfigResponseMapper *mapper = [EMSRemoteConfigResponseMapper new];
    NSString *responseRawJson = @"{\n"
                                "        \"serviceUrls\":{\n"
                                "            \"eventService\":\"https://testEventService.url\",\n"
                                "                \"clientService\":\"https://testClientService.url\",\n"
                                "                \"predictService\":\"https://testPredictService.url\",\n"
                                "                \"mobileEngageV2Service\":\"https://testMobileEngageV2Service.url\",\n"
                                "                \"deepLinkService\":\"https://testDeepLinkService.url\",\n"
                                "                \"inboxService\":\"https://testinboxService.url\"\n"
                                "        }\n"
                                "    }";
    EMSResponseModel *responseModel = [[EMSResponseModel alloc] initWithHttpUrlResponse:[[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:@"https://www.emarsys.com"]
                                                                                                                    statusCode:200
                                                                                                                   HTTPVersion:nil
                                                                                                                  headerFields:@{@"responseHeaderKey": @"responseHeaderValue"}]
                                                                                   data:[responseRawJson dataUsingEncoding:NSUTF8StringEncoding]
                                                                           requestModel:OCMClassMock([EMSRequestModel class])
                                                                              timestamp:[NSDate date]];
    EMSRemoteConfig *expectedConfig = [[EMSRemoteConfig alloc] initWithEventService:@"https://testEventService.url"
                                                                      clientService:@"https://testClientService.url"
                                                                     predictService:@"https://testPredictService.url"
                                                              mobileEngageV2Service:@"https://testMobileEngageV2Service.url"
                                                                    deepLinkService:@"https://testDeepLinkService.url"
                                                                       inboxService:@"https://testinboxService.url"];

    EMSRemoteConfig *remoteConfig = [mapper map:responseModel];

    XCTAssertEqualObjects(remoteConfig, expectedConfig);
}

@end
