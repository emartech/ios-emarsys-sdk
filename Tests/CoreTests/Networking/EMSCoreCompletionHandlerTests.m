//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSCoreCompletionHandler.h"
#import "EMSRequestModelBuilder.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSRequestModel.h"
#import "EMSResponseModel.h"
#import "EMSWaiter.h"
#import "NSError+EMSCore.h"
#import "EMSCompositeRequestModel.h";
#import "EMSRequestModel+RequestIds.h"

@interface EMSCoreCompletionHandlerTests : XCTestCase

@property(nonatomic, strong) EMSCoreCompletionHandler *coreCompletionHandler;
@property(nonatomic, strong) XCTestExpectation *successExpectation;
@property(nonatomic, strong) XCTestExpectation *errorExpectation;
@property(nonatomic, strong) NSDate *timestamp;
@property(nonatomic, strong) EMSRequestModel *expectedRequestModel;
@property(nonatomic, strong) NSData *data;
@property(nonatomic, strong) __block NSString *returnedRequestId;
@property(nonatomic, strong) __block EMSResponseModel *returnedResponseModel;
@property(nonatomic, strong) __block NSError *returnedError;

@end

@implementation EMSCoreCompletionHandlerTests

- (void)setUp {
    _timestamp = [NSDate date];
    _expectedRequestModel = [self generateRequestModel];
    _data = [self generateBodyData];

    _successExpectation = [[XCTestExpectation alloc] initWithDescription:@"waitForSuccessBlock"];
    _errorExpectation = [[XCTestExpectation alloc] initWithDescription:@"waitForErrorBlock"];
    __weak typeof(self) weakSelf = self;
    _coreCompletionHandler = [[EMSCoreCompletionHandler alloc] initWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
            _returnedRequestId = requestId;
            _returnedResponseModel = response;
            [weakSelf.successExpectation fulfill];
        }
                                                                         errorBlock:^(NSString *requestId, NSError *error) {
                                                                             _returnedRequestId = requestId;
                                                                             _returnedError = error;
                                                                             [weakSelf.errorExpectation fulfill];
                                                                         }];
}

- (void)testInit_successBlock_mustNotBeNull {
    @try {
        [[EMSCoreCompletionHandler alloc] initWithSuccessBlock:nil
                                                    errorBlock:^(NSString *requestId, NSError *error) {
                                                    }];
        XCTFail(@"Expected Exception when successBlock is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: successBlock");
    }
}

- (void)testInit_errorBlock_mustNotBeNull {
    @try {
        [[EMSCoreCompletionHandler alloc] initWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
            }
                                                    errorBlock:nil];
        XCTFail(@"Expected Exception when errorBlock is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: errorBlock");
    }
}

- (void)testCompletionBlock_requestModel_mustNotBeNull {
    @try {
        EMSResponseModel *expectedResponseModel = [self generateResponseWithRequestModel:self.expectedRequestModel
                                                                              statusCode:199];
        NSError *expectedError = [NSError errorWithCode:1234
                                   localizedDescription:@"testError"];

        self.coreCompletionHandler.completionBlock(nil, expectedResponseModel, expectedError);

        XCTFail(@"Expected Exception when requestModel is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestModel");
    }
}

- (void)testCompletionBlock_responseModel_mustNotBeNull {
    @try {
        NSError *expectedError = [NSError errorWithCode:1234
                                   localizedDescription:@"testError"];

        self.coreCompletionHandler.completionBlock([self generateRequestModel], nil, expectedError);

        XCTFail(@"Expected Exception when responseModel is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: responseModel");
    }
}

- (void)testCompletionBlock_shouldCallSuccessBlock {
    EMSResponseModel *expectedResponseModel = [self generateResponseWithRequestModel:self.expectedRequestModel
                                                                          statusCode:200];
    self.coreCompletionHandler.completionBlock(self.expectedRequestModel, expectedResponseModel, nil);

    [EMSWaiter waitForExpectations:@[self.successExpectation]
                           timeout:1];

    XCTAssertEqualObjects(self.expectedRequestModel.requestId, self.returnedRequestId);
    XCTAssertEqualObjects(expectedResponseModel, self.returnedResponseModel);
    XCTAssertNil(self.returnedError);
}

- (void)testCompletionBlock_shouldCallSuccessBlock_with_multipleRequestIds {
    [self.successExpectation setExpectedFulfillmentCount:3];

    EMSResponseModel *expectedResponseModel = [self generateResponseWithRequestModel:self.expectedRequestModel
                                                                          statusCode:200];
    EMSCompositeRequestModel *request = [EMSCompositeRequestModel new];
    [request setOriginalRequests:@[[self generateRequestModel], [self generateRequestModel], [self generateRequestModel]]];

    __block NSMutableArray *requestIds = [@[] mutableCopy];
    __weak typeof(self) weakSelf = self;
    _coreCompletionHandler = [[EMSCoreCompletionHandler alloc] initWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
            _returnedResponseModel = response;
            [requestIds addObject:requestId];
            [weakSelf.successExpectation fulfill];
        }
                                                                         errorBlock:^(NSString *requestId, NSError *error) {
                                                                         }];

    self.coreCompletionHandler.completionBlock((id) request, expectedResponseModel, nil);

    [EMSWaiter waitForExpectations:@[self.successExpectation]
                           timeout:1];

    XCTAssertEqualObjects([request requestIds], requestIds);
    XCTAssertEqualObjects(expectedResponseModel, self.returnedResponseModel);
    XCTAssertNil(self.returnedError);
}

