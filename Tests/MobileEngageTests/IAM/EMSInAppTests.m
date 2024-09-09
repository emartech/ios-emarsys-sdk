//
//  Copyright © 2022 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MEInApp.h"
#import "EMSWindowProvider.h"
#import "EMSMainWindowProvider.h"
#import "EMSTimestampProvider.h"
#import "EMSCompletionProvider.h"
#import "MEDisplayedIAMRepository.h"
#import "MEButtonClickRepository.h"
#import "EMSOperationQueue.h"
#import "MEInAppMessage.h"

@interface MEInApp (Tests)

@property(nonatomic, strong) NSMutableArray<MEInAppMessage *> *messages;

@end

@interface EMSInAppTests : XCTestCase

@property(nonatomic, strong) MEInApp *inApp;
@property(nonatomic, strong) EMSWindowProvider *mockWindowProvider;
@property(nonatomic, strong) EMSMainWindowProvider *mockMainWindowProvider;
@property(nonatomic, strong) EMSTimestampProvider *mockTimestampProvider;
@property(nonatomic, strong) EMSCompletionProvider *mockCompletionBlockProvider;
@property(nonatomic, strong) MEDisplayedIAMRepository *mockDisplayedIAMRepository;
@property(nonatomic, strong) MEButtonClickRepository *mockButtonClickRepository;

@end

@implementation EMSInAppTests

- (void)setUp {
    _mockWindowProvider = OCMClassMock([EMSWindowProvider class]);
    _mockMainWindowProvider = OCMClassMock([EMSMainWindowProvider class]);
    _mockTimestampProvider = OCMClassMock([EMSTimestampProvider class]);
    _mockCompletionBlockProvider = OCMClassMock([EMSCompletionProvider class]);
    _mockDisplayedIAMRepository = OCMClassMock([MEDisplayedIAMRepository class]);
    _mockButtonClickRepository = OCMClassMock([MEButtonClickRepository class]);
    _inApp = [[MEInApp alloc] initWithWindowProvider:self.mockWindowProvider
                                  mainWindowProvider:self.mockMainWindowProvider
                                   timestampProvider:self.mockTimestampProvider
                             completionBlockProvider:self.mockCompletionBlockProvider
                              displayedIamRepository:self.mockDisplayedIAMRepository
                               buttonClickRepository:self.mockButtonClickRepository
                                      operationQueue:[[EMSOperationQueue alloc] init]];
}

- (void)testShowMessage_shouldAddMessageToMessages_whenIAMWindowNotNil {
    MEInAppMessage *message = OCMClassMock([MEInAppMessage class]);
    UIWindow *mockWindow = OCMClassMock([UIWindow class]);
    [self.inApp setIamWindow:mockWindow];

    [self.inApp showMessage:message
          completionHandler:nil];
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForExpectation"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertTrue([self.inApp.messages containsObject:message]);
}

- (void)testCloseInApp_shouldCall_onMainThread {
    MEInApp *partialMockInApp = OCMPartialMock(self.inApp);

    UIViewController *mockRootViewController = OCMClassMock([UIViewController class]);
    UIWindow *mockWindow = OCMClassMock([UIWindow class]);
    OCMStub(mockWindow.rootViewController).andReturn(mockRootViewController);
    OCMStub([mockRootViewController dismissViewControllerAnimated:YES
                                                       completion:[OCMArg invokeBlock]]);
    [partialMockInApp setIamWindow:mockWindow];

    __block NSOperationQueue *resultQueue = nil;
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForExpectation"];
    [partialMockInApp closeInAppWithCompletionHandler:^{
        resultQueue = [NSOperationQueue currentQueue];
        [expectation fulfill];
    }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqual(resultQueue, [NSOperationQueue mainQueue]);
}

- (void)testCloseInApp_shouldCallShowMessage_whenMessagesIsNotEmpty {
    MEInApp *partialMockInApp = OCMPartialMock(self.inApp);

    MEInAppMessage *message = OCMClassMock([MEInAppMessage class]);
    MEInAppMessage *message2 = OCMClassMock([MEInAppMessage class]);
    UIViewController *mockRootViewController = OCMClassMock([UIViewController class]);
    UIWindow *mockWindow = OCMClassMock([UIWindow class]);
    OCMStub(mockWindow.rootViewController).andReturn(mockRootViewController);
    OCMStub([mockRootViewController dismissViewControllerAnimated:YES
                                                       completion:[OCMArg invokeBlock]]);
    [partialMockInApp setIamWindow:mockWindow];
    [partialMockInApp showMessage:message
                completionHandler:nil];
    [partialMockInApp showMessage:message2
                completionHandler:nil];

    [partialMockInApp closeInAppWithCompletionHandler:nil];
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForExpectation"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqual(partialMockInApp.messages.count, 1);
    XCTAssertEqualObjects(partialMockInApp.messages.firstObject, message2);
    OCMVerify([partialMockInApp showMessage:message
                          completionHandler:nil]);
}

@end
