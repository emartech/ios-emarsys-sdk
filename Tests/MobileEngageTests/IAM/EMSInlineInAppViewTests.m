//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <WebKit/WebKit.h>
#import "EMSInlineInAppView.h"
#import "EMSDependencyContainer.h"
#import "EMSRequestManager.h"
#import "EMSDependencyInjection.h"
#import "EMSRequestFactory.h"
#import "EMSResponseModel.h"
#import "MeInapp.h"
#import "NSError+EMSCore.h"
#import "FakeRequestManager.h"
#import "XCTestCase+Helper.h"

@interface EMSInlineInAppView (Tests)

@property(nonatomic, strong) WKWebView *webView;

- (void)fetchInlineInappMessage;

- (void)closeInAppWithCompletionHandler:(EMSCompletion _Nullable)completionHandler;

@end

@interface EMSInlineInAppViewTests : XCTestCase

@property(nonatomic, strong) EMSInlineInAppView *inappView;
@property(nonatomic, strong) id mockContainer;
@property(nonatomic, strong) id mockRequestManager;
@property(nonatomic, strong) id mockRequestFactory;
@property(nonatomic, strong) id operationQueue;
@property(nonatomic, strong) id publicApiOperationQueue;
@property(nonatomic, strong) id mockInapp;
@end

@implementation EMSInlineInAppViewTests

- (void)setUp {
    _mockContainer = OCMClassMock([EMSDependencyContainer class]);
    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    _operationQueue = [NSOperationQueue new];
    [self.operationQueue setName:@"CORE"];
    [self.operationQueue setMaxConcurrentOperationCount:1];
    _publicApiOperationQueue = [NSOperationQueue new];
    [self.publicApiOperationQueue setName:@"PUBLIC"];
    [self.publicApiOperationQueue setMaxConcurrentOperationCount:1];
    _mockInapp = OCMClassMock([MEInApp class]);
}

- (void)tearDown {
    [self.mockRequestFactory stopMocking];
    [self.mockRequestManager stopMocking];
    [self.mockInapp stopMocking];
    [self.mockContainer stopMocking];
    [self tearDownOperationQueue:self.operationQueue];
    [self tearDownOperationQueue:self.publicApiOperationQueue];
    [EMSDependencyInjection tearDown];
}

- (void)testFetchInlineInapp_shouldScheduleToCoreThread {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"testExpectation"];
    __block NSOperationQueue *resultQueue = nil;

    FakeRequestManager *fakeRequestManager = [[FakeRequestManager alloc] initWithSubmitNowCompletionBlock:^{
        resultQueue = [NSOperationQueue currentQueue];
        [expectation fulfill];
    }];
    [self setupMockContainerWithRequestManager:fakeRequestManager];

    EMSInlineInAppView *inlineInAppView = [[EMSInlineInAppView alloc] initWithFrame:CGRectMake(0, 0, 640, 480)];

    [inlineInAppView loadInAppWithViewId:@"testViewId"];

    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation]
                                                    timeout:10];

    XCTAssertEqual(result, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(resultQueue, self.operationQueue);
}

- (void)testFetchInlineInappMessage_shouldSendInlineInappRequestWithManager {
    [self setupMockContainerWithRequestManager:self.mockRequestManager];

    EMSRequestModel *requestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([self.mockRequestFactory createInlineInappRequestModelWithViewId:@"testViewId"]).andReturn(requestModel);

    EMSInlineInAppView *inAppView = [[EMSInlineInAppView alloc] initWithFrame:CGRectMake(0, 0, 640, 480)];
    [inAppView loadInAppWithViewId:@"testViewId"];
    [inAppView fetchInlineInappMessage];

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForOperationQueue"];
    [self.operationQueue addOperationWithBlock:^{
        [expectation fulfill];
    }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    OCMVerify([EMSDependencyInjection.dependencyContainer.requestFactory createInlineInappRequestModelWithViewId:@"testViewId"]);
    OCMVerify([self.mockRequestManager submitRequestModelNow:requestModel
                                                successBlock:[OCMArg any]
                                                  errorBlock:[OCMArg any]]);
}

- (void)testFetchInlineInappMessage_shouldLoadMessage {
    [self setupMockContainerWithRequestManager:self.mockRequestManager];
    EMSResponseModel *mockResponse = OCMClassMock([EMSResponseModel class]);

    OCMStub([mockResponse parsedBody]).andReturn((@{
            @"inlineMessages": @[
                    @{
                            @"html": @"<HTML><BODY></BODY></HTML>",
                            @"campaignId": @"testCampaignId",
                            @"viewId": @"testViewId"
                    },
                    @{
                            @"html": @"<HTML></HTML>",
                            @"campaignId": @"testCampaignId2",
                            @"viewId": @"testViewId2"
                    }
            ]
    }));
    OCMStub([self.mockRequestManager submitRequestModelNow:[OCMArg any]
                                              successBlock:([OCMArg invokeBlockWithArgs:@"testRequestId",
                                                                                        mockResponse,
                                                                                        nil])
                                                errorBlock:[OCMArg any]]);

    EMSInlineInAppView *inAppView = [[EMSInlineInAppView alloc] initWithFrame:CGRectMake(0, 0, 640, 480)];
    EMSInlineInAppView *partialMock = OCMPartialMock(inAppView);

    XCTestExpectation *expectation= [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [partialMock setCompletionBlock:^(NSError *error) {
            [expectation fulfill];
        }];
        [partialMock loadInAppWithViewId:@"testViewId"];
    });

    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation]
            timeout:5];

    XCTAssertEqual(result, XCTWaiterResultCompleted);
    OCMVerify([partialMock.webView loadHTMLString:@"<HTML><BODY></BODY></HTML>"
                                          baseURL:nil]);
}

