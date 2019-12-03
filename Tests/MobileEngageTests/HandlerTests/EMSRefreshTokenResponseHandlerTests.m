//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSRefreshTokenResponseHandler.h"
#import "MERequestContext.h"
#import "EMSUUIDProvider.h"
#import "EMSDeviceInfo.h"
#import "EMSAbstractResponseHandler+Private.h"
#import "EMSEndpoint.h"
#import "EMSValueProvider.h"

@interface EMSRefreshTokenResponseHandlerTests : XCTestCase

@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) EMSRefreshTokenResponseHandler *responseHandler;
@property(nonatomic, strong) NSString *applicationCode;
@property(nonatomic, strong) NSNumber *contactFieldId;

@end

@implementation EMSRefreshTokenResponseHandlerTests

- (void)setUp {
    _applicationCode = @"testApplicationCode";
    _contactFieldId = @3;
    _requestContext = [[MERequestContext alloc] initWithApplicationCode:self.applicationCode
                                                         contactFieldId:self.contactFieldId
                                                           uuidProvider:OCMClassMock([EMSUUIDProvider class])
                                                      timestampProvider:OCMClassMock([EMSTimestampProvider class])
                                                             deviceInfo:OCMClassMock([EMSDeviceInfo class])];

    EMSValueProvider *clientServiceUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://me-client.eservice.emarsys.net"
                                                                                       valueKey:@"CLIENT_SERVICE_URL"];
    EMSValueProvider *eventServiceUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://mobile-events.eservice.emarsys.net"
                                                                                      valueKey:@"EVENT_SERVICE_URL"];
    EMSEndpoint *endpoint = [[EMSEndpoint alloc] initWithClientServiceUrlProvider:clientServiceUrlProvider
                                                          eventServiceUrlProvider:eventServiceUrlProvider
                                                               predictUrlProvider:OCMClassMock([EMSValueProvider class])
                                                              deeplinkUrlProvider:OCMClassMock([EMSValueProvider class])
                                                        v2EventServiceUrlProvider:OCMClassMock([EMSValueProvider class])
                                                                 inboxUrlProvider:OCMClassMock([EMSValueProvider class])];

    _responseHandler = [[EMSRefreshTokenResponseHandler alloc] initWithRequestContext:self.requestContext
                                                                             endpoint:endpoint];
}

- (void)testInit_requestContext_mustNotBeNil {
    @try {
        [[EMSRefreshTokenResponseHandler alloc] initWithRequestContext:nil
                                                              endpoint:OCMClassMock([EMSEndpoint class])];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestContext");
    }
}

- (void)testInit_endpoint_mustNotBeNil {
    @try {
        [[EMSRefreshTokenResponseHandler alloc] initWithRequestContext:self.requestContext
                                                              endpoint:nil];
        XCTFail(@"Expected Exception when endpoint is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: endpoint");
    }
}

- (void)testShouldHandleResponse_shouldBeNO_whenMERequest_missingParsedBody {
    EMSResponseModel *mockResponseModel = [self createResponseModelWithUrl:@"https://ems-me-client.herokuapp.com/"
                                                                parsedBody:nil];

    BOOL result = [self.responseHandler shouldHandleResponse:mockResponseModel];

    XCTAssertFalse(result);
}

- (void)testShouldHandleResponse_shouldBeNO_whenMERequest_missingRefreshToken_withContactToken {
    EMSResponseModel *mockResponseModel = [self createResponseModelWithUrl:@"https://ems-me-client.herokuapp.com/"
                                                                parsedBody:@{@"contactToken": @"contactToken"}];

    BOOL result = [self.responseHandler shouldHandleResponse:mockResponseModel];

    XCTAssertFalse(result);
}

- (void)testShouldHandleResponse_shouldBeNO_whenNotMERequest_withRefreshTokenToken {
    EMSResponseModel *mockResponseModel = [self createResponseModelWithUrl:@"https://not.mobile-engage.com/"
                                                                parsedBody:@{@"refreshToken": @"token"}];

    BOOL result = [self.responseHandler shouldHandleResponse:mockResponseModel];

    XCTAssertFalse(result);
}

- (void)testShouldHandleResponse_shouldBeYES_whenMERequest_withRefreshTokenToken {
    EMSResponseModel *mockResponseModel = [self createResponseModelWithUrl:@"https://me-client.eservice.emarsys.net"
                                                                parsedBody:@{@"refreshToken": @"token"}];

    BOOL result = [self.responseHandler shouldHandleResponse:mockResponseModel];

    XCTAssertTrue(result);
}

- (void)testHandleResponse_shouldSetRefreshTokenOnRequestContext {
    EMSResponseModel *mockResponseModel = [self createResponseModelWithUrl:@"https://me-client.eservice.emarsys.net"
                                                                parsedBody:@{@"refreshToken": @"token"}];
    id mockRequestContext = OCMClassMock([MERequestContext class]);
    _responseHandler = [[EMSRefreshTokenResponseHandler alloc] initWithRequestContext:mockRequestContext
                                                                             endpoint:OCMClassMock([EMSEndpoint class])];

    [self.responseHandler handleResponse:mockResponseModel];

    OCMVerify([mockRequestContext setRefreshToken:@"token"]);

    [mockRequestContext stopMocking];
}

- (EMSResponseModel *)createResponseModelWithUrl:(NSString *)url
                                      parsedBody:(NSDictionary *)parsedBody {
    return [[EMSResponseModel alloc] initWithHttpUrlResponse:[[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:url]
                                                                                         statusCode:200
                                                                                        HTTPVersion:nil
                                                                                       headerFields:@{@"responseHeaderKey": @"responseHeaderValue"}]
                                                        data:parsedBody ? [NSJSONSerialization dataWithJSONObject:parsedBody
                                                                                                          options:NSJSONWritingPrettyPrinted
                                                                                                            error:nil] : nil
                                                requestModel:[EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                                                        [builder setUrl:url];
                                                    }
                                                                            timestampProvider:[EMSTimestampProvider new]
                                                                                 uuidProvider:[EMSUUIDProvider new]]
                                                   timestamp:[[EMSTimestampProvider new] provideTimestamp]];
}

@end
