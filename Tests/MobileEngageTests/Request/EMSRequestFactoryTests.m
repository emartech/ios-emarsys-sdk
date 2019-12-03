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
#import "EMSNotification.h"
#import "EMSEndpoint.h"
#import "EMSValueProvider.h"

@interface EMSRequestFactoryTests : XCTestCase

@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) MERequestContext *mockRequestContext;
@property(nonatomic, strong) EMSTimestampProvider *mockTimestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *mockUUIDProvider;
@property(nonatomic, strong) EMSDeviceInfo *mockDeviceInfo;
@property(nonatomic, strong) EMSEndpoint *endpoint;

@property(nonatomic, strong) NSDate *timestamp;

@end

@implementation EMSRequestFactoryTests

- (void)setUp {
    _mockRequestContext = OCMClassMock([MERequestContext class]);
    _mockTimestampProvider = OCMClassMock([EMSTimestampProvider class]);
    _mockUUIDProvider = OCMClassMock([EMSUUIDProvider class]);
    _mockDeviceInfo = OCMClassMock([EMSDeviceInfo class]);
    EMSValueProvider *clientServiceUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://me-client.eservice.emarsys.net"
                                                                                       valueKey:@"CLIENT_SERVICE_URL"];
    EMSValueProvider *eventServiceUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://mobile-events.eservice.emarsys.net"
                                                                                      valueKey:@"EVENT_SERVICE_URL"];
    EMSValueProvider *deeplinkUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://deep-link.eservice.emarsys.net/api/clicks"
                                                                                  valueKey:@"DEEPLINK_URL"];
    EMSValueProvider *v2EventServiceUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open"
                                                                                        valueKey:@"V2_EVENT_SERVICE_URL"];

    _endpoint = [[EMSEndpoint alloc] initWithClientServiceUrlProvider:clientServiceUrlProvider
                                              eventServiceUrlProvider:eventServiceUrlProvider
                                                   predictUrlProvider:OCMClassMock([EMSValueProvider class])
                                                  deeplinkUrlProvider:deeplinkUrlProvider
                                            v2EventServiceUrlProvider:v2EventServiceUrlProvider
                                                     inboxUrlProvider:OCMClassMock([EMSValueProvider class])];

    _timestamp = [NSDate date];

    OCMStub(self.mockRequestContext.timestampProvider).andReturn(self.mockTimestampProvider);
    OCMStub(self.mockRequestContext.deviceInfo).andReturn(self.mockDeviceInfo);
    OCMStub(self.mockRequestContext.uuidProvider).andReturn(self.mockUUIDProvider);
    OCMStub(self.mockRequestContext.refreshToken).andReturn(@"testRefreshToken");
    OCMStub(self.mockRequestContext.applicationCode).andReturn(@"testApplicationCode");

    OCMStub(self.mockTimestampProvider.provideTimestamp).andReturn(self.timestamp);
    OCMStub(self.mockUUIDProvider.provideUUIDString).andReturn(@"requestId");
    OCMStub(self.mockDeviceInfo.hardwareId).andReturn(@"hardwareId");
    OCMStub(self.mockDeviceInfo.deviceType).andReturn(@"testDeviceType");
    OCMStub(self.mockDeviceInfo.osVersion).andReturn(@"testOSVersion");

    _requestFactory = [[EMSRequestFactory alloc] initWithRequestContext:self.mockRequestContext
                                                               endpoint:self.endpoint];
}

- (void)testInit_requestContext_mustNotBeNil {
    @try {
        [[EMSRequestFactory alloc] initWithRequestContext:nil
                                                 endpoint:OCMClassMock([EMSEndpoint class])];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: requestContext"]);
    }
}

- (void)testInit_endpoint_mustNotBeNil {
    @try {
        [[EMSRequestFactory alloc] initWithRequestContext:self.mockRequestContext
                                                 endpoint:nil];
        XCTFail(@"Expected Exception when endpoint is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: endpoint"]);
    }
}

- (void)testCreateDeviceInfoRequestModel {
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

- (void)testCreatePushTokenRequestModelWithPushToken {
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

- (void)testClearCreatePushTokenRequestModelWithPushToken {
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

- (void)testCreateContactRequestModel {
    OCMStub([self.mockRequestContext contactFieldId]).andReturn(@3);
    OCMStub([self.mockRequestContext contactFieldValue]).andReturn(@"test@test.com");

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

- (void)testCreateContactRequestModel_when_contactFieldValueIsNil {
    OCMStub([self.mockRequestContext contactFieldValue]).andReturn(nil);

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
                                                                                           }
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

- (void)testCreateEventRequestModel_with_eventName_customType {
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

- (void)testCreateMessageOpenWithNotification {
    EMSNotification *notification = [[EMSNotification alloc] initWithNotificationDictionary:@{
        @"sid": @"testSID"
    }];

    OCMStub(self.mockRequestContext.contactFieldId).andReturn(@"testContactFieldId");
    OCMStub(self.mockRequestContext.contactFieldValue).andReturn(@"testContactFieldValue");

    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:@"requestId"
                                                                             timestamp:self.timestamp
                                                                                expiry:FLT_MAX
                                                                                   url:[[NSURL alloc] initWithString:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open"]
                                                                                method:@"POST"
                                                                               payload:@{
                                                                                   @"application_id": @"testApplicationCode",
                                                                                   @"hardware_id": @"hardwareId",
                                                                                   @"sid": @"testSID",
                                                                                   @"source": @"inbox",
                                                                                   @"contact_field_id": @"testContactFieldId",
                                                                                   @"contact_field_value": @"testContactFieldValue"
                                                                               }
                                                                               headers:@{@"Authorization": [EMSAuthentication createBasicAuthWithUsername:@"testApplicationCode"]}
                                                                                extras:nil];

    EMSRequestModel *requestModel = [self.requestFactory createMessageOpenWithNotification:notification];

    XCTAssertEqualObjects(requestModel, expectedRequestModel);
}

@end