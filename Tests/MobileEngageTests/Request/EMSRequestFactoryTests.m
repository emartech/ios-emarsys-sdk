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

@interface EMSRequestFactoryTests : XCTestCase
@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) MERequestContext *mockRequestContext;
@property(nonatomic, strong) EMSTimestampProvider *mockTimestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *mockUUIDProvider;
@property(nonatomic, strong) EMSDeviceInfo *mockDeviceInfo;
@property(nonatomic, strong) EMSConfig *mockConfig;

@property(nonatomic, strong) NSDate *timestamp;
@end

@implementation EMSRequestFactoryTests

- (void)setUp {
    _mockRequestContext = OCMClassMock([MERequestContext class]);
    _mockTimestampProvider = OCMClassMock([EMSTimestampProvider class]);
    _mockUUIDProvider = OCMClassMock([EMSUUIDProvider class]);
    _mockDeviceInfo = OCMClassMock([EMSDeviceInfo class]);
    _mockConfig = OCMClassMock([EMSConfig class]);

    _timestamp = [NSDate date];

    OCMStub(self.mockRequestContext.timestampProvider).andReturn(self.mockTimestampProvider);
    OCMStub(self.mockRequestContext.deviceInfo).andReturn(self.mockDeviceInfo);
    OCMStub(self.mockRequestContext.config).andReturn(self.mockConfig);
    OCMStub(self.mockRequestContext.uuidProvider).andReturn(self.mockUUIDProvider);
    OCMStub(self.mockTimestampProvider.provideTimestamp).andReturn(self.timestamp);
    OCMStub(self.mockUUIDProvider.provideUUIDString).andReturn(@"requestId");
    OCMStub(self.mockDeviceInfo.hardwareId).andReturn(@"hardwareId");
    OCMStub(self.mockConfig.applicationCode).andReturn(@"applicationCode");

    _requestFactory = [[EMSRequestFactory alloc] initWithRequestContext:self.mockRequestContext];
}

- (void)testInit_requestContext_mustNotBeNil {
    @try {
        [[EMSRequestFactory alloc] initWithRequestContext:nil];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: requestContext"]);
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
                                                                                   url:[[NSURL alloc] initWithString:@"https://ems-me-client.herokuapp.com/v3/apps/applicationCode/client"]
                                                                                method:@"POST"
                                                                               payload:payload
                                                                               headers:@{
                                                                                   @"X-Client-Id": @"hardwareId",
                                                                                   @"X-Request-Order": [self.timestamp.numberValueInMillis stringValue],
                                                                               }
                                                                                extras:nil];
    OCMStub(self.mockDeviceInfo.clientPayload).andReturn(payload);

    EMSRequestModel *requestModel = [self.requestFactory createDeviceInfoRequestModel];

    XCTAssertEqualObjects(expectedRequestModel, requestModel);
}

@end
