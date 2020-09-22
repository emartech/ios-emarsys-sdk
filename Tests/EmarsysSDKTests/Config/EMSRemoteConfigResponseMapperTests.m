//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSResponseModel.h"
#import "EMSRemoteConfigResponseMapper.h"
#import "EMSRemoteConfig.h"
#import "EMSRandomProvider.h"
#import "EMSDeviceInfo.h"

@interface EMSRemoteConfigResponseMapperTests : XCTestCase

@property(nonatomic, strong) EMSDeviceInfo *mockDeviceInfo;

@end

@implementation EMSRemoteConfigResponseMapperTests

- (void)setUp {
    _mockDeviceInfo = [OCMockObject mockForClass:[EMSDeviceInfo class]];
    OCMStub([self.mockDeviceInfo hardwareId]).andReturn(@"testHWId");
}

- (void)testInit_randomProvider_mustNotBeNil {
    @try {
        [[EMSRemoteConfigResponseMapper alloc] initWithRandomProvider:nil
                                                           deviceInfo:self.mockDeviceInfo] ;
        XCTFail(@"Expected Exception when randomProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: randomProvider");
    }
}

- (void)testInit_deviceInfo_mustNotBeNil {
    @try {
        [[EMSRemoteConfigResponseMapper alloc] initWithRandomProvider:[OCMockObject mockForClass:[EMSRandomProvider class]]
                                                           deviceInfo:nil];
        XCTFail(@"Expected Exception when deviceInfo is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: deviceInfo");
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

- (void)testMap_overrides {
    EMSRandomProvider *randomProvider = [EMSRandomProvider new];
    
    EMSRemoteConfigResponseMapper *mapper = [[EMSRemoteConfigResponseMapper alloc] initWithRandomProvider:randomProvider
                                                                                               deviceInfo:self.mockDeviceInfo];
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
                                "        \"logLevel\":\"warn\",\n"
                                "        \"overrides\":{\n"
                                "        \"testHWId\":{\n"
                                "            \"serviceUrls\":{\n"
                                "                \"eventService\":\"https://event.emarsys.com/test/test\",\n"
                                "                    \"clientService\":\"https://client2.emarsys.com/test/test\",\n"
                                "                    \"predictService\":\"https://predict.emarsys.com/test/test\",\n"
                                "            },\n"
                                "            \"logLevel\":\"error\",\n"
                                "            },"
                                "        },"
                                "    }";
    EMSResponseModel *responseModel = [[EMSResponseModel alloc] initWithHttpUrlResponse:[[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:@"https://www.emarsys.com"]
                                                                                                                    statusCode:200
                                                                                                                   HTTPVersion:nil
                                                                                                                  headerFields:@{@"responseHeaderKey": @"responseHeaderValue"}]
                                                                                   data:[responseRawJson dataUsingEncoding:NSUTF8StringEncoding]
                                                                           requestModel:OCMClassMock([EMSRequestModel class])
                                                                              timestamp:[NSDate date]];
    EMSRemoteConfig *expectedConfig = [[EMSRemoteConfig alloc] initWithEventService:@"https://event.emarsys.com/test/test"
                                                                      clientService:@"https://client2.emarsys.com/test/test"
                                                                     predictService:@"https://predict.emarsys.com/test/test"
                                                              mobileEngageV2Service:nil
                                                                    deepLinkService:nil
                                                                       inboxService:nil
                                                              v3MessageInboxService:@"https://inbox.emarsys.net/test/test"
                                                                           logLevel:LogLevelError];

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

    EMSRemoteConfigResponseMapper *mapper = [[EMSRemoteConfigResponseMapper alloc] initWithRandomProvider:mockRandomProvider
                                                                                               deviceInfo:self.mockDeviceInfo];
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

    EMSRemoteConfigResponseMapper *mapper = [[EMSRemoteConfigResponseMapper alloc] initWithRandomProvider:mockRandomProvider
                                                                                               deviceInfo:self.mockDeviceInfo];
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

    EMSRemoteConfigResponseMapper *mapper = [[EMSRemoteConfigResponseMapper alloc] initWithRandomProvider:mockRandomProvider
                                                                                               deviceInfo:self.mockDeviceInfo];
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
    NSArray *logLevels = @[@"trace", @"Debug", @"inFO", @"warN", @"ERROR", @"MetRic"];
    NSArray *expectedLogLevels = @[@(LogLevelTrace), @(LogLevelDebug), @(LogLevelInfo), @(LogLevelWarn), @(LogLevelError), @(LogLevelMetric)];

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
