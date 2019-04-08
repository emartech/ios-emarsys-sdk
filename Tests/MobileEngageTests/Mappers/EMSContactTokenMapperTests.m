//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSContactTokenMapper.h"
#import "MERequestContext.h"
#import "EMSRequestModel.h"
#import "EMSUUIDProvider.h"

@interface EMSContactTokenMapperTests : XCTestCase

@property(nonatomic, readonly) MERequestContext *mockRequestContext;

@end

@implementation EMSContactTokenMapperTests

- (void)setUp {
    _mockRequestContext = OCMClassMock([MERequestContext class]);
}

- (void)testInit_requestContext_mustNotBeNull {
    @try {
        [[EMSContactTokenMapper alloc] initWithRequestContext:nil];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestContext");
    }
}

- (void)testShouldHandleWithRequestModel_true_whenRequestIsMobileEngage_clientService {
    EMSContactTokenMapper *contactTokenMapper = [[EMSContactTokenMapper alloc] initWithRequestContext:self.mockRequestContext];
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub(mockRequestModel.url).andReturn([[NSURL alloc] initWithString:@"https://me-client.eservice.emarsys.net"]);

    BOOL result = [contactTokenMapper shouldHandleWithRequestModel:mockRequestModel];

    XCTAssertTrue(result);
}

- (void)testShouldHandleWithRequestModel_true_whenRequestIsMobileEngage_eventService {
    EMSContactTokenMapper *contactTokenMapper = [[EMSContactTokenMapper alloc] initWithRequestContext:self.mockRequestContext];
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub(mockRequestModel.url).andReturn([[NSURL alloc] initWithString:@"https://mobile-events.eservice.emarsys.net"]);

    BOOL result = [contactTokenMapper shouldHandleWithRequestModel:mockRequestModel];

    XCTAssertTrue(result);
}

- (void)testShouldHandleWithRequestModel_false_whenRequestIsContactToken {
    EMSContactTokenMapper *contactTokenMapper = [[EMSContactTokenMapper alloc] initWithRequestContext:self.mockRequestContext];
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub(mockRequestModel.url).andReturn([[NSURL alloc] initWithString:@"https://mobile-events.eservice.emarsys.net/v3/12345/client/contact-token"]);

    BOOL result = [contactTokenMapper shouldHandleWithRequestModel:mockRequestModel];

    XCTAssertFalse(result);
}


- (void)testModelFromModel_when_contactTokenIsNotNil {
    NSString *testContactToken = @"testContactToken";
    NSString *requestId = @"requestId";
    NSDate *timestamp = [NSDate date];

    EMSUUIDProvider *mockUUIDProvider = OCMClassMock([EMSUUIDProvider class]);
    EMSTimestampProvider *mockTimestampProvider = OCMClassMock([EMSTimestampProvider class]);

    OCMStub([mockUUIDProvider provideUUIDString]).andReturn(requestId);
    OCMStub([mockTimestampProvider provideTimestamp]).andReturn(timestamp);
    OCMStub([self.mockRequestContext contactToken]).andReturn(testContactToken);
    OCMStub([self.mockRequestContext timestampProvider]).andReturn(mockTimestampProvider);
    OCMStub([self.mockRequestContext uuidProvider]).andReturn(mockUUIDProvider);
    OCMStub([self.mockRequestContext uuidProvider]).andReturn(mockUUIDProvider);

    EMSContactTokenMapper *contactTokenMapper = [[EMSContactTokenMapper alloc] initWithRequestContext:self.mockRequestContext];

    EMSRequestModel *inputRequestModel = [[EMSRequestModel alloc] initWithRequestId:requestId
                                                                          timestamp:timestamp
                                                                             expiry:FLT_MAX
                                                                                url:[[NSURL alloc] initWithString:@"https://ems-me-client.herokuapp.com"]
                                                                             method:@"POST"
                                                                            payload:nil
                                                                            headers:@{@"testHeaderName": @"testHeaderValue"}
                                                                             extras:nil];
    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:requestId
                                                                             timestamp:timestamp
                                                                                expiry:FLT_MAX
                                                                                   url:[[NSURL alloc] initWithString:@"https://ems-me-client.herokuapp.com"]
                                                                                method:@"POST"
                                                                               payload:nil
                                                                               headers:@{
                                                                                   @"testHeaderName": @"testHeaderValue",
                                                                                   @"X-Contact-Token": testContactToken
                                                                               }
                                                                                extras:nil];

    EMSRequestModel *returnedModel = [contactTokenMapper modelFromModel:inputRequestModel];

    XCTAssertEqualObjects(returnedModel, expectedRequestModel);
}

@end
