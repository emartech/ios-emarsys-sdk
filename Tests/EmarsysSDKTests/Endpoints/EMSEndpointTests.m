//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSEndpoint.h"
#import "EMSValueProvider.h"
#import "EMSRemoteConfig.h"

static NSString *const kClientServiceUrl = @"testClientServiceUrl";
static NSString *const kEventServiceUrl = @"testEventServiceUrl";
static NSString *const kPredictUrl = @"testPredictUrl";
static NSString *const kDeeplinkUrl = @"testDeeplinkUrl";
static NSString *const kV2ServiceUrl = @"testV2ServiceUrl";
static NSString *const kInboxUrl = @"testInboxUrl";
static NSString *const kApplicationCode = @"testApplicationCode";

@interface EMSEndpointTests : XCTestCase

@property(nonatomic, strong) EMSEndpoint *endpoint;
@property(nonatomic, strong) EMSValueProvider *mockClientServiceUrlProvider;
@property(nonatomic, strong) EMSValueProvider *mockEventServiceUrlProvider;
@property(nonatomic, strong) EMSValueProvider *mockPredictUrlProvider;
@property(nonatomic, strong) EMSValueProvider *mockDeeplinkUrlProvider;
@property(nonatomic, strong) EMSValueProvider *mockV2EventServiceUrlProvider;
@property(nonatomic, strong) EMSValueProvider *mockInboxUrlProvider;

@end

@implementation EMSEndpointTests

- (void)setUp {
    _mockClientServiceUrlProvider = OCMClassMock([EMSValueProvider class]);
    _mockEventServiceUrlProvider = OCMClassMock([EMSValueProvider class]);
    _mockPredictUrlProvider = OCMClassMock([EMSValueProvider class]);
    _mockDeeplinkUrlProvider = OCMClassMock([EMSValueProvider class]);
    _mockV2EventServiceUrlProvider = OCMClassMock([EMSValueProvider class]);
    _mockInboxUrlProvider = OCMClassMock([EMSValueProvider class]);

    OCMStub([self.mockClientServiceUrlProvider provideValue]).andReturn(kClientServiceUrl);
    OCMStub([self.mockEventServiceUrlProvider provideValue]).andReturn(kEventServiceUrl);
    OCMStub([self.mockPredictUrlProvider provideValue]).andReturn(kPredictUrl);
    OCMStub([self.mockDeeplinkUrlProvider provideValue]).andReturn(kDeeplinkUrl);
    OCMStub([self.mockV2EventServiceUrlProvider provideValue]).andReturn(kV2ServiceUrl);
    OCMStub([self.mockInboxUrlProvider provideValue]).andReturn(kInboxUrl);

    _endpoint = [[EMSEndpoint alloc] initWithClientServiceUrlProvider:self.mockClientServiceUrlProvider
                                              eventServiceUrlProvider:self.mockEventServiceUrlProvider
                                                   predictUrlProvider:self.mockPredictUrlProvider
                                                  deeplinkUrlProvider:self.mockDeeplinkUrlProvider
                                            v2EventServiceUrlProvider:self.mockV2EventServiceUrlProvider
                                                     inboxUrlProvider:self.mockInboxUrlProvider];
}

- (void)testInit_clientServiceUrlProvider_mustNotBeNil {
    @try {
        [[EMSEndpoint alloc] initWithClientServiceUrlProvider:nil
                                      eventServiceUrlProvider:self.mockEventServiceUrlProvider
                                           predictUrlProvider:self.mockPredictUrlProvider
                                          deeplinkUrlProvider:self.mockDeeplinkUrlProvider
                                    v2EventServiceUrlProvider:self.mockV2EventServiceUrlProvider
                                             inboxUrlProvider:self.mockInboxUrlProvider];
        XCTFail(@"Expected Exception when clientServiceUrlProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: clientServiceUrlProvider");
    }
}

- (void)testInit_eventServiceUrlProvider_mustNotBeNil {
    @try {
        [[EMSEndpoint alloc] initWithClientServiceUrlProvider:self.mockClientServiceUrlProvider
                                      eventServiceUrlProvider:nil
                                           predictUrlProvider:self.mockPredictUrlProvider
                                          deeplinkUrlProvider:self.mockDeeplinkUrlProvider
                                    v2EventServiceUrlProvider:self.mockV2EventServiceUrlProvider
                                             inboxUrlProvider:self.mockInboxUrlProvider];
        XCTFail(@"Expected Exception when eventServiceUrlProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: eventServiceUrlProvider");
    }
}

