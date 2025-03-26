//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSRequestFactory.h"
#import "EMSUUIDProvider.h"
#import "EMSRequestModel.h"
#import "MERequestContext.h"
#import "EMSDeviceInfo.h"
#import "EMSDeviceInfo+MEClientPayload.h"
#import "NSDate+EMSCore.h"
#import "EmarsysSDKVersion.h"
#import "EMSAuthentication.h"
#import "EMSEndpoint.h"
#import "EMSValueProvider.h"
#import "MEButtonClickRepository.h"
#import "EMSSessionIdHolder.h"
#import "EMSStorage.h"
#import "MEExperimental.h"
#import "EMSInnerFeature.h"
#import "MEExperimental+Test.h"
#import "EMSStorageProtocol.h"
#import "PRERequestContext.h"

@interface EMSRequestFactoryTests : XCTestCase

@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) MERequestContext *mockRequestContext;
@property(nonatomic, strong) PRERequestContext *mockPredictRequestContext;
@property(nonatomic, strong) EMSTimestampProvider *mockTimestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *mockUUIDProvider;
@property(nonatomic, strong) EMSDeviceInfo *mockDeviceInfo;
@property(nonatomic, strong) EMSEndpoint *endpoint;
@property(nonatomic, strong) MEButtonClickRepository *mockButtonClickRepository;
@property(nonatomic, strong) EMSStorage *mockStorage;
@property(nonatomic, strong) EMSSessionIdHolder *sessionIdHolder;

@property(nonatomic, strong) NSDate *timestamp;

@end

@implementation EMSRequestFactoryTests

- (void)setUp {
    _mockRequestContext = OCMClassMock([MERequestContext class]);
    _mockPredictRequestContext = OCMClassMock([PRERequestContext class]);
    _mockTimestampProvider = OCMClassMock([EMSTimestampProvider class]);
    _mockUUIDProvider = OCMClassMock([EMSUUIDProvider class]);
    _mockDeviceInfo = OCMClassMock([EMSDeviceInfo class]);
    _mockButtonClickRepository = OCMClassMock([MEButtonClickRepository class]);
    _mockStorage = OCMClassMock([EMSStorage class]);

    _sessionIdHolder = [EMSSessionIdHolder new];

    EMSValueProvider *clientServiceUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://me-client.eservice.emarsys.net"
                                                                                       valueKey:@"CLIENT_SERVICE_URL"];
    EMSValueProvider *eventServiceUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://mobile-events.eservice.emarsys.net"
                                                                                      valueKey:@"EVENT_SERVICE_URL"];
    EMSValueProvider *deeplinkUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://deep-link.eservice.emarsys.net/api/clicks"
                                                                                  valueKey:@"DEEPLINK_URL"];
    EMSValueProvider *v2EventServiceUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open"
                                                                                        valueKey:@"V2_EVENT_SERVICE_URL"];
    EMSValueProvider *v3MessageInboxUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://me-inbox.eservice.emarsys.net"
                                                                                        valueKey:@"V3_MESSAGE_INBOX_URL"];

    _endpoint = [[EMSEndpoint alloc] initWithClientServiceUrlProvider:clientServiceUrlProvider
                                              eventServiceUrlProvider:eventServiceUrlProvider
                                                   predictUrlProvider:OCMClassMock([EMSValueProvider class])
                                                  deeplinkUrlProvider:deeplinkUrlProvider
                                            v3MessageInboxUrlProvider:v3MessageInboxUrlProvider];

    _timestamp = [NSDate date];

    OCMStub(self.mockRequestContext.timestampProvider).andReturn(self.mockTimestampProvider);
    OCMStub(self.mockRequestContext.deviceInfo).andReturn(self.mockDeviceInfo);
    OCMStub(self.mockRequestContext.uuidProvider).andReturn(self.mockUUIDProvider);
    OCMStub(self.mockRequestContext.refreshToken).andReturn(@"testRefreshToken");

    OCMStub(self.mockTimestampProvider.provideTimestamp).andReturn(self.timestamp);
    OCMStub(self.mockUUIDProvider.provideUUIDString).andReturn(@"requestId");
    OCMStub(self.mockDeviceInfo.clientId).andReturn(@"hardwareId");
    OCMStub(self.mockDeviceInfo.deviceType).andReturn(@"testDeviceType");
    OCMStub(self.mockDeviceInfo.osVersion).andReturn(@"testOSVersion");

    _requestFactory = [[EMSRequestFactory alloc] initWithRequestContext:self.mockRequestContext
                                                  predictRequestContext:self.mockPredictRequestContext
                                                               endpoint:self.endpoint
                                                  buttonClickRepository:self.mockButtonClickRepository
                                                        sessionIdHolder:self.sessionIdHolder
                                                                storage:self.mockStorage];
}

