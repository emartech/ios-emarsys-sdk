//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSResponseModel.h"
#import "EMSRemoteConfigResponseMapper.h"
#import "EMSRemoteConfig.h"
#import "EMSRandomProvider.h"

@interface EMSRemoteConfigResponseMapperTests : XCTestCase

@end

@implementation EMSRemoteConfigResponseMapperTests

- (void)testInit_randomProvider_mustNotBeNil {
    @try {
        [[EMSRemoteConfigResponseMapper alloc] initWithRandomProvider:nil];
        XCTFail(@"Expected Exception when randomProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: randomProvider");
    }
}

- (void)testMap {
    EMSRemoteConfigResponseMapper *mapper = [EMSRemoteConfigResponseMapper new];
    NSString *responseRawJson = @"{\n"
                                "        \"serviceUrls\":{\n"
                                "            \"eventService\":\"https://testEventService.url\",\n"
                                "                \"clientService\":\"https://client.emarsys.com/test/test\",\n"
                                "                \"predictService\":\"https://testPredictService.url\",\n"
                                "                \"mobileEngageV2Service\":\"https://testMobileEngageV2Service.url\",\n"
                                "                \"deepLinkService\":\"https://testDeepLinkService.url\",\n"
                                "                \"inboxService\":\"https://testinboxService.url\",\n"
                                "                \"v3MessageInboxService\":\"https://inbox.emarsys.net/test/test\"\n"
                                "        },\n"
                                "        \"logLevel\":\"warn\"\n"
                                "    }";
    EMSResponseModel *responseModel = [[EMSResponseModel alloc] initWithHttpUrlResponse:[[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:@"https://www.emarsys.com"]
                                                                                                                    statusCode:200
                                                                                                                   HTTPVersion:nil
                                                                                                                  headerFields:@{@"responseHeaderKey": @"responseHeaderValue"}]
                                                                                   data:[responseRawJson dataUsingEncoding:NSUTF8StringEncoding]
                                                                           requestModel:OCMClassMock([EMSRequestModel class])
                                                                              timestamp:[NSDate date]];
    EMSRemoteConfig *expectedConfig = [[EMSRemoteConfig alloc] initWithEventService:nil
                                                                      clientService:@"https://client.emarsys.com/test/test"
                                                                     predictService:nil
                                                              mobileEngageV2Service:nil
                                                                    deepLinkService:nil
                                                                       inboxService:nil
                                                              v3MessageInboxService:@"https://inbox.emarsys.net/test/test"
                                                                           logLevel:LogLevelWarn];

    EMSRemoteConfig *remoteConfig = [mapper map:responseModel];

    XCTAssertEqualObjects(remoteConfig, expectedConfig);
}

- (void)testMap_whenResponseModelParsedBodyIsNil {
    EMSRemoteConfigResponseMapper *mapper = [EMSRemoteConfigResponseMapper new];

    EMSResponseModel *responseModel = OCMClassMock([EMSResponseModel class]);

    EMSRemoteConfig *expected = [[EMSRemoteConfig alloc] initWithEventService:nil
                                                                clientService:nil
                                                               predictService:nil
                                                        mobileEngageV2Service:nil
                                                              deepLinkService:nil
                                                                 inboxService:nil
                                                        v3MessageInboxService:nil
                                                                     logLevel:LogLevelError];

    EMSRemoteConfig *result = [mapper map:responseModel];

    XCTAssertEqualObjects(expected, result);
}

- (void)testMap_withAlwaysLuckyLog {
    EMSRandomProvider *mockRandomProvider = OCMClassMock([EMSRandomProvider class]);
    OCMStub([mockRandomProvider provideDoubleUntil:@1]).andReturn(@1);

    EMSRemoteConfigResponseMapper *mapper = [[EMSRemoteConfigResponseMapper alloc]
            initWithRandomProvider:mockRandomProvider];
    NSString *responseRawJson = @"{\n"
                                "        \"logLevel\":\"error\",\n"
                                "        \"luckyLogger\":{\n"
                                "            \"logLevel\":\"debug\",\n"
                                "            \"threshold\":1\n"
                                "        }\n"
                                "    }";
    EMSResponseModel *responseModel = [[EMSResponseModel alloc] initWithHttpUrlResponse:[[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:@"https://www.emarsys.com"]
                                                                                                                    statusCode:200
                                                                                                                   HTTPVersion:nil
                                                                                                                  headerFields:@{@"responseHeaderKey": @"responseHeaderValue"}]
                                                                                   data:[responseRawJson dataUsingEncoding:NSUTF8StringEncoding]
                                                                           requestModel:OCMClassMock([EMSRequestModel class])
                                                                              timestamp:[NSDate date]];
    EMSRemoteConfig *expectedConfig = [[EMSRemoteConfig alloc] initWithEventService:nil
                                                                      clientService:nil
                                                                     predictService:nil
                                                              mobileEngageV2Service:nil
                                                                    deepLinkService:nil
                                                                       inboxService:nil
                                                              v3MessageInboxService:nil
                                                                           logLevel:LogLevelDebug];

    EMSRemoteConfig *remoteConfig = [mapper map:responseModel];

    XCTAssertEqualObjects(remoteConfig, expectedConfig);
}

