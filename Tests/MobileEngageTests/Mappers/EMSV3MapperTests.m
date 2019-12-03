//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSV3Mapper.h"
#import "EMSRequestModel.h"
#import "EMSDeviceInfo.h"
#import "NSDate+EMSCore.h"
#import "EMSEndpoint.h"

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
@property(nonatomic, strong) EMSEndpoint *mockEndpoint;

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
    _mockEndpoint = OCMClassMock([EMSEndpoint class]);

    OCMStub([self.mockRequestContext timestampProvider]).andReturn(mockTimestampProvider);
    OCMStub([self.mockRequestContext deviceInfo]).andReturn(mockDeviceInfo);
    OCMStub([mockTimestampProvider provideTimestamp]).andReturn(self.requestOrderTimestamp);
    OCMStub([mockDeviceInfo hardwareId]).andReturn(self.hardwareId);
    OCMStub([self.mockEndpoint clientServiceUrl]).andReturn(@"https://me-client.eservice.emarsys.net");
    OCMStub([self.mockEndpoint eventServiceUrl]).andReturn(@"https://mobile-events.eservice.emarsys.net");

    _mapper = [[EMSV3Mapper alloc] initWithRequestContext:self.mockRequestContext endpoint:self.mockEndpoint];
}

- (void)testInit_requestContext_mustNotBeNull {
    @try {
        [[EMSV3Mapper alloc] initWithRequestContext:nil endpoint:self.mockEndpoint];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestContext");
    }
}

- (void)testInit_endpoint_mustNotBeNull {
    @try {
        [[EMSV3Mapper alloc] initWithRequestContext:self.mockRequestContext
                                           endpoint:nil];
        XCTFail(@"Expected Exception when endpoint is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: endpoint");
    }
}

- (void)testShouldHandleWithRequestModel_when_missingRequestModel {
    XCTAssertFalse([self.mapper shouldHandleWithRequestModel:nil]);
}

- (void)testShouldHandleWithRequestModel_when_notV3Url {
    XCTAssertFalse([self.mapper shouldHandleWithRequestModel:[self createRequestModel]]);
}

- (void)testShouldHandleWithRequestModel_when_V3ClientUrl {
    _url = [[NSURL alloc] initWithString:@"https://me-client.eservice.emarsys.net"];

    XCTAssertTrue([self.mapper shouldHandleWithRequestModel:[self createRequestModel]]);
}

- (void)testShouldHandleWithRequestModel_when_V3EventUrl {
    _url = [[NSURL alloc] initWithString:@"https://mobile-events.eservice.emarsys.net"];

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
    OCMStub([self.mockRequestContext clientState]).andReturn(self.clientState);

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
