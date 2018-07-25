//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSResponseModel.h"
#import "TestUtils.h"
#import "EMSRESTClient.h"
#import "EMSRequestModelBuilder.h"
#import "NSURLRequest+EMSCore.h"
#import "NSError+EMSCore.h"
#import "EMSCompositeRequestModel.h"
#import "FakeLogRepository.h"
#import "EMSTimestampProvider.h"
#import "FakeTimeStampProvider.h"
#import "EMSUUIDProvider.h"

SPEC_BEGIN(EMSRESTClientTests)

        void (^successBlock)(NSString *, EMSResponseModel *) = ^(NSString *requestId, EMSResponseModel *response) {
        };
        void (^errorBlock)(NSString *, NSError *) = ^(NSString *requestId, NSError *error) {
        };

        id (^requestModel)(NSString *url, NSDictionary *payload) = ^id(NSString *url, NSDictionary *payload) {
            return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:url];
                [builder setMethod:HTTPMethodPOST];
                [builder setPayload:payload];
            }                     timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];
        };

        id (^compositeRequestModel)(NSString *url, NSDictionary *payload, NSArray<EMSRequestModel *> *originals) = ^id(NSString *url, NSDictionary *payload, NSArray<EMSRequestModel *> *originals) {
            EMSCompositeRequestModel *model = [EMSCompositeRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:url];
                [builder setMethod:HTTPMethodPOST];
                [builder setPayload:payload];
            }                                                         timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];
            model.originalRequests = originals;

            return model;
        };

        typedef void(^SessionMockBlock)(NSURLSession *session);
        void (^sessionMockWithCannedResponse)(EMSRequestModel *requestModel, int responseStatusCode, NSData *responseData, NSError *responseError, SessionMockBlock actionBlock) = ^(EMSRequestModel *requestModel, int responseStatusCode, NSData *responseData, NSError *responseError, SessionMockBlock actionBlock) {
            NSURLSession *sessionMock = [NSURLSession mock];
            NSURLResponse *urlResponse = [[NSHTTPURLResponse alloc] initWithURL:requestModel.url
                                                                     statusCode:responseStatusCode
                                                                    HTTPVersion:nil
                                                                   headerFields:nil];
            KWCaptureSpy *blockSpy = [sessionMock captureArgument:@selector(dataTaskWithRequest:completionHandler:)
                                                          atIndex:1];
            actionBlock(sessionMock);
            void (^onComplete)(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) = blockSpy.argument;
            onComplete(responseData, urlResponse, responseError);
        };

        describe(@"RESTClient", ^{

            FakeLogRepository *const fakeLogRepository = [FakeLogRepository new];
            id sessionMock = [NSURLSession mock];

            itShouldThrowException(@"should throw exception when successBlock is nil", ^{
                [EMSRESTClient clientWithSuccessBlock:nil
                                           errorBlock:errorBlock
                                        logRepository:fakeLogRepository];
            });

            itShouldThrowException(@"should throw exception when errorBlock is nil", ^{
                [EMSRESTClient clientWithSuccessBlock:successBlock
                                           errorBlock:nil
                                        logRepository:fakeLogRepository];
            });

            itShouldThrowException(@"should throw exception when timestampProvider is nil", ^{
                [EMSRESTClient clientWithSuccessBlock:successBlock
                                           errorBlock:errorBlock
                                              session:sessionMock
                                        logRepository:fakeLogRepository
                                    timestampProvider:nil];
            });

            itShouldThrowException(@"should throw exception when completionBlock is nil", ^{
                EMSRESTClient *client = [EMSRESTClient clientWithSuccessBlock:successBlock
                                                                   errorBlock:errorBlock
                                                                logRepository:fakeLogRepository];
                [client executeTaskWithOfflineCallbackStrategyWithRequestModel:requestModel(@"https://url1.com", nil)
                                                                    onComplete:nil];
            });

        });

        describe(@"executeTaskWithOfflineCallbackStrategyWithRequestModel", ^{


            it(@"should call dataTaskWithRequest:completionHandler: with the correct requestModel", ^{
                NSURLSession *sessionMock = [NSURLSession mock];

                EMSRequestModel *model = requestModel(@"https://url1.com", nil);

                EMSRESTClient *restClient = [EMSRESTClient clientWithSuccessBlock:successBlock errorBlock:errorBlock session:sessionMock logRepository:nil timestampProvider:[EMSTimestampProvider new]];
                KWCaptureSpy *sessionSpy = [sessionMock captureArgument:@selector(dataTaskWithRequest:completionHandler:)
                                                                atIndex:0];

                [restClient executeTaskWithOfflineCallbackStrategyWithRequestModel:model
                                                                        onComplete:^(BOOL shouldContinue) {

                                                                        }];

                NSURLRequest *expectedRequest = [NSURLRequest requestWithRequestModel:model];
                NSURLRequest *capturedRequest = sessionSpy.argument;

                [[expectedRequest should] equal:capturedRequest];
            });

            it(@"should execute datatask returned by dataTaskWithRequest:completionHandler:", ^{
                NSURLSession *sessionMock = [NSURLSession mock];

                EMSRequestModel *model = requestModel(@"https://url1.com", nil);

                EMSRESTClient *restClient = [EMSRESTClient clientWithSuccessBlock:successBlock errorBlock:errorBlock session:sessionMock logRepository:nil timestampProvider:[EMSTimestampProvider new]];
                NSURLSessionDataTask *dataTaskMock = [NSURLSessionDataTask mock];
                [[sessionMock should] receive:@selector(dataTaskWithRequest:completionHandler:)
                                    andReturn:dataTaskMock];
                [[dataTaskMock should] receive:@selector(resume)];

                KWCaptureSpy *sessionSpy = [sessionMock captureArgument:@selector(dataTaskWithRequest:completionHandler:)
                                                                atIndex:0];

                [restClient executeTaskWithOfflineCallbackStrategyWithRequestModel:model
                                                                        onComplete:^(BOOL shouldContinue) {

                                                                        }];

                NSURLRequest *expectedRequest = [NSURLRequest requestWithRequestModel:model];
                NSURLRequest *capturedRequest = sessionSpy.argument;

                [[expectedRequest should] equal:capturedRequest];
            });

            it(@"should return requestId, and responseModel on successBlock, when everything is fine", ^{
                NSURLSession *sessionMock = [NSURLSession mock];

                NSString *urlString = @"https://url1.com";
                EMSRequestModel *model = requestModel(urlString, nil);
                NSURLResponse *urlResponse = [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:urlString]
                                                                         statusCode:200
                                                                        HTTPVersion:nil
                                                                       headerFields:nil];
                NSData *data = [urlString dataUsingEncoding:NSUTF8StringEncoding];

                __block NSString *successRequestId;
                __block NSString *errorRequestId;
                __block EMSResponseModel *returnedResponse;
                __block NSError *returnedError;
                __block BOOL returnedShouldContinue;

                KWCaptureSpy *blockSpy = [sessionMock captureArgument:@selector(dataTaskWithRequest:completionHandler:)
                                                              atIndex:1];

                EMSRESTClient *restClient = [EMSRESTClient clientWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                    successRequestId = requestId;
                    returnedResponse = response;
                }                                                      errorBlock:^(NSString *requestId, NSError *error) {
                    errorRequestId = requestId;
                    returnedError = error;
                }                                                         session:sessionMock logRepository:nil timestampProvider:[EMSTimestampProvider new]];

                [restClient executeTaskWithOfflineCallbackStrategyWithRequestModel:model onComplete:^(BOOL shouldContinue) {
                    returnedShouldContinue = shouldContinue;
                }];

                void (^completionBlock)(NSData *_Nullable completionData, NSURLResponse *_Nullable response, NSError *_Nullable error) = blockSpy.argument;

                completionBlock(data, urlResponse, nil);

                [[expectFutureValue(successRequestId) shouldEventually] equal:model.requestId];
                [[expectFutureValue(returnedResponse) shouldNotEventually] beNil];
                [[expectFutureValue(returnedResponse.requestModel) shouldNot] beNil];
                [[expectFutureValue(returnedResponse.requestModel) should] equal:model];
                [[expectFutureValue(errorRequestId) shouldEventually] beNil];
                [[expectFutureValue(returnedError) shouldEventually] beNil];
                [[expectFutureValue(theValue(returnedShouldContinue)) shouldEventually] beYes];
            });

            it(@"should not return requestId or error on errorBlock nor successId and response when there is a retriable error", ^{
                NSURLSession *sessionMock = [NSURLSession mock];

                NSString *urlString = @"https://url1.com";
                EMSRequestModel *model = requestModel(urlString, nil);
                NSData *data = [urlString dataUsingEncoding:NSUTF8StringEncoding];
                NSURLResponse *urlResponse = [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:urlString]
                                                                         statusCode:500
                                                                        HTTPVersion:nil
                                                                       headerFields:nil];
                NSError *error = [NSError errorWithCode:5000 localizedDescription:@"crazy"];

                __block NSString *successRequestId;
                __block NSString *errorRequestId;
                __block EMSResponseModel *returnedResponse;
                __block NSError *returnedError;
                __block BOOL returnedShouldContinue;

                KWCaptureSpy *blockSpy = [sessionMock captureArgument:@selector(dataTaskWithRequest:completionHandler:)
                                                              atIndex:1];

                EMSRESTClient *restClient = [EMSRESTClient clientWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                    successRequestId = requestId;
                    returnedResponse = response;
                }                                                      errorBlock:^(NSString *requestId, NSError *blockError) {
                    errorRequestId = requestId;
                    returnedError = blockError;
                }                                                         session:sessionMock logRepository:nil timestampProvider:[EMSTimestampProvider new]];

                [restClient executeTaskWithOfflineCallbackStrategyWithRequestModel:model onComplete:^(BOOL shouldContinue) {
                    returnedShouldContinue = shouldContinue;
                }];

                void (^completionBlock)(NSData *_Nullable completionData, NSURLResponse *_Nullable response, NSError *_Nullable completionError) = blockSpy.argument;

                completionBlock(data, urlResponse, error);

                [[expectFutureValue(successRequestId) shouldEventually] beNil];
                [[expectFutureValue(returnedResponse) shouldEventually] beNil];
                [[expectFutureValue(errorRequestId) shouldEventually] beNil];
                [[expectFutureValue(returnedError) shouldEventually] beNil];
                [[expectFutureValue(theValue(returnedShouldContinue)) shouldEventually] beNo];
            });

            it(@"should not return requestId or error on errorBlock nor successId and response when there is a request timeout", ^{
                NSURLSession *sessionMock = [NSURLSession mock];

                NSString *urlString = @"https://url1.com";
                EMSRequestModel *model = requestModel(urlString, nil);
                NSData *data = [urlString dataUsingEncoding:NSUTF8StringEncoding];
                NSURLResponse *urlResponse = [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:urlString]
                                                                         statusCode:408
                                                                        HTTPVersion:nil
                                                                       headerFields:nil];
                NSError *error = [NSError errorWithCode:5000 localizedDescription:@"crazy"];

                __block NSString *successRequestId;
                __block NSString *errorRequestId;
                __block EMSResponseModel *returnedResponse;
                __block NSError *returnedError;
                __block BOOL returnedShouldContinue;

                KWCaptureSpy *blockSpy = [sessionMock captureArgument:@selector(dataTaskWithRequest:completionHandler:)
                                                              atIndex:1];

                EMSRESTClient *restClient = [EMSRESTClient clientWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                    successRequestId = requestId;
                    returnedResponse = response;
                }                                                      errorBlock:^(NSString *requestId, NSError *blockError) {
                    errorRequestId = requestId;
                    returnedError = blockError;
                }                                                         session:sessionMock logRepository:nil timestampProvider:[EMSTimestampProvider new]];

                [restClient executeTaskWithOfflineCallbackStrategyWithRequestModel:model onComplete:^(BOOL shouldContinue) {
                    returnedShouldContinue = shouldContinue;
                }];

                void (^completionBlock)(NSData *_Nullable completionData, NSURLResponse *_Nullable response, NSError *_Nullable completionError) = blockSpy.argument;

                completionBlock(data, urlResponse, error);

                [[expectFutureValue(successRequestId) shouldEventually] beNil];
                [[expectFutureValue(returnedResponse) shouldEventually] beNil];
                [[expectFutureValue(errorRequestId) shouldEventually] beNil];
                [[expectFutureValue(returnedError) shouldEventually] beNil];
                [[expectFutureValue(theValue(returnedShouldContinue)) shouldEventually] beNo];
            });

            it(@"should return requestId, and error on errorBlock, when there is a non-retriable error", ^{
                NSURLSession *sessionMock = [NSURLSession mock];

                NSString *urlString = @"https://url1.com";
                EMSRequestModel *model = requestModel(urlString, nil);
                NSData *data = [urlString dataUsingEncoding:NSUTF8StringEncoding];
                NSURLResponse *urlResponse = [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:urlString]
                                                                         statusCode:404
                                                                        HTTPVersion:nil
                                                                       headerFields:nil];
                NSError *error = [NSError errorWithCode:5000 localizedDescription:@"crazy"];

                __block NSString *successRequestId;
                __block NSString *errorRequestId;
                __block EMSResponseModel *returnedResponse;
                __block NSError *returnedError;
                __block BOOL returnedShouldContinue;

                KWCaptureSpy *blockSpy = [sessionMock captureArgument:@selector(dataTaskWithRequest:completionHandler:)
                                                              atIndex:1];

                EMSRESTClient *restClient = [EMSRESTClient clientWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                    successRequestId = requestId;
                    returnedResponse = response;
                }                                                      errorBlock:^(NSString *requestId, NSError *blockError) {
                    errorRequestId = requestId;
                    returnedError = blockError;
                }                                                         session:sessionMock logRepository:nil timestampProvider:[EMSTimestampProvider new]];

                [restClient executeTaskWithOfflineCallbackStrategyWithRequestModel:model onComplete:^(BOOL shouldContinue) {
                    returnedShouldContinue = shouldContinue;
                }];

                void (^completionBlock)(NSData *_Nullable completionData, NSURLResponse *_Nullable response, NSError *_Nullable completionError) = blockSpy.argument;

                completionBlock(data, urlResponse, error);

                [[expectFutureValue(successRequestId) shouldEventually] beNil];
                [[expectFutureValue(returnedResponse) shouldEventually] beNil];
                [[expectFutureValue(errorRequestId) shouldEventually] equal:model.requestId];
                [[expectFutureValue(returnedError) shouldEventually] equal:error];
                [[expectFutureValue(theValue(returnedShouldContinue)) shouldEventually] beYes];
            });


            it(@"should call onSuccess with the correct requestIDs for CompositeRequestModel", ^{
                __block NSMutableArray *_requestIds = [NSMutableArray new];
                __block NSError *_error;
                __block EMSRESTClient *_client;

                NSData *originalResponseData = [@"OK" dataUsingEncoding:NSUTF8StringEncoding];
                EMSRequestModel *originalRequestModel1 = requestModel(@"https://www.emarsys.com", nil);
                EMSRequestModel *originalRequestModel2 = requestModel(@"https://www.emarsys.com", nil);
                EMSRequestModel *originalRequestModel3 = requestModel(@"https://www.emarsys.com", nil);
                NSArray *originals = @[originalRequestModel1, originalRequestModel2, originalRequestModel3];

                EMSRequestModel *model = compositeRequestModel(@"https://www.google.com", nil, originals);

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForExpectation"];

                sessionMockWithCannedResponse(model, 200, originalResponseData, nil, ^(NSURLSession *session) {
                    _client = [EMSRESTClient clientWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                        [_requestIds addObject:requestId];
                        if ([_requestIds count] >= 3) {
                            [exp fulfill];
                        }
                    }                                    errorBlock:^(NSString *requestId, NSError *error) {

                    }                                       session:session logRepository:nil timestampProvider:[EMSTimestampProvider new]];

                    [_client executeTaskWithOfflineCallbackStrategyWithRequestModel:model onComplete:^(BOOL shouldContinue) {
                    }];
                });

                [XCTWaiter waitForExpectations:@[exp] timeout:10];

                [[theValue([_requestIds count]) should] equal:theValue(3)];
                [[_requestIds[0] should] equal:originalRequestModel1.requestId];
                [[_requestIds[1] should] equal:originalRequestModel2.requestId];
                [[_requestIds[2] should] equal:originalRequestModel3.requestId];
            });


            it(@"should call onError with the correct requestIDs for CompositeRequestModel", ^{
                __block NSMutableArray *_requestIds = [NSMutableArray new];
                __block NSError *_error;
                __block EMSRESTClient *_client;

                NSData *originalResponseData = [@"OK" dataUsingEncoding:NSUTF8StringEncoding];
                EMSRequestModel *originalRequestModel1 = requestModel(@"https://www.emarsys.com", nil);
                EMSRequestModel *originalRequestModel2 = requestModel(@"https://www.emarsys.com", nil);
                EMSRequestModel *originalRequestModel3 = requestModel(@"https://www.emarsys.com", nil);
                NSArray *originals = @[originalRequestModel1, originalRequestModel2, originalRequestModel3];

                EMSRequestModel *model = compositeRequestModel(@"https://www.google.com", nil, originals);

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForExpectation"];

                sessionMockWithCannedResponse(model, 404, originalResponseData, nil, ^(NSURLSession *session) {
                    _client = [EMSRESTClient clientWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                    }                                    errorBlock:^(NSString *requestId, NSError *error) {
                        [_requestIds addObject:requestId];
                        if ([_requestIds count] >= 3) {
                            [exp fulfill];
                        }
                    }                                       session:session logRepository:nil timestampProvider:[EMSTimestampProvider new]];

                    [_client executeTaskWithOfflineCallbackStrategyWithRequestModel:model onComplete:^(BOOL shouldContinue) {
                    }];
                });

                [XCTWaiter waitForExpectations:@[exp] timeout:10];

                [[theValue([_requestIds count]) should] equal:theValue(3)];
                [[_requestIds[0] should] equal:originalRequestModel1.requestId];
                [[_requestIds[1] should] equal:originalRequestModel2.requestId];
                [[_requestIds[2] should] equal:originalRequestModel3.requestId];
            });

        });

        describe(@"executeTaskWithRequestModel:onSuccess:onError", ^{

            it(@"should call onSuccess with the response data if the request was successful", ^{
                __block NSData *_data;
                __block NSError *_error;

                NSData *originalResponseData = [@"OK" dataUsingEncoding:NSUTF8StringEncoding];
                id model = requestModel(@"https://www.google.com", nil);
                sessionMockWithCannedResponse(model, 200, originalResponseData, nil, ^(NSURLSession *session) {
                    EMSRESTClient *client = [EMSRESTClient clientWithSession:session];
                    [client executeTaskWithRequestModel:model successBlock:^(NSString *requestId, EMSResponseModel *response) {
                        _data = response.body;
                    }                        errorBlock:^(NSString *requestId, NSError *error) {
                        _error = error;
                    }];
                });

                [[originalResponseData shouldEventually] equal:_data];
            });

            it(@"should call onSuccess with the correct requestID", ^{
                __block NSString *_requestId;
                __block NSError *_error;

                NSData *originalResponseData = [@"OK" dataUsingEncoding:NSUTF8StringEncoding];
                EMSRequestModel *model = requestModel(@"https://www.google.com", nil);
                sessionMockWithCannedResponse(model, 200, originalResponseData, nil, ^(NSURLSession *session) {
                    EMSRESTClient *client = [EMSRESTClient clientWithSession:session];
                    [client executeTaskWithRequestModel:model successBlock:^(NSString *requestId, EMSResponseModel *response) {
                        _requestId = requestId;
                    }                        errorBlock:^(NSString *requestId, NSError *error) {
                        _error = error;
                    }];
                });

                [[model.requestId shouldEventually] equal:_requestId];
            });

            it(@"should call onError if the request gone crazy", ^{
                __block NSData *_data;
                __block NSError *_error;

                NSData *originalResponseData = [@"OK" dataUsingEncoding:NSUTF8StringEncoding];
                NSError *originalError = [NSError errorWithCode:42 localizedDescription:@"desc"];
                id model = requestModel(@"https://www.google.com", nil);
                sessionMockWithCannedResponse(model, 500, nil, originalError, ^(NSURLSession *session) {
                    EMSRESTClient *client = [EMSRESTClient clientWithSession:session];
                    [client executeTaskWithRequestModel:model successBlock:^(NSString *requestId, EMSResponseModel *response) {
                        _data = response.body;
                    }                        errorBlock:^(NSString *requestId, NSError *error) {
                        _error = error;
                    }];
                });

                [[originalError shouldEventually] equal:_error];
            });

        });

        describe(@"logRepository", ^{
            it(@"should not log nil metric time", ^{
                EMSRequestModel *model = requestModel(@"https://www.goggle.com", nil);
                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForExpectation"];

                FakeLogRepository *logRepository = [FakeLogRepository new];
                NSData *originalResponseData = [@"OK" dataUsingEncoding:NSUTF8StringEncoding];
                __block EMSRESTClient *restClient;

                sessionMockWithCannedResponse(model, 200, originalResponseData, nil, ^(NSURLSession *session) {
                    restClient = [EMSRESTClient clientWithSuccessBlock:successBlock
                                                            errorBlock:errorBlock
                                                               session:session
                                                         logRepository:logRepository timestampProvider:[EMSTimestampProvider new]];
                    [restClient executeTaskWithOfflineCallbackStrategyWithRequestModel:model
                                                                            onComplete:^(BOOL shouldContinue) {
                                                                                [exp fulfill];
                                                                            }];
                });
                [XCTWaiter waitForExpectations:@[exp] timeout:10];

                NSDictionary<NSString *, id> *logElement = [logRepository.loggedElements firstObject];
                [[logElement shouldNot] beNil];
            });

            it(@"should log databaseTime", ^{
                EMSRequestModel *model = requestModel(@"https://www.goggle.com", nil);
                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForExpectation"];

                FakeLogRepository *logRepository = [FakeLogRepository new];
                NSData *originalResponseData = [@"OK" dataUsingEncoding:NSUTF8StringEncoding];
                __block EMSRESTClient *restClient;

                EMSTimestampProvider *timestampProvider = [EMSTimestampProvider mock];
                [[timestampProvider should] receive:@selector(provideTimestamp)
                                          andReturn:[NSDate dateWithTimeIntervalSince1970:[model.timestamp timeIntervalSince1970] + 53.3333]
                                   withCountAtLeast:2];

                sessionMockWithCannedResponse(model, 200, originalResponseData, nil, ^(NSURLSession *session) {
                    restClient = [EMSRESTClient clientWithSuccessBlock:successBlock
                                                            errorBlock:errorBlock
                                                               session:session
                                                         logRepository:logRepository
                                                     timestampProvider:timestampProvider];
                    [restClient executeTaskWithOfflineCallbackStrategyWithRequestModel:model
                                                                            onComplete:^(BOOL shouldContinue) {
                                                                                [exp fulfill];
                                                                            }];
                });
                [XCTWaiter waitForExpectations:@[exp] timeout:10];

                NSDictionary<NSString *, id> *logElement = [logRepository.loggedElements firstObject];
                [[logElement should] equal:@{
                        @"request_id": model.requestId,
                        @"url": model.url.absoluteString,
                        @"in_database": @53333}];
            });

            it(@"should log networking time", ^{
                EMSRequestModel *model = requestModel(@"https://www.goggle.com", nil);
                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForExpectation"];

                FakeLogRepository *logRepository = [FakeLogRepository new];
                NSData *responseData = [@"OK" dataUsingEncoding:NSUTF8StringEncoding];
                __block EMSRESTClient *restClient;

                NSDate *firstDate = [[NSDate alloc] initWithTimeIntervalSince1970:35.3456];
                NSDate *secondDate = [[NSDate alloc] initWithTimeIntervalSince1970:77.2347];

                EMSTimestampProvider *timestampProvider = [[FakeTimestampProvider alloc] initWithTimestamps:@[firstDate, secondDate]];

                sessionMockWithCannedResponse(model, 200, responseData, nil, ^(NSURLSession *session) {
                    restClient = [EMSRESTClient clientWithSuccessBlock:successBlock
                                                            errorBlock:errorBlock
                                                               session:session
                                                         logRepository:logRepository
                                                     timestampProvider:timestampProvider];
                    [restClient executeTaskWithOfflineCallbackStrategyWithRequestModel:model
                                                                            onComplete:^(BOOL shouldContinue) {
                                                                                [exp fulfill];
                                                                            }];
                });
                [XCTWaiter waitForExpectations:@[exp] timeout:10];

                NSDictionary<NSString *, id> *logElement = [logRepository.loggedElements lastObject];
                [[logElement should] equal:@{
                        @"request_id": model.requestId,
                        @"url": model.url.absoluteString,
                        @"networking_time": @(41889)}];
            });
        });


SPEC_END
