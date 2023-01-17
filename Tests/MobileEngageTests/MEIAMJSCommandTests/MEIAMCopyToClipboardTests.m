//
//  Copyright © 2023 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MEIAMCopyToClipboard.h"

@interface MEIAMCopyToClipboardTests: XCTestCase

@property(nonatomic, strong) MEIAMCopyToClipboard *command;
@property(nonatomic, strong) UIPasteboard *mockPasteboard;

@end

@implementation MEIAMCopyToClipboardTests

- (void)setUp {
    _mockPasteboard = OCMClassMock([UIPasteboard class]);
    _command = [[MEIAMCopyToClipboard alloc] initWithPasteboard:self.mockPasteboard];
}

- (void)tearDown {
}

- (void)testCommand_whenSuccess {
    NSDictionary *message = @{
            @"id": @"testEventId",
            @"text": @"testTextToCopy"
    };
    NSDictionary *expectedResult = @{
            @"success": @YES,
            @"id": @"testEventId"
    };

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    __block NSDictionary *resultDict = nil;
    [self.command handleMessage:message
                    resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                        resultDict = result;
                        [expectation fulfill];
                    }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
            timeout:5];

    OCMVerify([self.mockPasteboard setString:@"testTextToCopy"]);

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(resultDict, expectedResult);
}

- (void)testCommand_whenMissingText {
    NSDictionary *message = @{
            @"id": @"testEventId"
    };
    NSDictionary *expectedResult = @{
            @"success": @NO,
            @"id": @"testEventId",
            @"errors": @[@"Missing 'text' key with type: NSString."]
    };

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    __block NSDictionary *resultDict = nil;
    [self.command handleMessage:message
                    resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                        resultDict = result;
                        [expectation fulfill];
                    }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:5];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(resultDict, expectedResult);
}

- (void)testCommandName {
    XCTAssertEqualObjects(MEIAMCopyToClipboard.commandName, @"copyToClipboard");
}

@end
