//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Kiwi/NSObject+KiwiStubAdditions.h>
#import "EMSClientStateResponseHandler.h"
#import "EMSAbstractResponseHandler+Private.h"
#import "EMSUUIDProvider.h"
#import "EMSDeviceInfo.h"

@interface EMSClientStateResponseHandlerTests : XCTestCase

@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) EMSClientStateResponseHandler *responseHandler;
@property(nonatomic, strong) NSString *applicationCode;
@property(nonatomic, strong) NSNumber *contactFieldId;

@end

@implementation EMSClientStateResponseHandlerTests

- (void)setUp {
    _applicationCode = @"testApplicationCode";
    _contactFieldId = @3;
    _requestContext = [[MERequestContext alloc] initWithApplicationCode:self.applicationCode
                                                         contactFieldId:self.contactFieldId
                                                           uuidProvider:OCMClassMock([EMSUUIDProvider class])
                                                      timestampProvider:OCMClassMock([EMSTimestampProvider class])
                                                             deviceInfo:OCMClassMock([EMSDeviceInfo class])];

    _responseHandler = [[EMSClientStateResponseHandler alloc] initWithRequestContext:self.requestContext];
}

- (void)testInit_requestContext_mustNotBeNull {
    @try {
        [[EMSClientStateResponseHandler alloc] initWithRequestContext:nil];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestContext");
    }
}

- (void)testShouldHandleResponse {
    BOOL shouldHandle = [self.responseHandler shouldHandleResponse:[self createResponseModelWithHeaders:@{@"X-Client-State": @"TEST-CLIENT-STATE-VALUE"}]];

    XCTAssertTrue(shouldHandle);
}

- (void)testShouldHandleResponse_shouldReturnFalse_whenRequestIsNotMobileEngage {
    BOOL shouldHandle = [self.responseHandler shouldHandleResponse:[self createResponseModelWithHeaders:@{@"X-Client-State": @"TEST-CLIENT-STATE-VALUE"}
                                                                                                    url:[[NSURL alloc] initWithString:@"https://not-ems-me-client.herokuapp.com/"]]];

    XCTAssertFalse(shouldHandle);
}

- (void)testShouldHandleResponse_shouldReturnFalse_whenClientStateIsNotPresent {
    BOOL shouldHandle = [self.responseHandler shouldHandleResponse:[self createResponseModelWithHeaders:nil]];

    XCTAssertFalse(shouldHandle);
}

- (void)testShouldHandleResponse_shouldReturnFalse_whenUrlIsNotPresent {
    BOOL shouldHandle = [self.responseHandler shouldHandleResponse:[self createResponseModelWithHeaders:@{@"X-Client-State": @"TEST-CLIENT-STATE-VALUE"}
                                                                                                    url:nil]];
    XCTAssertFalse(shouldHandle);
}

- (void)testHandleResponse {
    [self.responseHandler handleResponse:[self createResponseModelWithHeaders:@{@"X-Client-State": @"TEST-CLIENT-STATE-VALUE"}]];

    XCTAssertEqualObjects(self.requestContext.clientState, @"TEST-CLIENT-STATE-VALUE");
}

- (EMSResponseModel *)createResponseModelWithHeaders:(NSDictionary<NSString *, NSString *> *)headers {
    return [self createResponseModelWithHeaders:headers
                                            url:[[NSURL alloc] initWithString:@"https://me-client.eservice.emarsys.net"]];
}

- (EMSResponseModel *)createResponseModelWithHeaders:(NSDictionary<NSString *, NSString *> *)headers
                                                 url:(NSURL *)url {
    EMSRequestModel *requestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([requestModel url]).andReturn(url);
    return [[EMSResponseModel alloc] initWithStatusCode:200
                                                headers:headers
                                                   body:nil
                                           requestModel:requestModel
                                              timestamp:[NSDate date]];
}

@end
