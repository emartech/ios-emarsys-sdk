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

@interface EMSRefreshTokenResponseHandlerTests : XCTestCase

@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) EMSRefreshTokenResponseHandler *responseHandler;

@end

@implementation EMSRefreshTokenResponseHandlerTests

- (void)setUp {
    _requestContext = [[MERequestContext alloc] initWithConfig:OCMClassMock([EMSConfig class])
                                                  uuidProvider:OCMClassMock([EMSUUIDProvider class])
                                             timestampProvider:OCMClassMock([EMSTimestampProvider class])
                                                    deviceInfo:OCMClassMock([EMSDeviceInfo class])];
    _responseHandler = [[EMSRefreshTokenResponseHandler alloc] initWithRequestContext:self.requestContext];
}

- (void)testInit_requestContext_mustNotBeNil {
    @try {
        [[EMSRefreshTokenResponseHandler alloc] initWithRequestContext:nil];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestContext");
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
    MERequestContext *mockRequestContext = OCMClassMock([MERequestContext class]);
    _responseHandler = [[EMSRefreshTokenResponseHandler alloc] initWithRequestContext:mockRequestContext];

    [self.responseHandler handleResponse:mockResponseModel];

    OCMVerify([mockRequestContext setRefreshToken:@"token"]);
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