- (void)tearDown {
    [super tearDown];
    [MEExperimental reset];
}


- (void)testInit_requestContext_mustNotBeNil {
    @try {
        [[EMSRequestFactory alloc] initWithRequestContext:nil
                                    predictRequestContext:self.mockPredictRequestContext
                                                 endpoint:OCMClassMock([EMSEndpoint class])
                                    buttonClickRepository:self.mockButtonClickRepository
                                          sessionIdHolder:self.sessionIdHolder
                                                  storage:self.mockStorage];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: requestContext"]);
    }
}

- (void)testInit_predictRequestContext_mustNotBeNil {
    @try {
        [[EMSRequestFactory alloc] initWithRequestContext:self.mockRequestContext
                                    predictRequestContext:nil
                                                 endpoint:OCMClassMock([EMSEndpoint class])
                                    buttonClickRepository:self.mockButtonClickRepository
                                          sessionIdHolder:self.sessionIdHolder
                                                  storage:self.mockStorage];
        XCTFail(@"Expected Exception when predictRequestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: predictRequestContext"]);
    }
}

- (void)testInit_endpoint_mustNotBeNil {
    @try {
        [[EMSRequestFactory alloc] initWithRequestContext:self.mockRequestContext
                                    predictRequestContext:self.mockPredictRequestContext
                                                 endpoint:nil
                                    buttonClickRepository:self.mockButtonClickRepository
                                          sessionIdHolder:self.sessionIdHolder
                                                  storage:self.mockStorage];
        XCTFail(@"Expected Exception when endpoint is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: endpoint"]);
    }
}

- (void)testInit_buttonClickRepository_mustNotBeNil {
    @try {
        [[EMSRequestFactory alloc] initWithRequestContext:self.mockRequestContext
                                    predictRequestContext:self.mockPredictRequestContext
                                                 endpoint:self.endpoint
                                    buttonClickRepository:nil
                                          sessionIdHolder:self.sessionIdHolder
                                                  storage:self.mockStorage];
        XCTFail(@"Expected Exception when buttonClickRepository is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: buttonClickRepository"]);
    }
}

- (void)testInit_sessionIdHolder_mustNotBeNil {
    @try {
        [[EMSRequestFactory alloc] initWithRequestContext:self.mockRequestContext
                                    predictRequestContext:self.mockPredictRequestContext
                                                 endpoint:self.endpoint
                                    buttonClickRepository:self.mockButtonClickRepository
                                          sessionIdHolder:nil
                                                  storage:self.mockStorage];
        XCTFail(@"Expected Exception when sessionIdHolder is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: sessionIdHolder"]);
    }
}

- (void)testInit_storage_mustNotBeNil {
    @try {
        [[EMSRequestFactory alloc] initWithRequestContext:self.mockRequestContext
                                    predictRequestContext:self.mockPredictRequestContext
                                                 endpoint:self.endpoint
                                    buttonClickRepository:self.mockButtonClickRepository
                                          sessionIdHolder:self.sessionIdHolder
                                                  storage:nil];
        XCTFail(@"Expected Exception when storage is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: storage"]);
    }
}

- (void)testCreateDeviceInfoRequestModel {
    OCMStub(self.mockRequestContext.applicationCode).andReturn(@"testApplicationCode");

    NSDictionary *payload = @{
            @"platform": @"ios",
            @"applicationVersion": @"0.0.1",
            @"deviceModel": @"iPhone 6",
            @"osVersion": @"12.1",
            @"sdkVersion": @"0.0.1",
            @"language": @"en-US",
            @"timezone": @"+100"
    };
    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:@"requestId"
                                                                             timestamp:self.timestamp
                                                                                expiry:FLT_MAX
                                                                                   url:[[NSURL alloc] initWithString:@"https://me-client.eservice.emarsys.net/v3/apps/testApplicationCode/client"]
                                                                                method:@"POST"
                                                                               payload:payload
                                                                               headers:nil
                                                                                extras:nil];
    OCMStub(self.mockDeviceInfo.clientPayload).andReturn(payload);

    EMSRequestModel *requestModel = [self.requestFactory createDeviceInfoRequestModel];

    XCTAssertEqualObjects(expectedRequestModel, requestModel);
}

