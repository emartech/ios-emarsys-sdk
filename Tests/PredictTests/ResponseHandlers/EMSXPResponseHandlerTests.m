//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSXPResponseHandler.h"
#import <OCMock/OCMock.h>
#import "PRERequestContext.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSAbstractResponseHandler+Private.h"
#import "EMSEndpoint.h"
#import "EMSValueProvider.h"

@interface EMSXPResponseHandlerTests : XCTestCase

@property(nonatomic, strong) PRERequestContext *mockRequestContext;
@property(nonatomic, strong) EMSXPResponseHandler *responseHandler;

@end

@implementation EMSXPResponseHandlerTests

- (void)setUp {
    [super setUp];
    _mockRequestContext = OCMClassMock([PRERequestContext class]);

    EMSValueProvider *clientServiceUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://me-client.eservice.emarsys.net"
                                                                                       valueKey:@"CLIENT_SERVICE_URL"];
    EMSValueProvider *eventServiceUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://mobile-events.eservice.emarsys.net"
                                                                                      valueKey:@"EVENT_SERVICE_URL"];
    EMSValueProvider *predictUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://recommender.scarabresearch.com"
                                                                                 valueKey:@"PREDICT_URL"];
    EMSEndpoint *endpoint = [[EMSEndpoint alloc] initWithClientServiceUrlProvider:clientServiceUrlProvider
                                                          eventServiceUrlProvider:eventServiceUrlProvider
                                                               predictUrlProvider:predictUrlProvider
                                                              deeplinkUrlProvider:OCMClassMock([EMSValueProvider class])
                                                        v2EventServiceUrlProvider:OCMClassMock([EMSValueProvider class])
                                                                 inboxUrlProvider:OCMClassMock([EMSValueProvider class])];

    _responseHandler = [[EMSXPResponseHandler alloc] initWithRequestContext:self.mockRequestContext
                                                                   endpoint:endpoint]; 
}

- (void)testInit_requestContext_mustNotBeNil {
    @try {
        [[EMSXPResponseHandler alloc] initWithRequestContext:nil
                                                    endpoint:OCMClassMock([EMSEndpoint class])];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: requestContext"]);
    }
}

- (void)testInit_endpoint_mustNotBeNil {
    @try {
        [[EMSXPResponseHandler alloc] initWithRequestContext:self.mockRequestContext
                                                    endpoint:nil];
        XCTFail(@"Expected Exception when endpoint is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: endpoint"]);
    }
}

- (void)testShouldHandleResponse_shouldReturnNo_whenResponseHasNoXP {
    EMSResponseModel *responseModel = [self createResponseModelWithUrl:@"https://www.emarsys.com"
                                                           withHeaders:@{}];
    BOOL result = [self.responseHandler shouldHandleResponse:responseModel];
    XCTAssertFalse(result);
}

- (void)testShouldHandleResponse_shouldReturnYes_whenResponseHasXP {
    EMSResponseModel *responseModel = [self createResponseModelWithUrl:@"https://recommender.scarabresearch.com"
                                                           withHeaders:@{@"Set-Cookie": @"CDV=CDVVALUE;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT, s=SVALUE, xP=XPVALUE-1_JmYJ0idhLv23ebPQHuvQANK5aTUfzOBKf89-h;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT"}];
    BOOL result = [self.responseHandler shouldHandleResponse:responseModel];
    XCTAssertTrue(result);
}

- (void)testShouldHandleResponse_shouldReturnNo_whenUrlIsNotPredictUrl {
    EMSResponseModel *responseModel = [self createResponseModelWithUrl:@"https://www.emarsys.com"
                                                           withHeaders:@{@"Set-Cookie": @"CDV=CDVVALUE;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT, s=SVALUE, xP=XPVALUE-1_JmYJ0idhLv23ebPQHuvQANK5aTUfzOBKf89-h;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT"}];
    BOOL result = [self.responseHandler shouldHandleResponse:responseModel];
    XCTAssertFalse(result);
}

- (void)testShouldHandleResponse_shouldReturnNo_whenUrlIsPredictUrlButNoCookie {
    EMSResponseModel *responseModel = [self createResponseModelWithUrl:@"https://recommender.scarabresearch.com"
                                                           withHeaders:@{}];
    BOOL result = [self.responseHandler shouldHandleResponse:responseModel];
    XCTAssertFalse(result);
}

- (void)testHandleResponse_shouldSetCookieToRequestContext {
    EMSResponseModel *responseModel = [self createResponseModelWithUrl:@"https://www.emarsys.com"
                                                           withHeaders:@{@"Set-Cookie": @"CDV=CDVVALUE;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT, s=SVALUE, xP=XPVALUE-1_JmYJ0idhLv23ebPQHuvQANK5aTUfzOBKf89-h;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT"}];

    [self.responseHandler handleResponse:responseModel];
    OCMVerify([self.mockRequestContext setXp:@"XPVALUE-1_JmYJ0idhLv23ebPQHuvQANK5aTUfzOBKf89-h"]);
}

- (void)testHandleResponse_shouldSetCookieToRequestContext_whenHeaderKeyIsLowercase {
    EMSResponseModel *responseModel = [self createResponseModelWithUrl:@"https://www.emarsys.com"
                                                           withHeaders:@{@"set-cookie": @"CDV=CDVVALUE;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT, s=SVALUE, xP=XPVALUE-1_JmYJ0idhLv23ebPQHuvQANK5aTUfzOBKf89-h;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT"}];

    [self.responseHandler handleResponse:responseModel];
    OCMVerify([self.mockRequestContext setXp:@"XPVALUE-1_JmYJ0idhLv23ebPQHuvQANK5aTUfzOBKf89-h"]);
}


- (EMSResponseModel *)createResponseModelWithUrl:(NSString *)url withHeaders:(NSDictionary *)headers {
    EMSTimestampProvider *timestampProvider = [EMSTimestampProvider new];
    EMSUUIDProvider *uuidProvider = [EMSUUIDProvider new];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:url]
                                                              statusCode:200
                                                             HTTPVersion:@"1.1"
                                                            headerFields:headers];
    NSData *data = [@"dataString" dataUsingEncoding:NSUTF8StringEncoding];
    EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setUrl:url];
        }
                                                   timestampProvider:timestampProvider
                                                        uuidProvider:uuidProvider];
    return [[EMSResponseModel alloc] initWithHttpUrlResponse:response
                                                        data:data
                                                requestModel:requestModel
                                                   timestamp:[timestampProvider provideTimestamp]];
}


@end
