//
//  Copyright © 2022 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MEExperimental+Test.h"
#import "EMSDeviceEventStateRequestMapper.h"
#import "EMSRequestModel.h"
#import "EMSEndpoint.h"
#import "EMSInnerFeature.h"
#import "EMSStorageProtocol.h"

#define kDeviceEventStateKey @"DEVICE_EVENT_STATE_KEY"

@interface EMSDeviceEventStateRequestMapperTests : XCTestCase

@property(nonatomic, strong) EMSDeviceEventStateRequestMapper *desRequestMapper;
@property(nonatomic, strong) EMSEndpoint *mockEndpoint;
@property(nonatomic, strong) id <EMSStorageProtocol> mockStorage;

@end

@implementation EMSDeviceEventStateRequestMapperTests

- (void)setUp {
    _mockEndpoint = OCMClassMock([EMSEndpoint class]);
    OCMStub([self.mockEndpoint clientServiceUrl]).andReturn(@"https://me-client.eservice.emarsys.net");
    OCMStub([self.mockEndpoint eventServiceUrl]).andReturn(@"https://mobile-events.eservice.emarsys.net");
    _mockStorage = OCMProtocolMock(@protocol(EMSStorageProtocol));
    _desRequestMapper = [[EMSDeviceEventStateRequestMapper alloc] initWithEndpoint:self.mockEndpoint
                                                                           storage:self.mockStorage];
}

- (void)tearDown {
    [MEExperimental reset];
}

- (void)testShouldHandle_shouldReturnYes_when_V4Enabled_and_customEventUrl_and_deviceEventStateExists {
    [MEExperimental enableFeature:EMSInnerFeature.eventServiceV4];

    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([mockRequestModel url]).andReturn(([[NSURL alloc] initWithString:@"thisIsAValidCustomEventUrl"]));
    OCMStub([self.mockEndpoint isCustomEventUrl:[OCMArg any]]).andReturn(YES);
    OCMStub([self.mockEndpoint isInlineInAppUrl:[OCMArg any]]).andReturn(NO);

    NSDictionary *deviceEventState = @{
            @"testDESKey": @"testDESValue"
    };
    OCMStub([self.mockStorage dictionaryForKey:kDeviceEventStateKey]).andReturn(deviceEventState);

    BOOL result = [self.desRequestMapper shouldHandleWithRequestModel:mockRequestModel];

    XCTAssertTrue(result);
}

- (void)testShouldHandle_shouldReturnYes_when_V4Enabled_and_inlineInAppUrl_and_deviceEventStateExists {
    [MEExperimental enableFeature:EMSInnerFeature.eventServiceV4];

    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([mockRequestModel url]).andReturn(([[NSURL alloc] initWithString:@"thisIsAValidCustomEventUrl"]));
    OCMStub([self.mockEndpoint isCustomEventUrl:[OCMArg any]]).andReturn(NO);
    OCMStub([self.mockEndpoint isInlineInAppUrl:[OCMArg any]]).andReturn(YES);

    NSDictionary *deviceEventState = @{
            @"testDESKey": @"testDESValue"
    };
    OCMStub([self.mockStorage dictionaryForKey:kDeviceEventStateKey]).andReturn(deviceEventState);


    BOOL result = [self.desRequestMapper shouldHandleWithRequestModel:mockRequestModel];

    XCTAssertTrue(result);
}

- (void)testShouldHandle_shouldReturnNo_when_V4IsNotEnabled {
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([mockRequestModel url]).andReturn(([[NSURL alloc] initWithString:@"thisIsAValidCustomEventUrl"]));
    OCMStub([self.mockEndpoint isCustomEventUrl:[OCMArg any]]).andReturn(NO);
    OCMStub([self.mockEndpoint isInlineInAppUrl:[OCMArg any]]).andReturn(YES);

    NSDictionary *deviceEventState = @{
            @"testDESKey": @"testDESValue"
    };
    OCMStub([self.mockStorage dictionaryForKey:kDeviceEventStateKey]).andReturn(deviceEventState);


    BOOL result = [self.desRequestMapper shouldHandleWithRequestModel:mockRequestModel];

    XCTAssertFalse(result);
}

- (void)testShouldHandle_shouldReturnNo_when_urlIsNotCustomEventOrInlineInApp {
    [MEExperimental enableFeature:EMSInnerFeature.eventServiceV4];

    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([mockRequestModel url]).andReturn(([[NSURL alloc] initWithString:@"thisIsAValidCustomEventUrl"]));
    OCMStub([self.mockEndpoint isCustomEventUrl:[OCMArg any]]).andReturn(NO);
    OCMStub([self.mockEndpoint isInlineInAppUrl:[OCMArg any]]).andReturn(NO);

    NSDictionary *deviceEventState = @{
            @"testDESKey": @"testDESValue"
    };
    OCMStub([self.mockStorage dictionaryForKey:kDeviceEventStateKey]).andReturn(deviceEventState);


    BOOL result = [self.desRequestMapper shouldHandleWithRequestModel:mockRequestModel];

    XCTAssertFalse(result);
}

- (void)testShouldHandle_shouldReturnNo_when_DES_isNotAvailable {
    [MEExperimental enableFeature:EMSInnerFeature.eventServiceV4];

    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([mockRequestModel url]).andReturn(([[NSURL alloc] initWithString:@"thisIsAValidCustomEventUrl"]));
    OCMStub([self.mockEndpoint isCustomEventUrl:[OCMArg any]]).andReturn(YES);
    OCMStub([self.mockEndpoint isInlineInAppUrl:[OCMArg any]]).andReturn(NO);

    OCMStub([self.mockStorage dictionaryForKey:kDeviceEventStateKey]).andReturn(nil);


    BOOL result = [self.desRequestMapper shouldHandleWithRequestModel:mockRequestModel];

    XCTAssertFalse(result);
}

- (void)testModelFromModel {
    NSDictionary *deviceEventState = @{
            @"testDESKey": @"testDESValue"
    };
    NSDate *timestamp = [NSDate date];
    EMSRequestModel *requestModel = [[EMSRequestModel alloc] initWithRequestId:@"testRequestID"
                                                                     timestamp:timestamp expiry:0
                                                                           url:[[NSURL alloc] initWithString:@"https://www.test.com/test"]
                                                                        method:@"POST"
                                                                       payload:@{
                                                                               @"testKey": @"testValue",
                                                                               @"testKey2": @{}
                                                                       }
                                                                       headers:@{}
                                                                        extras:@{}];
    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:@"testRequestID"
                                                                             timestamp:timestamp expiry:0
                                                                                   url:[[NSURL alloc] initWithString:@"https://www.test.com/test"]
                                                                                method:@"POST"
                                                                               payload:@{
                                                                                       @"testKey": @"testValue",
                                                                                       @"testKey2": @{},
                                                                                       @"deviceEventState": deviceEventState
                                                                               }
                                                                               headers:@{}
                                                                                extras:@{}];

    OCMStub([self.mockStorage dictionaryForKey:kDeviceEventStateKey]).andReturn(deviceEventState);

    EMSRequestModel *result = [self.desRequestMapper modelFromModel:requestModel];

    XCTAssertEqualObjects(result, expectedRequestModel);
}

@end