- (void)testInit_predictUrlProvider_mustNotBeNil {
    @try {
        [[EMSEndpoint alloc] initWithClientServiceUrlProvider:self.mockClientServiceUrlProvider
                                      eventServiceUrlProvider:self.mockEventServiceUrlProvider
                                           predictUrlProvider:nil
                                          deeplinkUrlProvider:self.mockDeeplinkUrlProvider
                                    v2EventServiceUrlProvider:self.mockV2EventServiceUrlProvider
                                             inboxUrlProvider:self.mockInboxUrlProvider];
        XCTFail(@"Expected Exception when predictUrlProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: predictUrlProvider");
    }
}

- (void)testInit_deeplinkUrlProvider_mustNotBeNil {
    @try {
        [[EMSEndpoint alloc] initWithClientServiceUrlProvider:self.mockClientServiceUrlProvider
                                      eventServiceUrlProvider:self.mockEventServiceUrlProvider
                                           predictUrlProvider:self.mockPredictUrlProvider
                                          deeplinkUrlProvider:nil
                                    v2EventServiceUrlProvider:self.mockV2EventServiceUrlProvider
                                             inboxUrlProvider:self.mockInboxUrlProvider];
        XCTFail(@"Expected Exception when deeplinkUrlProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: deeplinkUrlProvider");
    }
}

- (void)testInit_v2EventServiceUrlProvider_mustNotBeNil {
    @try {
        [[EMSEndpoint alloc] initWithClientServiceUrlProvider:self.mockClientServiceUrlProvider
                                      eventServiceUrlProvider:self.mockEventServiceUrlProvider
                                           predictUrlProvider:self.mockPredictUrlProvider
                                          deeplinkUrlProvider:self.mockDeeplinkUrlProvider
                                    v2EventServiceUrlProvider:nil
                                             inboxUrlProvider:self.mockInboxUrlProvider];
        XCTFail(@"Expected Exception when v2EventServiceUrlProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: v2EventServiceUrlProvider");
    }
}

- (void)testInit_inboxUrlProvider_mustNotBeNil {
    @try {
        [[EMSEndpoint alloc] initWithClientServiceUrlProvider:self.mockClientServiceUrlProvider
                                      eventServiceUrlProvider:self.mockEventServiceUrlProvider
                                           predictUrlProvider:self.mockPredictUrlProvider
                                          deeplinkUrlProvider:self.mockDeeplinkUrlProvider
                                    v2EventServiceUrlProvider:self.mockV2EventServiceUrlProvider
                                             inboxUrlProvider:nil];
        XCTFail(@"Expected Exception when inboxUrlProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: inboxUrlProvider");
    }
}

- (void)testClientServiceUrl {
    NSString *result = [self.endpoint clientServiceUrl];

    XCTAssertEqualObjects(result, kClientServiceUrl);
}

- (void)testEventServiceUrl {
    NSString *result = [self.endpoint eventServiceUrl];

    XCTAssertEqualObjects(result, kEventServiceUrl);
}

- (void)testClientUrlWithApplicationCode {
    NSString *expectedUrl = [self clientBaseUrl];

    NSString *result = [self.endpoint clientUrlWithApplicationCode:kApplicationCode];

    XCTAssertEqualObjects(result, expectedUrl);
}

- (void)testPushTokenUrlWithApplicationCode {
    NSString *expectedUrl = [NSString stringWithFormat:@"%@/push-token", [self clientBaseUrl]];

    NSString *result = [self.endpoint pushTokenUrlWithApplicationCode:kApplicationCode];

    XCTAssertEqualObjects(result, expectedUrl);
}

- (void)testContactUrlWithApplicationCode {
    NSString *expectedUrl = [NSString stringWithFormat:@"%@/contact", [self clientBaseUrl]];

    NSString *result = [self.endpoint contactUrlWithApplicationCode:kApplicationCode];

    XCTAssertEqualObjects(result, expectedUrl);
}

