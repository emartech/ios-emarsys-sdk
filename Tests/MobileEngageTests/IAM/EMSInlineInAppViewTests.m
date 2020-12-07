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

@interface EMSInlineInAppView (Tests)

@property(nonatomic, strong) WKWebView *webView;

- (void)fetchInlineInappMessage;

@end

@interface EMSInlineInAppViewTests : XCTestCase

@property(nonatomic, strong) EMSInlineInAppView *inappView;
@property(nonatomic, strong) id mockContainer;
@property(nonatomic, strong) id mockRequestManager;
@property(nonatomic, strong) id mockRequestFactory;
@property(nonatomic, strong) id operationQueue;
@property(nonatomic, strong) id mockInapp;
@end

@implementation EMSInlineInAppViewTests

- (void)setUp {
    _mockContainer = OCMClassMock([EMSDependencyContainer class]);
    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    _operationQueue = [NSOperationQueue new];
    [self.operationQueue setMaxConcurrentOperationCount:1];
    _mockInapp = OCMClassMock([MEInApp class]);

    [EMSDependencyInjection setupWithDependencyContainer:self.mockContainer];
    OCMStub([self.mockContainer requestManager]).andReturn(self.mockRequestManager);
    OCMStub([self.mockContainer requestFactory]).andReturn(self.mockRequestFactory);
    OCMStub([self.mockContainer coreOperationQueue]).andReturn(self.operationQueue);
    OCMStub([self.mockContainer iam]).andReturn(self.mockInapp);

    _inappView = [[EMSInlineInAppView alloc] initWithFrame:CGRectMake(0, 0, 640, 480)];
}

- (void)tearDown {
    [self.mockRequestFactory stopMocking];
    [self.mockRequestManager stopMocking];
    [self.mockContainer stopMocking];
    [EMSDependencyInjection tearDown];
}

- (void)testFetchInlineInapp_shouldScheduleToCoreThread {
    [EMSDependencyInjection tearDown];
    EMSDependencyContainer *container = OCMClassMock([EMSDependencyContainer class]);
    OCMStub([container requestFactory]).andReturn(self.mockRequestFactory);
    OCMStub([container coreOperationQueue]).andReturn(self.operationQueue);
    OCMStub([container iam]).andReturn(self.mockInapp);
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"testExpectation"];
    __block NSOperationQueue *resultQueue = nil;

    FakeRequestManager *fakeRequestManager = [[FakeRequestManager alloc] initWithSubmitNowCompletionBlock:^{
        resultQueue = [NSOperationQueue currentQueue];
        [expectation fulfill];
    }];
    OCMStub([container requestManager]).andReturn(fakeRequestManager);

    [EMSDependencyInjection setupWithDependencyContainer:container];

    EMSInlineInAppView *inlineInAppView = [[EMSInlineInAppView alloc] initWithFrame:CGRectMake(0, 0, 640, 480)];

    [inlineInAppView loadInAppWithViewId:@"testViewId"];

    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation]
                                                    timeout:10];

    XCTAssertEqual(result, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(resultQueue, self.operationQueue);
}

- (void)testFetchInlineInappMessage_shouldSendInlineInappRequestWithManager {
    EMSRequestModel *requestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([self.mockRequestFactory createInlineInappRequestModelWithViewId:@"testViewId"]).andReturn(requestModel);

    [self.inappView loadInAppWithViewId:@"testViewId"];
    [self.inappView fetchInlineInappMessage];
    OCMVerify([EMSDependencyInjection.dependencyContainer.requestFactory createInlineInappRequestModelWithViewId:@"testViewId"]);
    OCMVerify([self.mockRequestManager submitRequestModelNow:requestModel
                                                successBlock:[OCMArg any]
                                                  errorBlock:[OCMArg any]]);
}

- (void)testFetchInlineInappMessage_shouldLoadMessage {
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

    [self.inappView loadInAppWithViewId:@"testViewId"];
    [self.inappView fetchInlineInappMessage];

    OCMVerify([self.inappView.webView loadHTMLString:@"<HTML><BODY></BODY></HTML>"
                                             baseURL:nil]);
}

- (void)testFetchInlineInappMessage_shouldCallCompletionBlockWithError_whenNoInAppMessageFound {
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
    [inlineInappPartialMock fetchInlineInappMessage];

    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation]
                                                    timeout:10];

    XCTAssertEqual(result, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(returnedError.localizedDescription, expectedError.localizedDescription);
    XCTAssertEqual(returnedError.code, expectedError.code);
    XCTAssertEqualObjects(returnedThread, NSThread.mainThread);
}

@end