- (void)testFetchInlineInappMessage_shouldCallCompletionBlockWithError_whenNoInAppMessageFound {
    [self setupMockContainerWithRequestManager:self.mockRequestManager];
    _inappView = [[EMSInlineInAppView alloc] initWithFrame:CGRectMake(0, 0, 640, 480)];

    EMSInlineInAppView *inlineInappPartialMock = OCMPartialMock(self.inappView);
    OCMReject([inlineInappPartialMock.webView loadHTMLString:[OCMArg any]
                                                     baseURL:nil]);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"testExpectation"];

    EMSResponseModel *mockResponse = OCMClassMock([EMSResponseModel class]);
    NSError *expectedError = [NSError errorWithCode:-1400
                               localizedDescription:@"Inline In-App HTML content must not be empty, please check your viewId!"];

    OCMStub([mockResponse parsedBody]).andReturn((@{
            @"inlineMessages": @[
            ]
    }));
    OCMStub([self.mockRequestManager submitRequestModelNow:[OCMArg any]
                                              successBlock:([OCMArg invokeBlockWithArgs:@"testRequestId",
                                                                                        mockResponse,
                                                                                        nil])
                                                errorBlock:[OCMArg any]]);

    __block NSError *returnedError;
    __block NSThread *returnedThread = nil;
    EMSCompletionBlock completionBlock = ^(NSError *error) {
        returnedError = error;
        returnedThread = [NSThread currentThread];
        [expectation fulfill];
    };

    [inlineInappPartialMock setCompletionBlock:completionBlock];
    [inlineInappPartialMock loadInAppWithViewId:@"testViewId"];

    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation]
                                                    timeout:10];

    XCTAssertEqual(result, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(returnedError.localizedDescription, expectedError.localizedDescription);
    XCTAssertEqual(returnedError.code, expectedError.code);
    XCTAssertEqualObjects(returnedThread, NSThread.mainThread);
}

- (void)testFetchInlineInappMessage_shouldCallCompletionBlockWithError_fetchingFailed {
    [self setupMockContainerWithRequestManager:self.mockRequestManager];
    _inappView = [[EMSInlineInAppView alloc] initWithFrame:CGRectMake(0, 0, 640, 480)];

    EMSInlineInAppView *inlineInappPartialMock = OCMPartialMock(self.inappView);
    OCMReject([inlineInappPartialMock.webView loadHTMLString:[OCMArg any]
                                                     baseURL:nil]);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"testExpectation"];

    NSError *expectedError = [NSError errorWithCode:-1400
                               localizedDescription:@"Test error"];

    OCMStub([self.mockRequestManager submitRequestModelNow:[OCMArg any]
                                              successBlock:[OCMArg any]
                                                errorBlock:([OCMArg invokeBlockWithArgs:@"testRequestId",
                                                                                        expectedError,
                                                                                        nil])]);

    __block NSError *returnedError;
    __block NSThread *returnedThread = nil;
    EMSCompletionBlock completionBlock = ^(NSError *error) {
        returnedError = error;
        returnedThread = [NSThread currentThread];
        [expectation fulfill];
    };

    [inlineInappPartialMock setCompletionBlock:completionBlock];
    [inlineInappPartialMock loadInAppWithViewId:@"testViewId"];

    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation]
                                                    timeout:10];

    XCTAssertEqual(result, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(returnedError.localizedDescription, expectedError.localizedDescription);
    XCTAssertEqual(returnedError.code, expectedError.code);
    XCTAssertEqualObjects(returnedThread, NSThread.mainThread);
}

- (void)testCloseBlock_shouldNotCrash_whenMissing {
    [self setupMockContainerWithRequestManager:self.mockRequestManager];
    EMSInlineInAppView *inAppView = [[EMSInlineInAppView alloc] initWithFrame:CGRectMake(0, 0, 640, 480)];
    [inAppView closeInAppWithCompletionHandler:nil];
}

- (void)setupMockContainerWithRequestManager:(EMSRequestManager *)requestManager {
    [EMSDependencyInjection setupWithDependencyContainer:self.mockContainer];
    OCMStub([self.mockContainer requestFactory]).andReturn(self.mockRequestFactory);
    OCMStub([self.mockContainer coreOperationQueue]).andReturn(self.operationQueue);
    OCMStub([self.mockContainer publicApiOperationQueue]).andReturn(self.publicApiOperationQueue);
    OCMStub([self.mockContainer iam]).andReturn(self.mockInapp);
    if (requestManager != nil) {
        OCMStub([self.mockContainer requestManager]).andReturn(requestManager);
    }
}


@end