- (void)testCreateDeviceInfoRequestModel_when_ApplicationCode_isNil {
    EMSRequestModel *result = [self.requestFactory createDeviceInfoRequestModel];

    XCTAssertNil(result);
}

- (void)testCreatePushTokenRequestModelWithPushToken {
    OCMStub(self.mockRequestContext.applicationCode).andReturn(@"testApplicationCode");

    NSString *const pushToken = @"awesdrxcftvgyhbj";
    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:@"requestId"
                                                                             timestamp:self.timestamp
                                                                                expiry:FLT_MAX
                                                                                   url:[[NSURL alloc] initWithString:@"https://me-client.eservice.emarsys.net/v3/apps/testApplicationCode/client/push-token"]
                                                                                method:@"PUT"
                                                                               payload:@{@"pushToken": pushToken}
                                                                               headers:nil
                                                                                extras:nil];

    EMSRequestModel *requestModel = [self.requestFactory createPushTokenRequestModelWithPushToken:pushToken];

    XCTAssertEqualObjects(expectedRequestModel, requestModel);
}

- (void)testCreatePushTokenRequestModelWithPushToken_when_ApplicationCode_isNil {
    NSString *const pushToken = @"awesdrxcftvgyhbj";
    EMSRequestModel *result = [self.requestFactory createPushTokenRequestModelWithPushToken:pushToken];

    XCTAssertNil(result);
}

- (void)testCreateClearPushTokenRequestModel {
    OCMStub(self.mockRequestContext.applicationCode).andReturn(@"testApplicationCode");

    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:@"requestId"
                                                                             timestamp:self.timestamp
                                                                                expiry:FLT_MAX
                                                                                   url:[[NSURL alloc] initWithString:@"https://me-client.eservice.emarsys.net/v3/apps/testApplicationCode/client/push-token"]
                                                                                method:@"DELETE"
                                                                               payload:@{}
                                                                               headers:nil
                                                                                extras:nil];

    EMSRequestModel *requestModel = [self.requestFactory createClearPushTokenRequestModel];

    XCTAssertEqualObjects(expectedRequestModel, requestModel);
}

- (void)testClearCreatePushTokenRequestModel_when_ApplicationCode_isNil {
    EMSRequestModel *result = [self.requestFactory createClearPushTokenRequestModel];

    XCTAssertNil(result);
}

- (void)testCreateContactRequestModel {
    OCMStub([self.mockRequestContext contactFieldId]).andReturn(@3);
    OCMStub([self.mockRequestContext contactFieldValue]).andReturn(@"test@test.com");
    OCMStub([self.mockRequestContext hasContactIdentification]).andReturn(YES);
    OCMStub(self.mockRequestContext.applicationCode).andReturn(@"testApplicationCode");

    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:@"requestId"
                                                                             timestamp:self.timestamp
                                                                                expiry:FLT_MAX
                                                                                   url:[[NSURL alloc] initWithString:@"https://me-client.eservice.emarsys.net/v3/apps/testApplicationCode/client/contact?anonymous=false"]
                                                                                method:@"POST"
                                                                               payload:@{
                                                                                       @"contactFieldId": @3,
                                                                                       @"contactFieldValue": @"test@test.com"
                                                                               }
                                                                               headers:nil
                                                                                extras:nil];

    EMSRequestModel *requestModel = [self.requestFactory createContactRequestModel];

    XCTAssertEqualObjects(requestModel, expectedRequestModel);
}

- (void)testCreateContactRequestModel_when_ApplicationCode_isNil {
    EMSRequestModel *result = [self.requestFactory createContactRequestModel];

    XCTAssertNil(result);
}