- (void)testCompletionBlock_shouldCallErrorBlock_when_statusCodeIsGreaterThan299_andNoError {
    EMSResponseModel *expectedResponseModel = [self generateResponseWithRequestModel:self.expectedRequestModel
                                                                          statusCode:300];
    NSString *description = self.data ? [[NSString alloc] initWithData:self.data
                                                              encoding:NSUTF8StringEncoding] : @"Unknown error";
    NSError *expectedError = [NSError errorWithCode:@(300).intValue localizedDescription:description];

    self.coreCompletionHandler.completionBlock(self.expectedRequestModel, expectedResponseModel, nil);

    [EMSWaiter waitForExpectations:@[self.errorExpectation]
                           timeout:1];

    XCTAssertEqualObjects(self.expectedRequestModel.requestId, self.returnedRequestId);
    XCTAssertEqualObjects(expectedError, self.returnedError);
    XCTAssertNil(self.returnedResponseModel);
}


- (void)testCompletionBlock_shouldCallErrorBlock_with_multipleRequestIds {
    [self.errorExpectation setExpectedFulfillmentCount:3];

    EMSResponseModel *expectedResponseModel = [self generateResponseWithRequestModel:self.expectedRequestModel
                                                                          statusCode:199];
    NSError *expectedError = [NSError errorWithCode:1234
                               localizedDescription:@"testError"];

    EMSCompositeRequestModel *request = [EMSCompositeRequestModel new];
    [request setOriginalRequests:@[[self generateRequestModel], [self generateRequestModel], [self generateRequestModel]]];

    __block NSMutableArray *requestIds = [@[] mutableCopy];
    __weak typeof(self) weakSelf = self;
    _coreCompletionHandler = [[EMSCoreCompletionHandler alloc] initWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
        }
                                                                         errorBlock:^(NSString *requestId, NSError *error) {
                                                                             _returnedError = error;
                                                                             [requestIds addObject:requestId];
                                                                             [weakSelf.errorExpectation fulfill];
                                                                         }];

    self.coreCompletionHandler.completionBlock((id) request, expectedResponseModel, expectedError);

    [EMSWaiter waitForExpectations:@[self.errorExpectation]
                           timeout:1];

    XCTAssertEqualObjects([request requestIds], requestIds);
    XCTAssertEqualObjects(expectedError, self.returnedError);
}

- (void)testCompletionBlock_shouldCallErrorBlock_when_statusCodeIsLessThan200_andNoError {
    EMSResponseModel *expectedResponseModel = [self generateResponseWithRequestModel:self.expectedRequestModel
                                                                          statusCode:199];
    NSString *description = self.data ? [[NSString alloc] initWithData:self.data
                                                              encoding:NSUTF8StringEncoding] : @"Unknown error";
    NSError *expectedError = [NSError errorWithCode:@(199).intValue localizedDescription:description];

    self.coreCompletionHandler.completionBlock(self.expectedRequestModel, expectedResponseModel, nil);

    [EMSWaiter waitForExpectations:@[self.errorExpectation]
                           timeout:1];

    XCTAssertEqualObjects(self.expectedRequestModel.requestId, self.returnedRequestId);
    XCTAssertEqualObjects(expectedError, self.returnedError);
    XCTAssertNil(self.returnedResponseModel);
}

- (void)testCompletionBlock_shouldCallErrorBlock_when_hasError {
    EMSResponseModel *expectedResponseModel = [self generateResponseWithRequestModel:self.expectedRequestModel
                                                                          statusCode:199];
    NSError *expectedError = [NSError errorWithCode:1234
                               localizedDescription:@"testError"];
    self.coreCompletionHandler.completionBlock(self.expectedRequestModel, expectedResponseModel, expectedError);

    [EMSWaiter waitForExpectations:@[self.errorExpectation]
                           timeout:1];

    XCTAssertEqualObjects(self.expectedRequestModel.requestId, self.returnedRequestId);
    XCTAssertEqualObjects(expectedError, self.returnedError);
    XCTAssertNil(self.returnedResponseModel);
}

- (EMSRequestModel *)generateRequestModel {
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setUrl:@"https://www.emarsys.com"];
            [builder setMethod:HTTPMethodPOST];
        }
                          timestampProvider:[EMSTimestampProvider new]
                               uuidProvider:[EMSUUIDProvider new]];
}

- (EMSResponseModel *)generateResponseWithRequestModel:(EMSRequestModel *)requestModel
                                            statusCode:(int)statusCode {
    return [[EMSResponseModel alloc] initWithHttpUrlResponse:[[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:@"https://www.emarsys.com"]
                                                                                         statusCode:statusCode
                                                                                        HTTPVersion:nil
                                                                                       headerFields:@{@"responseHeaderKey": @"responseHeaderValue"}]
                                                        data:self.data
                                                requestModel:requestModel
                                                   timestamp:self.timestamp];
}

- (NSData *)generateBodyData {
    return [NSJSONSerialization dataWithJSONObject:@{@"bodyKey": @"bodyValue"}
                                           options:NSJSONWritingPrettyPrinted
                                             error:nil];
}

@end
