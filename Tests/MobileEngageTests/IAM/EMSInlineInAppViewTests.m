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

@interface EMSInlineInAppView (Tests)

@property(nonatomic, strong) WKWebView *webView;

- (void)fetchInlineInappMessage;

@end

@interface EMSInlineInAppViewTests : XCTestCase

@property(nonatomic, strong) EMSInlineInAppView *inappView;
@property(nonatomic, strong) id mockContainer;
@property(nonatomic, strong) id mockRequestManager;
@property(nonatomic, strong) id mockRequestFactory;
@end

@implementation EMSInlineInAppViewTests

- (void)setUp {
    _mockContainer = OCMClassMock([EMSDependencyContainer class]);
    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    MEInApp *mockInapp = OCMClassMock([MEInApp class]);

    [EMSDependencyInjection setupWithDependencyContainer:self.mockContainer];
    OCMStub([self.mockContainer requestManager]).andReturn(self.mockRequestManager);
    OCMStub([self.mockContainer requestFactory]).andReturn(self.mockRequestFactory);
    OCMStub([self.mockContainer iam]).andReturn(mockInapp);

    _inappView = [[EMSInlineInAppView alloc] initWithFrame:CGRectMake(0, 0, 640, 480)];
}

- (void)tearDown {
    [self.mockRequestFactory stopMocking];
    [self.mockRequestManager stopMocking];
    [self.mockContainer stopMocking];
    [EMSDependencyInjection tearDown];
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

@end