- (void)testCreateContactRequestModel_whenContactFieldValueIsNil {
    OCMStub([self.mockRequestContext contactFieldId]).andReturn(@3);
    OCMStub([self.mockRequestContext hasContactIdentification]).andReturn(YES);
    OCMStub(self.mockRequestContext.applicationCode).andReturn(@"testApplicationCode");

    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:@"requestId"
                                                                             timestamp:self.timestamp
                                                                                expiry:FLT_MAX
                                                                                   url:[[NSURL alloc] initWithString:@"https://me-client.eservice.emarsys.net/v3/apps/testApplicationCode/client/contact?anonymous=false"]
                                                                                method:@"POST"
                                                                               payload:@{
                                                                                       @"contactFieldId": @3,
                                                                               }
                                                                               headers:nil
                                                                                extras:nil];

    EMSRequestModel *requestModel = [self.requestFactory createContactRequestModel];

    XCTAssertEqualObjects(requestModel, expectedRequestModel);
}

- (void)testCreateContactRequestModel_when_contactFieldValueIsNil {
    OCMStub([self.mockRequestContext contactFieldValue]).andReturn(nil);
    OCMStub(self.mockRequestContext.applicationCode).andReturn(@"testApplicationCode");

    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:@"requestId"
                                                                             timestamp:self.timestamp
                                                                                expiry:FLT_MAX
                                                                                   url:[[NSURL alloc] initWithString:@"https://me-client.eservice.emarsys.net/v3/apps/testApplicationCode/client/contact?anonymous=true"]
                                                                                method:@"POST"
                                                                               payload:@{}
                                                                               headers:nil
                                                                                extras:nil];

    EMSRequestModel *requestModel = [self.requestFactory createContactRequestModel];

    XCTAssertEqualObjects(requestModel, expectedRequestModel);
}

- (void)testCreateEventRequestModel_with_eventName_eventAttributes_internalType {
    OCMStub(self.mockRequestContext.applicationCode).andReturn(@"testApplicationCode");

    self.sessionIdHolder.sessionId = @"testSessionId";

    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:@"requestId"
                                                                             timestamp:self.timestamp
                                                                                expiry:FLT_MAX
                                                                                   url:[[NSURL alloc] initWithString:@"https://mobile-events.eservice.emarsys.net/v3/apps/testApplicationCode/client/events"]
                                                                                method:@"POST"
                                                                               payload:@{
                                                                                       @"clicks": @[],
                                                                                       @"viewedMessages": @[],
                                                                                       @"events": @[
                                                                                               @{
                                                                                                       @"type": @"internal",
                                                                                                       @"name": @"testEventName",
                                                                                                       @"timestamp": [self.timestamp stringValueInUTC],
                                                                                                       @"attributes":
                                                                                                       @{
                                                                                                               @"testEventAttributeKey1": @"testEventAttributeValue1",
                                                                                                               @"testEventAttributeKey2": @"testEventAttributeValue2"
                                                                                                       },
                                                                                                       @"sessionId": @"testSessionId"
                                                                                               }
                                                                                       ]
                                                                               }
                                                                               headers:nil
                                                                                extras:nil];

    EMSRequestModel *requestModel = [self.requestFactory createEventRequestModelWithEventName:@"testEventName"
                                                                              eventAttributes:@{
                                                                                      @"testEventAttributeKey1": @"testEventAttributeValue1",
                                                                                      @"testEventAttributeKey2": @"testEventAttributeValue2"
                                                                              }
                                                                                    eventType:EventTypeInternal];

    XCTAssertEqualObjects(requestModel, expectedRequestModel);
}

- (void)testCreateEventRequestModel_when_ApplicationCode_isNil {
    EMSRequestModel *result = [self.requestFactory createEventRequestModelWithEventName:@"testEventName"
                                                                        eventAttributes:@{
                                                                                @"testEventAttributeKey1": @"testEventAttributeValue1",
                                                                                @"testEventAttributeKey2": @"testEventAttributeValue2"
                                                                        }
                                                                              eventType:EventTypeInternal];

    XCTAssertNil(result);
}

