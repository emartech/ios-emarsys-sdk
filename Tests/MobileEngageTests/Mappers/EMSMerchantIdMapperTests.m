//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSMerchantIdMapper.h"
#import "PRERequestContext.h"
#import "EMSRequestModel.h"
#import "EMSUUIDProvider.h"
#import "EMSEndpoint.h"
#import "EMSValueProvider.h"

@interface EMSMerchantIdMapperTests : XCTestCase

@property(nonatomic, readonly) PRERequestContext *mockRequestContext;
@property(nonatomic, readonly) EMSMerchantIdMapper *merchantIdMapper;
@property(nonatomic, readonly) EMSEndpoint *endpoint;

@end

@implementation EMSMerchantIdMapperTests

- (void)setUp {
    _mockRequestContext = OCMClassMock([PRERequestContext class]);
    OCMStub(self.mockRequestContext.merchantId).andReturn(@"testMerchantId");
    EMSValueProvider *clientServiceUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://me-client.eservice.emarsys.net"
                                                                                       valueKey:@"CLIENT_SERVICE_URL"];
    EMSValueProvider *eventServiceUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://mobile-events.eservice.emarsys.net"
                                                                                      valueKey:@"EVENT_SERVICE_URL"];
    EMSValueProvider *predictUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://recommender.scarabresearch.com"
                                                                                 valueKey:@"PREDICT_URL"];
    EMSValueProvider *v3MessageInboxUrlProdider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://me-inbox.eservice.emarsys.net"
                                                                                        valueKey:@"V3_MESSAGE_INBOX_URL"];

    _endpoint = [[EMSEndpoint alloc] initWithClientServiceUrlProvider:clientServiceUrlProvider
                                                          eventServiceUrlProvider:eventServiceUrlProvider
                                                               predictUrlProvider:predictUrlProvider
                                                              deeplinkUrlProvider:OCMClassMock([EMSValueProvider class])
                                                        v3MessageInboxUrlProvider:v3MessageInboxUrlProdider];

    _merchantIdMapper = [[EMSMerchantIdMapper alloc] initWithRequestContext:self.mockRequestContext
                                                                       endpoint:_endpoint];
}

- (void)testInit_requestContext_mustNotBeNull {
    @try {
        [[EMSMerchantIdMapper alloc] initWithRequestContext:nil
                                                     endpoint:OCMClassMock([EMSEndpoint class])];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestContext");
    }
}

- (void)testInit_endpoint_mustNotBeNull {
    @try {
        [[EMSMerchantIdMapper alloc] initWithRequestContext:self.mockRequestContext
                                                     endpoint:nil];
        XCTFail(@"Expected Exception when endpoint is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: endpoint");
    }
}

- (void)testShouldHandleWithRequestModel_true_whenRequestIsMobileEngage_clientService_setContactEndpoint {
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub(mockRequestModel.url).andReturn([[NSURL alloc] initWithString:@"https://me-client.eservice.emarsys.net/v3/apps/12345/client/contact?anonymous=false"]);

    BOOL result = [self.merchantIdMapper shouldHandleWithRequestModel:mockRequestModel];

    XCTAssertTrue(result);
}

- (void)testShouldHandleWithRequestModel_true_whenRequestIsMobileEngage_clientService_refreshContactTokenEndpoint {
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub(mockRequestModel.url).andReturn([[NSURL alloc] initWithString:@"https://me-client.eservice.emarsys.net/v3/apps/12345/client/contact-token"]);

    BOOL result = [self.merchantIdMapper shouldHandleWithRequestModel:mockRequestModel];

    XCTAssertTrue(result);
}

- (void)testShouldHandleWithRequestModel_true_whenRequestIsMobileEngage_clientService_predictOnlySetContactEndpoint {
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub(mockRequestModel.url).andReturn([[NSURL alloc] initWithString:@"https://me-client.eservice.emarsys.net/v3/contact-token"]);

    BOOL result = [self.merchantIdMapper shouldHandleWithRequestModel:mockRequestModel];

    XCTAssertTrue(result);
}

- (void)testShouldHandleWithRequestModel_false_whenRequestIsMobileEngage_clientService_notMappedEndpoint {
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub(mockRequestModel.url).andReturn([[NSURL alloc] initWithString:@"https://me-client.eservice.emarsys.net/v3/apps/12345/client"]);

    BOOL result = [self.merchantIdMapper shouldHandleWithRequestModel:mockRequestModel];

    XCTAssertFalse(result);
}

- (void)testShouldHandleWithRequestModel_false_whenRequestIsNotMobileEngage_clientService {
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub(mockRequestModel.url).andReturn([[NSURL alloc] initWithString:@"https://me-device-event.eservice.emarsys.net"]);

    BOOL result = [self.merchantIdMapper shouldHandleWithRequestModel:mockRequestModel];

    XCTAssertFalse(result);
}

- (void)testShouldHandleWithRequestModel_false_whenMerchantIdIsNil {
    PRERequestContext *mockRequestContextWithoutMerchantId = OCMClassMock([PRERequestContext class]);
    OCMStub(mockRequestContextWithoutMerchantId.merchantId).andReturn(nil);
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub(mockRequestModel.url).andReturn([[NSURL alloc] initWithString:@"https://me-client.eservice.emarsys.net/v3/apps/12345/client/contact-token"]);
    
    EMSMerchantIdMapper *merchantIdMapperWithoutMerchantId = [[EMSMerchantIdMapper alloc] initWithRequestContext:mockRequestContextWithoutMerchantId endpoint:_endpoint];

    BOOL result = [merchantIdMapperWithoutMerchantId shouldHandleWithRequestModel:mockRequestModel];

    XCTAssertFalse(result);
}



- (void)testModelFromModel_when_contactTokenIsNotNil {
    NSString *testMerchantId = @"testMerchantId";
    NSString *testUrl = @"https://me-client.eservice.emarsys.net/v3/apps/12345/client/contact-token";
    NSString *requestId = @"requestId";
    NSDate *timestamp = [NSDate date];
    OCMStub([self.mockRequestContext merchantId]).andReturn(testMerchantId);

    EMSRequestModel *inputRequestModel = [[EMSRequestModel alloc] initWithRequestId:requestId
                                                                          timestamp:timestamp
                                                                             expiry:FLT_MAX
                                                                                url:[[NSURL alloc] initWithString:testUrl]
                                                                             method:@"POST"
                                                                            payload:nil
                                                                            headers:@{@"testHeaderName": @"testHeaderValue"}
                                                                             extras:nil];
    
    
    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:requestId
                                                                             timestamp:timestamp
                                                                                expiry:FLT_MAX
                                                                                   url:[[NSURL alloc] initWithString:testUrl]
                                                                                method:@"POST"
                                                                               payload:nil
                                                                               headers:@{
                                                                                   @"testHeaderName": @"testHeaderValue",
                                                                                   @"X-Merchant-Id": testMerchantId
                                                                               }
                                                                                extras:nil];

    EMSRequestModel *returnedModel = [self.merchantIdMapper modelFromModel:inputRequestModel];

    XCTAssertEqualObjects(returnedModel, expectedRequestModel);
}

@end
