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

@interface EMSXPResponseHandlerTests : XCTestCase

@property(nonatomic, strong) PRERequestContext *mockRequestContext;

@end

@implementation EMSXPResponseHandlerTests

- (void)setUp {
    [super setUp];
    _mockRequestContext = OCMClassMock([PRERequestContext class]);
}


- (void)testInit_requestContext_mustNotBeNil {
    @try {
        [[EMSXPResponseHandler alloc] initWithRequestContext:nil];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: requestContext"]);
    }
}

- (void)testShouldHandleResponse_shouldReturnNo_whenResponseHasNoXP {
    EMSXPResponseHandler *responseHandler = [[EMSXPResponseHandler alloc] initWithRequestContext:self.mockRequestContext];
    EMSResponseModel *responseModel = [self createResponseModelWithUrl:@"https://www.emarsys.com"
                                                           withHeaders:@{}];
    BOOL result = [responseHandler shouldHandleResponse:responseModel];
    XCTAssertFalse(result);
}

- (void)testShouldHandleResponse_shouldReturnYes_whenResponseHasXP {
    EMSXPResponseHandler *responseHandler = [[EMSXPResponseHandler alloc] initWithRequestContext:self.mockRequestContext];
    EMSResponseModel *responseModel = [self createResponseModelWithUrl:@"https://recommender.scarabresearch.com"
                                                           withHeaders:@{@"Set-Cookie": @"CDV=CDVVALUE;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT, s=SVALUE, xP=XPVALUE-1_JmYJ0idhLv23ebPQHuvQANK5aTUfzOBKf89-h;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT"}];
    BOOL result = [responseHandler shouldHandleResponse:responseModel];
    XCTAssertTrue(result);
}

- (void)testShouldHandleResponse_shouldReturnNo_whenUrlIsNotPredictUrl {
    EMSXPResponseHandler *responseHandler = [[EMSXPResponseHandler alloc] initWithRequestContext:self.mockRequestContext];
    EMSResponseModel *responseModel = [self createResponseModelWithUrl:@"https://www.emarsys.com"
                                                           withHeaders:@{@"Set-Cookie": @"CDV=CDVVALUE;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT, s=SVALUE, xP=XPVALUE-1_JmYJ0idhLv23ebPQHuvQANK5aTUfzOBKf89-h;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT"}];
    BOOL result = [responseHandler shouldHandleResponse:responseModel];
    XCTAssertFalse(result);
}

- (void)testShouldHandleResponse_shouldReturnNo_whenUrlIsPredictUrlButNoCookie {
    EMSXPResponseHandler *responseHandler = [[EMSXPResponseHandler alloc] initWithRequestContext:self.mockRequestContext];
    EMSResponseModel *responseModel = [self createResponseModelWithUrl:@"https://recommender.scarabresearch.com"
                                                           withHeaders:@{}];
    BOOL result = [responseHandler shouldHandleResponse:responseModel];
    XCTAssertFalse(result);
}

- (void)testHandleResponse_shouldSetCookieToRequestContext {
    EMSXPResponseHandler *responseHandler = [[EMSXPResponseHandler alloc] initWithRequestContext:self.mockRequestContext];
    EMSResponseModel *responseModel = [self createResponseModelWithUrl:@"https://www.emarsys.com"
                                                           withHeaders:@{@"Set-Cookie": @"CDV=CDVVALUE;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT, s=SVALUE, xP=XPVALUE-1_JmYJ0idhLv23ebPQHuvQANK5aTUfzOBKf89-h;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT"}];

    [responseHandler handleResponse:responseModel];
    OCMVerify([self.mockRequestContext setXp:@"XPVALUE-1_JmYJ0idhLv23ebPQHuvQANK5aTUfzOBKf89-h"]);
}

- (void)testHandleResponse_shouldSetCookieToRequestContext_whenHeaderKeyIsLowercase {
    EMSXPResponseHandler *responseHandler = [[EMSXPResponseHandler alloc] initWithRequestContext:self.mockRequestContext];
    EMSResponseModel *responseModel = [self createResponseModelWithUrl:@"https://www.emarsys.com"
                                                           withHeaders:@{@"set-cookie": @"CDV=CDVVALUE;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT, s=SVALUE, xP=XPVALUE-1_JmYJ0idhLv23ebPQHuvQANK5aTUfzOBKf89-h;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT"}];

    [responseHandler handleResponse:responseModel];
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