- (void)testCreateEventRequestModel_with_eventName_customType {
    OCMStub(self.mockRequestContext.applicationCode).andReturn(@"testApplicationCode");

    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:@"requestId"
                                                                             timestamp:self.timestamp
                                                                                expiry:FLT_MAX
                                                                                   url:[[NSURL alloc] initWithString:@"https://mobile-events.eservice.emarsys.net/v3/apps/testApplicationCode/client/events"]
                                                                                method:@"POST"
                                                                               payload:@{
                                                                                       @"clicks": @[],
                                                                                       @"viewedMessages": @[],
                                                                                       @"events": @[
                                                                                               @{
                                                                                                       @"type": @"custom",
                                                                                                       @"name": @"testEventName",
                                                                                                       @"timestamp": [self.timestamp stringValueInUTC]
                                                                                               }
                                                                                       ]
                                                                               }
                                                                               headers:nil
                                                                                extras:nil];

    EMSRequestModel *requestModel = [self.requestFactory createEventRequestModelWithEventName:@"testEventName"
                                                                              eventAttributes:nil
                                                                                    eventType:EventTypeCustom];

    XCTAssertEqualObjects(requestModel, expectedRequestModel);
}

- (void)testCreateRefreshTokenRequestModel {
    OCMStub(self.mockRequestContext.applicationCode).andReturn(@"testApplicationCode");
    [MEExperimental enableFeature:EMSInnerFeature.mobileEngage];

    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:@"requestId"
                                                                             timestamp:self.timestamp
                                                                                expiry:FLT_MAX
                                                                                   url:[[NSURL alloc] initWithString:@"https://me-client.eservice.emarsys.net/v3/apps/testApplicationCode/client/contact-token"]
                                                                                method:@"POST"
                                                                               payload:@{
                                                                                       @"refreshToken": @"testRefreshToken"
                                                                               }
                                                                               headers:nil
                                                                                extras:nil];

    EMSRequestModel *requestModel = [self.requestFactory createRefreshTokenRequestModel];

    XCTAssertEqualObjects(requestModel, expectedRequestModel);
    [MEExperimental reset];
}

- (void)testCreateRefreshTokenRequestModel_predictOnly {
    OCMStub(self.mockPredictRequestContext.merchantId).andReturn(@"testMerchantId");
    [MEExperimental enableFeature:EMSInnerFeature.predict];

    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:@"requestId"
                                                                             timestamp:self.timestamp
                                                                                expiry:FLT_MAX
                                                                                   url:[[NSURL alloc] initWithString:@"https://me-client.eservice.emarsys.net/v3/contact-token"]
                                                                                method:@"POST"
                                                                               payload:@{
                                                                                       @"refreshToken": @"testRefreshToken"
                                                                               }
                                                                               headers:nil
                                                                                extras:nil];

    EMSRequestModel *requestModel = [self.requestFactory createRefreshTokenRequestModel];

    XCTAssertEqualObjects(requestModel, expectedRequestModel);
    [MEExperimental reset];
}

- (void)testCreateRefreshTokenRequestModel_when_ApplicationCode_isNil {
    EMSRequestModel *result = [self.requestFactory createRefreshTokenRequestModel];

    XCTAssertNil(result);
}

- (void)testCreateDeepLinkRequestModel {
    NSString *const value = @"dl_value";
    NSString *userAgent = [NSString stringWithFormat:@"Emarsys SDK %@ %@ %@", EMARSYS_SDK_VERSION,
                                                     @"testDeviceType",
                                                     @"testOSVersion"];

    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:@"requestId"
                                                                             timestamp:self.timestamp
                                                                                expiry:FLT_MAX
                                                                                   url:[[NSURL alloc] initWithString:@"https://deep-link.eservice.emarsys.net/api/clicks"]
                                                                                method:@"POST"
                                                                               payload:@{@"ems_dl": value}
                                                                               headers:@{@"User-Agent": userAgent}
                                                                                extras:nil];

    EMSRequestModel *requestModel = [self.requestFactory createDeepLinkRequestModelWithTrackingId:value];

    XCTAssertEqualObjects(requestModel, expectedRequestModel);
}

