//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSContactTokenResponseHandler.h"
#import "MERequestContext.h"
#import "EMSUUIDProvider.h"
#import "EMSDeviceInfo.h"
#import "EMSEndpoint.h"
#import "EMSValueProvider.h"
#import "EMSAbstractResponseHandler+Private.h"

@interface EMSContactTokenResponseHandlerTests : XCTestCase

@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) EMSContactTokenResponseHandler *responseHandler;
@property(nonatomic, strong) NSString *applicationCode;
@property(nonatomic, strong) NSNumber *contactFieldId;
@end

@implementation EMSContactTokenResponseHandlerTests

- (void)setUp {
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


    _applicationCode = @"testApplicationCode";
    _contactFieldId = @3;
    _requestContext = [[MERequestContext alloc] initWithApplicationCode:self.applicationCode
                                                         contactFieldId:self.contactFieldId
                                                           uuidProvider:OCMClassMock([EMSUUIDProvider class])
                                                      timestampProvider:OCMClassMock([EMSTimestampProvider class])
                                                             deviceInfo:OCMClassMock([EMSDeviceInfo class])];
    _responseHandler = [[EMSContactTokenResponseHandler alloc] initWithRequestContext:self.requestContext
                                                                             endpoint:endpoint];
}

- (void)testInit_requestContext_mustNotBeNil {
    @try {
        [[EMSContactTokenResponseHandler alloc] initWithRequestContext:nil
                                                              endpoint:OCMClassMock([EMSEndpoint class])];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestContext");
    }
}

- (void)testInit_endpoint_mustNotBeNil {
    @try {
        [[EMSContactTokenResponseHandler alloc] initWithRequestContext:self.requestContext
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

- (void)testShouldHandleResponse_shouldBeNO_whenMERequest_missingContactToken_withRefreshToken {
    EMSResponseModel *mockResponseModel = [self createResponseModelWithUrl:@"https://ems-me-client.herokuapp.com/"
                                                                parsedBody:@{@"refreshToken": @"refreshToken"}];

    BOOL result = [self.responseHandler shouldHandleResponse:mockResponseModel];

    XCTAssertFalse(result);
}

- (void)testShouldHandleResponse_shouldBeNO_whenNotMERequest_withContactToken {
    EMSResponseModel *mockResponseModel = [self createResponseModelWithUrl:@"https://not.mobile-engage.com/"
                                                                parsedBody:@{@"contactToken": @"token"}];

    BOOL result = [self.responseHandler shouldHandleResponse:mockResponseModel];

    XCTAssertFalse(result);
}

- (void)testShouldHandleResponse_shouldBeYES_whenMERequest_withContactToken {
    EMSResponseModel *mockResponseModel = [self createResponseModelWithUrl:@"https://me-client.eservice.emarsys.net"
                                                                parsedBody:@{@"contactToken": @"token"}];

    BOOL result = [self.responseHandler shouldHandleResponse:mockResponseModel];

    XCTAssertTrue(result);
}

- (void)testHandleResponse_shouldSetContactTokenOnRequestContext {
    EMSResponseModel *mockResponseModel = [self createResponseModelWithUrl:@"https://me-client.eservice.emarsys.net"
                                                                parsedBody:@{@"contactToken": @"token"}];
    MERequestContext *mockRequestContext = OCMClassMock([MERequestContext class]);
    _responseHandler = [[EMSContactTokenResponseHandler alloc] initWithRequestContext:mockRequestContext
                                                                             endpoint:OCMClassMock([EMSEndpoint class])];

    [self.responseHandler handleResponse:mockResponseModel];

    OCMVerify([mockRequestContext setContactToken:@"token"]);
}

- (EMSResponseModel *)createResponseModelWithUrl:(NSString *)url
                                      parsedBody:(NSDictionary *)parsedBody {
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    EMSResponseModel *mockResponseModel = OCMClassMock([EMSResponseModel class]);

    OCMStub([mockRequestModel url]).andReturn([[NSURL alloc] initWithString:url]);
    OCMStub([mockResponseModel requestModel]).andReturn(mockRequestModel);
    OCMStub([mockResponseModel parsedBody]).andReturn(parsedBody);

    return mockResponseModel;
}

@end