- (void)testMap_withNeverLuckyLog {
    EMSRandomProvider *mockRandomProvider = OCMClassMock([EMSRandomProvider class]);
    OCMStub([mockRandomProvider provideDoubleUntil:@1]).andReturn(@0);

    EMSRemoteConfigResponseMapper *mapper = [[EMSRemoteConfigResponseMapper alloc]
            initWithRandomProvider:mockRandomProvider];
    NSString *responseRawJson = @"{\n"
                                "        \"logLevel\":\"error\",\n"
                                "        \"luckyLogger\":{\n"
                                "            \"logLevel\":\"debug\",\n"
                                "            \"threshold\":0\n"
                                "        }\n"
                                "    }";
    EMSResponseModel *responseModel = [[EMSResponseModel alloc] initWithHttpUrlResponse:[[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:@"https://www.emarsys.com"]
                                                                                                                    statusCode:200
                                                                                                                   HTTPVersion:nil
                                                                                                                  headerFields:@{@"responseHeaderKey": @"responseHeaderValue"}]
                                                                                   data:[responseRawJson dataUsingEncoding:NSUTF8StringEncoding]
                                                                           requestModel:OCMClassMock([EMSRequestModel class])
                                                                              timestamp:[NSDate date]];
    EMSRemoteConfig *expectedConfig = [[EMSRemoteConfig alloc] initWithEventService:nil
                                                                      clientService:nil
                                                                     predictService:nil
                                                              mobileEngageV2Service:nil
                                                                    deepLinkService:nil
                                                                       inboxService:nil
                                                              v3MessageInboxService:nil
                                                                           logLevel:LogLevelError];

    EMSRemoteConfig *remoteConfig = [mapper map:responseModel];

    XCTAssertEqualObjects(remoteConfig, expectedConfig);
}

- (void)testMap_withMiddleThresholdLuckyLog {
    EMSRandomProvider *mockRandomProvider = OCMClassMock([EMSRandomProvider class]);
    OCMStub([mockRandomProvider provideDoubleUntil:@1]).andReturn(@0);

    EMSRemoteConfigResponseMapper *mapper = [[EMSRemoteConfigResponseMapper alloc]
            initWithRandomProvider:mockRandomProvider];
    NSString *responseRawJson = @"{\n"
                                "        \"logLevel\":\"error\",\n"
                                "        \"luckyLogger\":{\n"
                                "            \"logLevel\":\"debug\",\n"
                                "            \"threshold\":0.5\n"
                                "        }\n"
                                "    }";
    EMSResponseModel *responseModel = [[EMSResponseModel alloc] initWithHttpUrlResponse:[[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:@"https://www.emarsys.com"]
                                                                                                                    statusCode:200
                                                                                                                   HTTPVersion:nil
                                                                                                                  headerFields:@{@"responseHeaderKey": @"responseHeaderValue"}]
                                                                                   data:[responseRawJson dataUsingEncoding:NSUTF8StringEncoding]
                                                                           requestModel:OCMClassMock([EMSRequestModel class])
                                                                              timestamp:[NSDate date]];
    EMSRemoteConfig *expectedConfig = [[EMSRemoteConfig alloc] initWithEventService:nil
                                                                      clientService:nil
                                                                     predictService:nil
                                                              mobileEngageV2Service:nil
                                                                    deepLinkService:nil
                                                                       inboxService:nil
                                                              v3MessageInboxService:nil
                                                                           logLevel:LogLevelDebug];

    EMSRemoteConfig *remoteConfig = [mapper map:responseModel];

    XCTAssertEqualObjects(remoteConfig, expectedConfig);
}

- (void)testMap_logLevel {
    NSArray *logLevels = @[@"trace", @"Debug", @"inFO", @"warN", @"ERROR"];
    NSArray *expectedLogLevels = @[@(LogLevelTrace), @(LogLevelDebug), @(LogLevelInfo), @(LogLevelWarn), @(LogLevelError)];

    for (NSUInteger i = 0; i < [logLevels count]; i++) {
        [self assertForRawLogLevel:logLevels[i]
                          logLevel:(LogLevel) [expectedLogLevels[i] intValue]];
    }
}

- (void)assertForRawLogLevel:(NSString *)rawLogLevel
                    logLevel:(LogLevel)logLevel {
    EMSRemoteConfigResponseMapper *mapper = [EMSRemoteConfigResponseMapper new];
    NSString *responseRawJson = [NSString stringWithFormat:@"{\n"
                                                           "        \"logLevel\":\"%@\"\n"
                                                           "    }",
                                                           rawLogLevel];
    EMSResponseModel *responseModel = [[EMSResponseModel alloc] initWithHttpUrlResponse:[[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:@"https://www.emarsys.com"]
                                                                                                                    statusCode:200
                                                                                                                   HTTPVersion:nil
                                                                                                                  headerFields:@{@"responseHeaderKey": @"responseHeaderValue"}]
                                                                                   data:[responseRawJson dataUsingEncoding:NSUTF8StringEncoding]
                                                                           requestModel:OCMClassMock([EMSRequestModel class])
                                                                              timestamp:[NSDate date]];
    EMSRemoteConfig *expectedConfig = [[EMSRemoteConfig alloc] initWithEventService:nil
                                                                      clientService:nil
                                                                     predictService:nil
                                                              mobileEngageV2Service:nil
                                                                    deepLinkService:nil
                                                                       inboxService:nil
                                                              v3MessageInboxService:nil
                                                                           logLevel:logLevel];

    EMSRemoteConfig *remoteConfig = [mapper map:responseModel];

    XCTAssertEqualObjects(remoteConfig, expectedConfig);
}

@end