- (void)testCreateGeofenceRequestModel {
    OCMStub(self.mockRequestContext.applicationCode).andReturn(@"testApplicationCode");

    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:@"requestId"
                                                                             timestamp:self.timestamp
                                                                                expiry:FLT_MAX
                                                                                   url:[[NSURL alloc] initWithString:@"https://me-client.eservice.emarsys.net/v3/apps/testApplicationCode/geo-fences"]
                                                                                method:@"GET"
                                                                               payload:nil
                                                                               headers:@{@"Authorization": [EMSAuthentication createBasicAuthWithUsername:@"testApplicationCode"]}
                                                                                extras:nil];

    EMSRequestModel *result = [self.requestFactory createGeofenceRequestModel];

    XCTAssertEqualObjects(result, expectedRequestModel);
}

- (void)testCreateGeofenceRequestModel_when_ApplicationCode_isNil {
    EMSRequestModel *result = [self.requestFactory createGeofenceRequestModel];

    XCTAssertNil(result);
}

- (void)testCreateMessageInboxRequestModel {
    OCMStub(self.mockRequestContext.applicationCode).andReturn(@"testApplicationCode");

    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:@"requestId"
                                                                             timestamp:self.timestamp
                                                                                expiry:FLT_MAX
                                                                                   url:[[NSURL alloc] initWithString:@"https://me-inbox.eservice.emarsys.net/v3/apps/testApplicationCode/inbox"]
                                                                                method:@"GET"
                                                                               payload:nil
                                                                               headers:@{@"Authorization": [EMSAuthentication createBasicAuthWithUsername:@"testApplicationCode"]}
                                                                                extras:nil];

    EMSRequestModel *result = [self.requestFactory createMessageInboxRequestModel];

    XCTAssertEqualObjects(result, expectedRequestModel);
}

- (void)testCreateMessageInboxRequestModel_when_ApplicationCode_isNil {
    EMSRequestModel *result = [self.requestFactory createMessageInboxRequestModel];

    XCTAssertNil(result);
}

- (void)testCreateInlineInappRequestModel_whenMobileEngageIsEnabled_andApplicationCodeIsSet {
    [MEExperimental enableFeature:EMSInnerFeature.mobileEngage];
    OCMStub(self.mockRequestContext.applicationCode).andReturn(@"testApplicationCode");

    NSArray<MEButtonClick *> *clicks = @[
            [[MEButtonClick alloc] initWithCampaignId:@"campaignID"
                                             buttonId:@"buttonID"
                                            timestamp:[NSDate date]],
            [[MEButtonClick alloc] initWithCampaignId:@"campaignID2"
                                             buttonId:@"buttonID2"
                                            timestamp:[NSDate date]]
    ];

    OCMStub([self.mockButtonClickRepository query:[OCMArg any]]).andReturn(clicks);

    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:@"requestId"
                                                                             timestamp:self.timestamp
                                                                                expiry:FLT_MAX
                                                                                   url:[[NSURL alloc] initWithString:@"https://mobile-events.eservice.emarsys.net/v3/apps/testApplicationCode/inline-messages"]
                                                                                method:@"POST"
                                                                               payload:@{
                                                                                       @"viewIds": @[
                                                                                               @"testViewId"
                                                                                       ],
                                                                                       @"clicks": @[
                                                                                               @{@"campaignId": [clicks[0] campaignId], @"buttonId": [clicks[0] buttonId], @"timestamp": [clicks[0] timestamp].stringValueInUTC},
                                                                                               @{@"campaignId": [clicks[1] campaignId], @"buttonId": [clicks[1] buttonId], @"timestamp": [clicks[1] timestamp].stringValueInUTC}
                                                                                       ]
                                                                               }
                                                                               headers:nil
                                                                                extras:nil];
    EMSRequestModel *result = [self.requestFactory createInlineInappRequestModelWithViewId:@"testViewId"];

    XCTAssertEqualObjects(result, expectedRequestModel);
}

- (void)testCreateInlineInappRequestModel_when_ApplicationCode_isNil {
    EMSRequestModel *result = [self.requestFactory createInlineInappRequestModelWithViewId:@"testViewId"];

    XCTAssertNil(result);
}

- (void)testCreateInlineInappRequestModel_when_MobileEngageIsDisabled_isNil {
    [MEExperimental disableFeature:EMSInnerFeature.mobileEngage];

    EMSRequestModel *result = [self.requestFactory createInlineInappRequestModelWithViewId:@"testViewId"];

    XCTAssertNil(result);
}

@end
