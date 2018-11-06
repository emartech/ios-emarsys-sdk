//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSCompletionMiddleware.h"
#import "EMSResponseModel.h"
#import "EMSWaiter.h"
#import "NSError+EMSCore.h"

SPEC_BEGIN(EMSCompletionMiddlewareTests)

        beforeAll(^{
        });

        afterAll(^{
        });

        EMSRequestModel *(^createRequestModel)(NSString *requestModelId) = ^EMSRequestModel *(NSString *requestModelId) {
            return [[EMSRequestModel alloc] initWithRequestId:requestModelId
                                                    timestamp:[NSDate date]
                                                       expiry:1.0
                                                          url:[NSURL URLWithString:@"https://www.emarsys.com"]
                                                       method:@"GET"
                                                      payload:nil
                                                      headers:nil
                                                       extras:nil];
        };

        describe(@"initWithSuccessBlock:errorBlock:", ^{

            it(@"should throw exception when successBlock is nil", ^{
                @try {
                    [[EMSCompletionMiddleware alloc] initWithSuccessBlock:nil
                                                               errorBlock:^(NSString *requestId, NSError *error) {
                                                               }];
                    fail(@"Expected Exception when successBlock is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: successBlock"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when errorBlock is nil", ^{
                @try {
                    [[EMSCompletionMiddleware alloc] initWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                            }
                                                               errorBlock:nil];
                    fail(@"Expected Exception when errorBlock is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: errorBlock"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should set successBlock property", ^{
                EMSCompletionMiddleware *middleware = [[EMSCompletionMiddleware alloc] initWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                        }
                                                                                                 errorBlock:^(NSString *requestId, NSError *error) {
                                                                                                 }];
                [[middleware.successBlock shouldNot] beNil];

            });

            it(@"should set errorBlock property", ^{
                EMSCompletionMiddleware *middleware = [[EMSCompletionMiddleware alloc] initWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                        }
                                                                                                 errorBlock:^(NSString *requestId, NSError *error) {
                                                                                                 }];
                [[middleware.errorBlock shouldNot] beNil];

            });

            it(@"should invoke successBlock when calling injected successBlock", ^{
                NSString *expectedRequestId = @"requestId";
                EMSResponseModel *expectedResponseModel = [EMSResponseModel mock];

                __block NSString *returnedRequestId;
                __block EMSResponseModel *returnedResponseModel;
                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                EMSCompletionMiddleware *middleware = [[EMSCompletionMiddleware alloc] initWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                            returnedRequestId = requestId;
                            returnedResponseModel = response;
                            [expectation fulfill];
                        }
                                                                                                 errorBlock:^(NSString *requestId, NSError *error) {
                                                                                                 }];

                middleware.successBlock(expectedRequestId, expectedResponseModel);

                [EMSWaiter waitForExpectations:@[expectation]
                                       timeout:5.0];

                [[returnedRequestId should] equal:expectedRequestId];
                [[returnedResponseModel should] equal:expectedResponseModel];
            });

            it(@"should invoke successBlock on main thread", ^{
                __block NSOperationQueue *queue;
                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                EMSCompletionMiddleware *middleware = [[EMSCompletionMiddleware alloc] initWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                        }
                                                                                                 errorBlock:^(NSString *requestId, NSError *error) {
                                                                                                 }];
                [middleware registerCompletionBlock:^(NSError *error) {
                    [expectation fulfill];
                    queue = [NSOperationQueue currentQueue];
                }                   forRequestModel:createRequestModel(@"requestId")];
                [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
                    middleware.successBlock(@"requestId", [EMSResponseModel mock]);
                }];

                [EMSWaiter waitForExpectations:@[expectation]
                                       timeout:5.0];
                [[queue should] equal:[NSOperationQueue mainQueue]];
            });


            it(@"should invoke errorBlock on main thread", ^{
                __block NSOperationQueue *queue;
                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                EMSCompletionMiddleware *middleware = [[EMSCompletionMiddleware alloc] initWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                        }
                                                                                                 errorBlock:^(NSString *requestId, NSError *error) {
                                                                                                 }];
                [middleware registerCompletionBlock:^(NSError *error) {
                    [expectation fulfill];
                    queue = [NSOperationQueue currentQueue];
                }                   forRequestModel:createRequestModel(@"requestId")];

                [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
                    middleware.errorBlock(@"requestId", [NSError errorWithCode:42 localizedDescription:@"test error"]);
                }];

                [EMSWaiter waitForExpectations:@[expectation]
                                       timeout:5.0];
                [[queue should] equal:[NSOperationQueue mainQueue]];
            });

            it(@"should invoke errorBlock when calling injected errorBlock", ^{
                NSString *expectedRequestId = @"requestId";
                NSError *expectedError = [NSError errorWithCode:42 localizedDescription:@"test error"];

                __block NSString *returnedRequestId;
                __block NSError *returnedError;
                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                EMSCompletionMiddleware *middleware = [[EMSCompletionMiddleware alloc] initWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                        }
                                                                                                 errorBlock:^(NSString *requestId, NSError *error) {
                                                                                                     returnedRequestId = requestId;
                                                                                                     returnedError = error;
                                                                                                     [expectation fulfill];
                                                                                                 }];

                middleware.errorBlock(expectedRequestId, expectedError);

                [EMSWaiter waitForExpectations:@[expectation]
                                       timeout:5.0];

                [[returnedRequestId should] equal:expectedRequestId];
                [[returnedError should] equal:expectedError];
            });
        });

        describe(@"registerCompletionBlock:forRequestModel:", ^{

            it(@"should invoke registered completionBlock when successBlock called with the registered requestModel id", ^{
                __block NSError *returnedError = [NSError mock];

                EMSRequestModel *requestModel = createRequestModel(@"requestModelId");

                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                EMSCompletionMiddleware *middleware = [[EMSCompletionMiddleware alloc] initWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                        }
                                                                                                 errorBlock:^(NSString *requestId, NSError *error) {
                                                                                                 }];

                [middleware registerCompletionBlock:^(NSError *error) {
                            returnedError = error;
                            [expectation fulfill];
                        }
                                    forRequestModel:requestModel];

                middleware.successBlock(@"requestModelId", [EMSResponseModel mock]);

                [EMSWaiter waitForExpectations:@[expectation]
                                       timeout:5.0];

                [[returnedError should] beNil];
            });

            it(@"should invoke registered completionBlock when errorBlock called with the registered requestModel id", ^{
                NSError *expectedError = [NSError mock];
                __block NSError *returnedError;

                EMSRequestModel *requestModel = createRequestModel(@"requestModelId");

                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                EMSCompletionMiddleware *middleware = [[EMSCompletionMiddleware alloc] initWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                        }
                                                                                                 errorBlock:^(NSString *requestId, NSError *error) {
                                                                                                 }];

                [middleware registerCompletionBlock:^(NSError *error) {
                            returnedError = error;
                            [expectation fulfill];
                        }
                                    forRequestModel:requestModel];

                middleware.errorBlock(@"requestModelId", expectedError);

                [EMSWaiter waitForExpectations:@[expectation]
                                       timeout:5.0];

                [[returnedError should] equal:expectedError];
            });

            it(@"should invoke registered completionBlocks when errorBlock or successBlock are called with the registered requestModel id", ^{
                NSError *expectedError1 = [NSError mock];
                NSError *expectedError2 = [NSError mock];
                NSError *expectedError3 = [NSError mock];
                NSError *expectedError4 = [NSError mock];
                __block NSError *returnedError1;
                __block NSError *returnedError2;
                __block NSError *returnedError3;
                __block NSError *returnedError4;

                EMSRequestModel *requestModel1 = createRequestModel(@"requestModelId1");
                EMSRequestModel *requestModel2 = createRequestModel(@"requestModelId2");
                EMSRequestModel *requestModel3 = createRequestModel(@"requestModelId3");
                EMSRequestModel *requestModel4 = createRequestModel(@"requestModelId4");

                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [expectation setExpectedFulfillmentCount:4];
                EMSCompletionMiddleware *middleware = [[EMSCompletionMiddleware alloc] initWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                        }
                                                                                                 errorBlock:^(NSString *requestId, NSError *error) {
                                                                                                 }];

                [middleware registerCompletionBlock:^(NSError *error) {
                            returnedError1 = error;
                            [expectation fulfill];
                        }
                                    forRequestModel:requestModel1];
                [middleware registerCompletionBlock:^(NSError *error) {
                            returnedError2 = error;
                            [expectation fulfill];
                        }
                                    forRequestModel:requestModel2];
                [middleware registerCompletionBlock:^(NSError *error) {
                            returnedError3 = error;
                            [expectation fulfill];
                        }
                                    forRequestModel:requestModel3];
                [middleware registerCompletionBlock:^(NSError *error) {
                            returnedError4 = error;
                            [expectation fulfill];
                        }
                                    forRequestModel:requestModel4];

                middleware.errorBlock(@"requestModelId1", expectedError1);
                middleware.successBlock(@"requestModelId2", [EMSResponseModel mock]);
                middleware.errorBlock(@"requestModelId3", expectedError3);
                middleware.successBlock(@"requestModelId4", [EMSResponseModel mock]);

                [EMSWaiter waitForExpectations:@[expectation]
                                       timeout:5.0];

                [[returnedError1 should] equal:expectedError1];
                [[returnedError2 should] beNil];
                [[returnedError3 should] equal:expectedError3];
                [[returnedError4 should] beNil];
            });

            it(@"should not invoke registered completionBlock for requestId if it was already called in error", ^{
                EMSRequestModel *requestModel1 = createRequestModel(@"requestModelId1");

                XCTestExpectation *completionBlockCall = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [completionBlockCall setExpectedFulfillmentCount:2];
                EMSCompletionMiddleware *middleware = [[EMSCompletionMiddleware alloc] initWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                        }
                                                                                                 errorBlock:^(NSString *requestId, NSError *error) {
                                                                                                 }];

                [middleware registerCompletionBlock:^(NSError *error) {
                            [completionBlockCall fulfill];
                        }
                                    forRequestModel:requestModel1];

                middleware.errorBlock(@"requestModelId1", [NSError mock]);
                middleware.successBlock(@"requestModelId1", [EMSResponseModel mock]);
                [[theValue([XCTWaiter waitForExpectations:@[completionBlockCall]
                                                  timeout:1.0]) should] equal:theValue(XCTWaiterResultTimedOut)];
            });

            it(@"should not invoke registered completionBlock for requestId if it was already called in success", ^{
                EMSRequestModel *requestModel1 = createRequestModel(@"requestModelId1");

                XCTestExpectation *completionBlockCall = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [completionBlockCall setExpectedFulfillmentCount:2];
                EMSCompletionMiddleware *middleware = [[EMSCompletionMiddleware alloc] initWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                        }
                                                                                                 errorBlock:^(NSString *requestId, NSError *error) {
                                                                                                 }];

                [middleware registerCompletionBlock:^(NSError *error) {
                            [completionBlockCall fulfill];
                        }
                                    forRequestModel:requestModel1];

                middleware.successBlock(@"requestModelId1", [EMSResponseModel mock]);
                middleware.errorBlock(@"requestModelId1", [NSError mock]);
                [[theValue([XCTWaiter waitForExpectations:@[completionBlockCall]
                                                  timeout:1.0]) should] equal:theValue(XCTWaiterResultTimedOut)];
            });
        });

SPEC_END
