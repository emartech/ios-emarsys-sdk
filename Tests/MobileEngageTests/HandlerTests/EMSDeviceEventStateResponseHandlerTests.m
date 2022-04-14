//
//  Copyright © 2021 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSDeviceEventStateResponseHandler.h"
#import "EMSAbstractResponseHandler+Private.h"
#import "MEExperimental+Test.h"
#import "EMSInnerFeature.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSStorage.h"
#import "EMSEndpoint.h"
#import "EMSStorageProtocol.h"

@interface EMSDeviceEventStateResponseHandlerTests : XCTestCase

@property(nonatomic, strong) EMSStorage *mockStorage;
@property(nonatomic, strong) EMSEndpoint *mockEndpoint;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) EMSDeviceEventStateResponseHandler *responseHandler;

@end

@implementation EMSDeviceEventStateResponseHandlerTests

- (void)setUp {
    _mockStorage = OCMClassMock([EMSStorage class]);
    _mockEndpoint = OCMClassMock([EMSEndpoint class]);

    _responseHandler = [[EMSDeviceEventStateResponseHandler alloc] initWithStorage:self.mockStorage
                                                                          endpoint:self.mockEndpoint];

    _timestampProvider = [EMSTimestampProvider new];
}

- (void)tearDown {
    [MEExperimental reset];
}

- (void)testInit_storage_mustNotBeNil {
    @try {
        [[EMSDeviceEventStateResponseHandler alloc] initWithStorage:nil
                                                           endpoint:self.mockEndpoint];
        XCTFail(@"Expected Exception when storage is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: storage");
    }
}

- (void)testInit_endpoint_mustNotBeNil {
    @try {
        [[EMSDeviceEventStateResponseHandler alloc] initWithStorage:self.mockStorage
                                                           endpoint:nil];
        XCTFail(@"Expected Exception when endpoint is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: endpoint");
    }
}

- (void)testShouldHandleResponse_shouldBeNo_whenV4IsEnabled_butResponseIsNotSuccess {
    [MEExperimental enableFeature:EMSInnerFeature.eventServiceV4];
    OCMStub([self.mockEndpoint isMobileEngageUrl:[OCMArg any]]).andReturn(YES);

    NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"oldCampaigns": @[@1234, @56789]}
                                                   options:0
                                                     error:nil];
    EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:300
                                                                      headers:@{}
                                                                         body:body
                                                                   parsedBody:nil
                                                                 requestModel:[self createRequestModelWithPayload:@{}]
                                                                    timestamp:[NSDate date]];

    XCTAssertFalse([self.responseHandler shouldHandleResponse:response]);
}
- (void)testShouldHandleResponse_shouldBeNo_whenV4IsEnabled_butAndNotMobileEngageEndpoint {
    [MEExperimental enableFeature:EMSInnerFeature.eventServiceV4];
    OCMStub([self.mockEndpoint isMobileEngageUrl:[OCMArg any]]).andReturn(NO);

    NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"oldCampaigns": @[@1234, @56789]}
                                                   options:0
                                                     error:nil];
    EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                      headers:@{}
                                                                         body:body
                                                                   parsedBody:nil
                                                                 requestModel:[self createRequestModelWithPayload:@{}]
                                                                    timestamp:[NSDate date]];

    XCTAssertFalse([self.responseHandler shouldHandleResponse:response]);
}

- (void)testShouldHandleResponse_shouldBeNo_whenV4IsEnabled_andDeviceEventStateIsOmitted {
    [MEExperimental enableFeature:EMSInnerFeature.eventServiceV4];
    OCMStub([self.mockEndpoint isMobileEngageUrl:[OCMArg any]]).andReturn(YES);

    NSData *body = [NSJSONSerialization dataWithJSONObject:@{}
                                                   options:0
                                                     error:nil];
    EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                      headers:@{}
                                                                         body:body
                                                                   parsedBody:nil
                                                                 requestModel:[self createRequestModelWithPayload:@{}]
                                                                    timestamp:[NSDate date]];

    XCTAssertFalse([self.responseHandler shouldHandleResponse:response]);
}

- (void)testShouldHandleResponse_shouldBeNo_whenV4IsEnabled_andDeviceEventStateIsEmpty {
    [MEExperimental enableFeature:EMSInnerFeature.eventServiceV4];
    OCMStub([self.mockEndpoint isMobileEngageUrl:[OCMArg any]]).andReturn(YES);

    NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"deviceEventState": @[@{}]}
                                                   options:0
                                                     error:nil];
    EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                      headers:@{}
                                                                         body:body
                                                                   parsedBody:nil
                                                                 requestModel:[self createRequestModelWithPayload:@{}]
                                                                    timestamp:[NSDate date]];

    XCTAssertTrue([self.responseHandler shouldHandleResponse:response]);
}

- (void)testHandleResponse_shouldStoreDeviceEventState {
    [MEExperimental enableFeature:EMSInnerFeature.eventServiceV4];
    OCMStub([self.mockEndpoint isMobileEngageUrl:[OCMArg any]]).andReturn(YES);
    NSDictionary *deviceEventState = @{@"aaaa": @"bbbbb"};

    NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"deviceEventState": deviceEventState}
                                                   options:0
                                                     error:nil];
    EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                      headers:@{}
                                                                         body:body
                                                                   parsedBody:nil
                                                                 requestModel:[self createRequestModelWithPayload:@{}]
                                                                    timestamp:[NSDate date]];
    [self.responseHandler handleResponse:response];

    OCMVerify([self.mockStorage setDictionary:deviceEventState
                                       forKey:@"DEVICE_EVENT_STATE_KEY"]);
}


- (EMSRequestModel *)createRequestModelWithPayload:(NSDictionary *)payload {
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"https://www.test.url.com/com/test/url"];
                [builder setPayload:payload];
            }
                          timestampProvider:self.timestampProvider
                               uuidProvider:[EMSUUIDProvider new]];
}


@end
