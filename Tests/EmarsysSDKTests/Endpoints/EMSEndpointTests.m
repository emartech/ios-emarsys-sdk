//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSEndpoint.h"
#import "EMSValueProvider.h"

static NSString *const kClientServiceUrl = @"testClientServiceUrl";
static NSString *const kEventServiceUrl = @"testEventServiceUrl";
static NSString *const kPredictUrl = @"testPredictUrl";
static NSString *const kApplicationCode = @"testApplicationCode";

@interface EMSEndpointTests : XCTestCase

@property(nonatomic, strong) EMSEndpoint *endpoint;
@property(nonatomic, strong) EMSValueProvider *mockClientServiceUrlProvider;
@property(nonatomic, strong) EMSValueProvider *mockEventServiceUrlProvider;
@property(nonatomic, strong) EMSValueProvider *mockPredictUrlProvider;

@end

@implementation EMSEndpointTests

- (void)setUp {
    _mockClientServiceUrlProvider = OCMClassMock([EMSValueProvider class]);
    _mockEventServiceUrlProvider = OCMClassMock([EMSValueProvider class]);
    _mockPredictUrlProvider = OCMClassMock([EMSValueProvider class]);

    OCMStub([self.mockClientServiceUrlProvider provideValue]).andReturn(kClientServiceUrl);
    OCMStub([self.mockEventServiceUrlProvider provideValue]).andReturn(kEventServiceUrl);
    OCMStub([self.mockPredictUrlProvider provideValue]).andReturn(kPredictUrl);

    _endpoint = [[EMSEndpoint alloc] initWithClientServiceUrlProvider:self.mockClientServiceUrlProvider
                                              eventServiceUrlProvider:self.mockEventServiceUrlProvider
                                                   predictUrlProvider:self.mockPredictUrlProvider];
}

- (void)testInit_clientServiceUrlProvider_mustNotBeNil {
    @try {
        [[EMSEndpoint alloc] initWithClientServiceUrlProvider:nil
                                      eventServiceUrlProvider:self.mockEventServiceUrlProvider
                                           predictUrlProvider:self.mockPredictUrlProvider];
        XCTFail(@"Expected Exception when clientServiceUrlProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: clientServiceUrlProvider");
    }
}

- (void)testInit_eventServiceUrlProvider_mustNotBeNil {
    @try {
        [[EMSEndpoint alloc] initWithClientServiceUrlProvider:self.mockClientServiceUrlProvider
                                      eventServiceUrlProvider:nil
                                           predictUrlProvider:self.mockPredictUrlProvider];
        XCTFail(@"Expected Exception when eventServiceUrlProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: eventServiceUrlProvider");
    }
}

- (void)testInit_predictUrlProvider_mustNotBeNil {
    @try {
        [[EMSEndpoint alloc] initWithClientServiceUrlProvider:self.mockClientServiceUrlProvider
                                      eventServiceUrlProvider:self.mockEventServiceUrlProvider
                                           predictUrlProvider:nil];
        XCTFail(@"Expected Exception when predictUrlProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: predictUrlProvider");
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
    NSString *expectedUrl = @"https://deep-link.eservice.emarsys.net/api/clicks";

    NSString *result = [self.endpoint deeplinkUrl];

    XCTAssertEqualObjects(result, expectedUrl);
}

- (void)testV2EventServiceUrl {
    NSString *expectedUrl = @"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open";

    NSString *result = [self.endpoint v2EventServiceUrl];

    XCTAssertEqualObjects(result, expectedUrl);
}

- (void)testInboxUrl {
    NSString *expectedUrl = @"https://me-inbox.eservice.emarsys.net/api/";

    NSString *result = [self.endpoint inboxUrl];

    XCTAssertEqualObjects(result, expectedUrl);
}

- (NSString *)clientBaseUrl {
    return [NSString stringWithFormat:@"%@/v3/apps/%@/client", kClientServiceUrl, kApplicationCode];
}

@end
