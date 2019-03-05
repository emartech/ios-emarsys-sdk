//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSV3Mapper.h"
#import "EMSRequestModel.h"
#import "EMSDeviceInfo.h"
#import "NSDate+EMSCore.h"

@interface EMSV3MapperTests : XCTestCase

@property(nonatomic, strong) NSString *requestId;
@property(nonatomic, strong) NSDate *timestamp;
@property(nonatomic, strong) NSURL *url;
@property(nonatomic, strong) NSString *httpMethod;
@property(nonatomic, strong) NSDictionary *payload;
@property(nonatomic, strong) NSDictionary *headers;
@property(nonatomic, strong) NSDictionary *extras;
@property(nonatomic, strong) EMSV3Mapper *mapper;
@property(nonatomic, strong) MERequestContext *mockRequestContext;
@property(nonatomic, strong) NSString *clientState;
@property(nonatomic, strong) NSDate *requestOrderTimestamp;
@property(nonatomic, strong) NSString *hardwareId;

@end

@implementation EMSV3MapperTests

- (void)setUp {
    _requestId = @"testRequestId";
    _timestamp = [NSDate date];
    _url = [[NSURL alloc] initWithString:@"https://www.emarsys.com/test/url"];
    _httpMethod = @"POST";
    _payload = @{@"testPayloadKey": @"testPayloadValue"};
    _clientState = @"testClientStateValue";
    _requestOrderTimestamp = [NSDate date];
    _headers = @{
        @"testHeaderKey": @"testHeaderValue"
    };
    _extras = @{@"testExtraKey": @"testExtraValue"};
    _hardwareId = @"testHardwareId";

    EMSTimestampProvider *mockTimestampProvider = OCMClassMock([EMSTimestampProvider class]);
    EMSDeviceInfo *mockDeviceInfo = OCMClassMock([EMSDeviceInfo class]);
    _mockRequestContext = OCMClassMock([MERequestContext class]);

    OCMStub([self.mockRequestContext timestampProvider]).andReturn(mockTimestampProvider);
    OCMStub([self.mockRequestContext deviceInfo]).andReturn(mockDeviceInfo);
    OCMStub([mockTimestampProvider provideTimestamp]).andReturn(self.requestOrderTimestamp);
    OCMStub([mockDeviceInfo hardwareId]).andReturn(self.hardwareId);

    _mapper = [[EMSV3Mapper alloc] initWithRequestContext:self.mockRequestContext];
}

- (void)testInit_requestContext_mustNotBeNull {
    @try {
        [[EMSV3Mapper alloc] initWithRequestContext:nil];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestContext");
    }
}

- (void)testShouldHandleWithRequestModel_when_missingRequestModel {
    XCTAssertFalse([self.mapper shouldHandleWithRequestModel:nil]);
}

- (void)testShouldHandleWithRequestModel_when_notV3Url {
    XCTAssertFalse([self.mapper shouldHandleWithRequestModel:[self createRequestModel]]);
}

- (void)testShouldHandleWithRequestModel_when_V3Url {
    _url = [[NSURL alloc] initWithString:@"https://ems-me-client.herokuapp.com"];

    XCTAssertTrue([self.mapper shouldHandleWithRequestModel:[self createRequestModel]]);
}

- (void)testModelFromModel_when_clientStateIsNil {
    _clientState = nil;
    NSMutableDictionary *mutableHeaders = [self.headers mutableCopy];
    mutableHeaders[@"X-Request-Order"] = [[self.requestOrderTimestamp numberValueInMillis] stringValue];
    mutableHeaders[@"X-Client-Id"] = self.hardwareId;
    NSDictionary *expectedHeaders = [NSDictionary dictionaryWithDictionary:mutableHeaders];

    EMSRequestModel *returnedModel = [self.mapper modelFromModel:[self createRequestModel]];

    _headers = expectedHeaders;

    XCTAssertEqualObjects(returnedModel, [self createRequestModel]);
}

- (void)testModelFromModel_when_clientStateIsNotNil {
    _clientState = nil;
    NSMutableDictionary *mutableHeaders = [self.headers mutableCopy];
    mutableHeaders[@"X-Request-Order"] = [[self.requestOrderTimestamp numberValueInMillis] stringValue];
    mutableHeaders[@"X-Client-Id"] = self.hardwareId;
    mutableHeaders[@"X-Client-State"] = self.clientState;
    NSDictionary *expectedHeaders = [NSDictionary dictionaryWithDictionary:mutableHeaders];

    EMSRequestModel *returnedModel = [self.mapper modelFromModel:[self createRequestModel]];

    _headers = expectedHeaders;

    XCTAssertEqualObjects(returnedModel, [self createRequestModel]);
}

- (EMSRequestModel *)createRequestModel {
    return [[EMSRequestModel alloc] initWithRequestId:self.requestId
                                            timestamp:self.timestamp
                                               expiry:FLT_MAX
                                                  url:self.url
                                               method:self.httpMethod
                                              payload:self.payload
                                              headers:self.headers
                                               extras:self.extras];
}

@end
