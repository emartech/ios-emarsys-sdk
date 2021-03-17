//
//  Copyright © 2021 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSIdTokenMapper.h"
#import "EMSEndpoint.h"
#import "MERequestContext.h"
#import "EMSRequestModel.h"
#import "EMSValueProvider.h"
#import "EMSUUIDProvider.h"

@interface EMSIdTokenMapperTests : XCTestCase

@property(nonatomic, strong) EMSEndpoint *endpoint;
@property(nonatomic, strong) MERequestContext *mockRequestContext;
@property(nonatomic, strong) EMSIdTokenMapper *idTokenMapper;

@end

@implementation EMSIdTokenMapperTests

- (void)setUp {
    EMSValueProvider *clientServiceUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://me-client.eservice.emarsys.net"
                                                                                       valueKey:@"CLIENT_SERVICE_URL"];
    EMSValueProvider *eventServiceUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://mobile-events.eservice.emarsys.net"
                                                                                      valueKey:@"EVENT_SERVICE_URL"];
    EMSValueProvider *v3MessageInboxUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://me-inbox.eservice.emarsys.net"
                                                                                        valueKey:@"V3_MESSAGE_INBOX_URL"];

    _endpoint = [[EMSEndpoint alloc] initWithClientServiceUrlProvider:clientServiceUrlProvider
                                              eventServiceUrlProvider:eventServiceUrlProvider
                                                   predictUrlProvider:OCMClassMock([EMSValueProvider class])
                                                  deeplinkUrlProvider:OCMClassMock([EMSValueProvider class])
                                            v2EventServiceUrlProvider:OCMClassMock([EMSValueProvider class])
                                                     inboxUrlProvider:OCMClassMock([EMSValueProvider class])
                                            v3MessageInboxUrlProvider:v3MessageInboxUrlProvider];
    _mockRequestContext = OCMClassMock([MERequestContext class]);
    _idTokenMapper = [[EMSIdTokenMapper alloc] initWithRequestContext:self.mockRequestContext
                                                             endpoint:self.endpoint];
}

- (void)tearDown {
}

- (void)testInit_requestContext_mustNotBeNull {
    @try {
        [[EMSIdTokenMapper alloc] initWithRequestContext:nil
                                                endpoint:self.endpoint];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestContext");
    }
}

- (void)testInit_endpoint_mustNotBeNull {
    @try {
        [[EMSIdTokenMapper alloc] initWithRequestContext:self.mockRequestContext
                                                endpoint:nil];
        XCTFail(@"Expected Exception when endpoint is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: endpoint");
    }
}

- (void)testShouldHandleWithRequestModel_NO_whenRequestIs_somethingElse {
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);

    OCMStub(mockRequestModel.url).andReturn([[NSURL alloc] initWithString:@"https://test.test.com/test/com"]);

    BOOL result = [self.idTokenMapper shouldHandleWithRequestModel:mockRequestModel];

    XCTAssertFalse(result);
}

- (void)testShouldHandleWithRequestModel_NO_whenRequestIsMobileEngageURL_eventService {
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);

    OCMStub(mockRequestModel.url).andReturn([[NSURL alloc] initWithString:@"https://mobile-events.eservice.emarsys.net/apps/EMS11-C3FD3/events"]);

    BOOL result = [self.idTokenMapper shouldHandleWithRequestModel:mockRequestModel];

    XCTAssertFalse(result);
}

- (void)testShouldHandleWithRequestModel_NO_whenRequestIsMobileEngageURL_notContactEndpoint {
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);

    OCMStub(mockRequestModel.url).andReturn([[NSURL alloc] initWithString:@"https://me-client.eservice.emarsys.net/apps/EMS11-C3FD3/client/NotContactService"]);

    BOOL result = [self.idTokenMapper shouldHandleWithRequestModel:mockRequestModel];

    XCTAssertFalse(result);
}

- (void)testShouldHandleWithRequestModel_YES_whenRequestIsMobileEngageURL_contactEndpoint {
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);

    OCMStub(mockRequestModel.url).andReturn([[NSURL alloc] initWithString:@"https://me-client.eservice.emarsys.net/apps/EMS11-C3FD3/client/contact/anonymous=true"]);

    BOOL result = [self.idTokenMapper shouldHandleWithRequestModel:mockRequestModel];

    XCTAssertTrue(result);
}

- (void)testModelFromModel_when_contactTokenIsNotNil {
    NSString *testIdToken = @"testIdToken";
    NSString *requestId = @"requestId";
    NSDate *timestamp = [NSDate date];

    EMSUUIDProvider *mockUUIDProvider = OCMClassMock([EMSUUIDProvider class]);
    EMSTimestampProvider *mockTimestampProvider = OCMClassMock([EMSTimestampProvider class]);

    OCMStub([mockUUIDProvider provideUUIDString]).andReturn(requestId);
    OCMStub([mockTimestampProvider provideTimestamp]).andReturn(timestamp);
    OCMStub([self.mockRequestContext idToken]).andReturn(testIdToken);
    OCMStub([self.mockRequestContext timestampProvider]).andReturn(mockTimestampProvider);
    OCMStub([self.mockRequestContext uuidProvider]).andReturn(mockUUIDProvider);
    OCMStub([self.mockRequestContext uuidProvider]).andReturn(mockUUIDProvider);

    EMSRequestModel *inputRequestModel = [[EMSRequestModel alloc] initWithRequestId:requestId
                                                                          timestamp:timestamp
                                                                             expiry:FLT_MAX
                                                                                url:[[NSURL alloc] initWithString:@"https://me-client.eservice.emarsys.net/apps/EMS11-C3FD3/client/contact"]
                                                                             method:@"POST"
                                                                            payload:nil
                                                                            headers:@{@"testHeaderName": @"testHeaderValue"}
                                                                             extras:nil];
    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:requestId
                                                                             timestamp:timestamp
                                                                                expiry:FLT_MAX
                                                                                   url:[[NSURL alloc] initWithString:@"https://me-client.eservice.emarsys.net/apps/EMS11-C3FD3/client/contact"]
                                                                                method:@"POST"
                                                                               payload:@{@"openIdToken": testIdToken}
                                                                               headers:@{
                                                                                       @"testHeaderName": @"testHeaderValue"
                                                                               }
                                                                                extras:nil];

    EMSRequestModel *returnedModel = [self.idTokenMapper modelFromModel:inputRequestModel];

    XCTAssertEqualObjects(returnedModel, expectedRequestModel);
}

@end