- (void)testContactTokenUrlWithApplicationCode {
    NSString *expectedUrl = [NSString stringWithFormat:@"%@/contact-token", [self clientBaseUrl]];

    NSString *result = [self.endpoint contactTokenUrlWithApplicationCode:kApplicationCode];

    XCTAssertEqualObjects(result, expectedUrl);
}

- (void)testEventUrlWithApplicationCode {
    NSString *expectedUrl = [NSString stringWithFormat:@"%@/v3/apps/%@/client/events",
                                                       kEventServiceUrl,
                                                       kApplicationCode];

    NSString *result = [self.endpoint eventUrlWithApplicationCode:kApplicationCode];

    XCTAssertEqualObjects(result, expectedUrl);
}

- (void)testIsV3_shouldReturnYes_when_URLClientUrl {
    NSString *url = [self.endpoint clientUrlWithApplicationCode:@"testApplicationCode"];

    XCTAssertTrue([self.endpoint isV3url:url]);
}

- (void)testIsV3_shouldReturnNo_when_URLIsNotV3 {
    NSString *url = @"https://www.notv3url.com";

    XCTAssertFalse([self.endpoint isV3url:url]);
}

- (void)testIsV3_shouldReturnYes_when_URLEventUrl {
    NSString *url = [self.endpoint eventUrlWithApplicationCode:@"testApplicationCode"];

    XCTAssertTrue([self.endpoint isV3url:url]);
}

- (void)testPredictUrl {
    NSString *expectedUrl = @"testPredictUrl";

    NSString *result = [self.endpoint predictUrl];

    XCTAssertEqualObjects(result, expectedUrl);
}

- (void)testDeeplinkUrl {
    NSString *result = [self.endpoint deeplinkUrl];

    XCTAssertEqualObjects(result, kDeeplinkUrl);
}

- (void)testV2EventServiceUrl {
    NSString *result = [self.endpoint v2EventServiceUrl];

    XCTAssertEqualObjects(result, kV2ServiceUrl);
}

- (void)testInboxUrl {
    NSString *result = [self.endpoint inboxUrl];

    XCTAssertEqualObjects(result, kInboxUrl);
}

- (void)testUpdateUrlsWithRemoteConfig {
    NSString *const eventServiceUrl = @"newEventServiceUrl";
    NSString *const clientServiceUrl = @"newClientServiceUrl";
    NSString *const predictServiceUrl = @"newPredictServiceUrl";
    NSString *const v2ServiceUrl = @"newV2ServiceUrl";
    NSString *const deeplinkServiceUrl = @"newDeeplinkServiceUrl";
    NSString *const inboxServiceUrl = @"newInboxServiceUrl";
    EMSRemoteConfig *remoteConfig = [[EMSRemoteConfig alloc] initWithEventService:eventServiceUrl
                                                                    clientService:clientServiceUrl
                                                                   predictService:predictServiceUrl
                                                            mobileEngageV2Service:v2ServiceUrl
                                                                  deepLinkService:deeplinkServiceUrl
                                                                     inboxService:inboxServiceUrl];

    [self.endpoint updateUrlsWithRemoteConfig:remoteConfig];

    OCMVerify([self.mockEventServiceUrlProvider updateValue:eventServiceUrl]);
    OCMVerify([self.mockClientServiceUrlProvider updateValue:clientServiceUrl]);
    OCMVerify([self.mockPredictUrlProvider updateValue:predictServiceUrl]);
    OCMVerify([self.mockV2EventServiceUrlProvider updateValue:v2ServiceUrl]);
    OCMVerify([self.mockDeeplinkUrlProvider updateValue:deeplinkServiceUrl]);
    OCMVerify([self.mockInboxUrlProvider updateValue:inboxServiceUrl]);
}

- (void)testReset {
    [self.endpoint reset];

    OCMVerify([self.mockInboxUrlProvider updateValue:nil]);
    OCMVerify([self.mockV2EventServiceUrlProvider updateValue:nil]);
    OCMVerify([self.mockDeeplinkUrlProvider updateValue:nil]);
    OCMVerify([self.mockPredictUrlProvider updateValue:nil]);
    OCMVerify([self.mockClientServiceUrlProvider updateValue:nil]);
    OCMVerify([self.mockEventServiceUrlProvider updateValue:nil]);
}

- (NSString *)clientBaseUrl {
    return [NSString stringWithFormat:@"%@/v3/apps/%@/client", kClientServiceUrl, kApplicationCode];
}

@end
