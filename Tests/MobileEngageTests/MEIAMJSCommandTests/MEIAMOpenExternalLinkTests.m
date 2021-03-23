#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MEIAMOpenExternalLink.h"
#import "EMSWaiter.h"

@interface MEIAMOpenExternalLinkTests : XCTestCase

@property(nonatomic, strong) UIApplication *mockApplication;
@property(nonatomic, strong) MEIAMOpenExternalLink *command;

@end

@implementation MEIAMOpenExternalLinkTests

- (void)setUp {
    _mockApplication = OCMClassMock([UIApplication class]);
    _command = [[MEIAMOpenExternalLink alloc] initWithApplication:self.mockApplication];
}

- (void)tearDown {
    [((id) self.mockApplication) stopMocking];
}

- (void)testInit_application_mustNotBeNil {
    @try {
        [[MEIAMOpenExternalLink alloc] initWithApplication:nil];
        XCTFail(@"Expected Exception when application is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: application");
    }
}

- (void)testHandleMessage_withNoSuccess {
    NSString *link = @"notAValidUrl";

    OCMStub([self.mockApplication canOpenURL:[OCMArg any]]).andReturn(NO);

    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"wait"];
    __block BOOL returnedContent;
    [self.command handleMessage:@{@"id": @1, @"url": link}
                    resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                        returnedContent = [((NSNumber *) result[@"success"]) boolValue];
                        [exp fulfill];
                    }];

    [EMSWaiter waitForExpectations:@[exp]
                           timeout:30];

    XCTAssertFalse(returnedContent);
}

- (void)testHandleMessage_withMissingUrl {
    NSDictionary *expected = @{
            @"success": @NO,
            @"id": @"999",
            @"errors": @[
                    @"Missing 'url' key with type: NSString."
            ]
    };

    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    __block NSDictionary<NSString *, NSObject *> *returnedResult;

    [self.command handleMessage:@{@"id": @"999"}
                    resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                        returnedResult = result;
                        [exp fulfill];
                    }];
    [EMSWaiter waitForExpectations:@[exp]
                           timeout:30];


    XCTAssertEqualObjects(returnedResult, expected);
}

- (void)testHandleMessage_withWrongType {
    NSArray *urlValue = @[];
    NSDictionary *expected = @{
            @"success": @NO,
            @"id": @"999",
            @"errors": @[
                    [NSString stringWithFormat:@"Type mismatch for key 'url', expected type: NSString, but was: %@.",
                                               NSStringFromClass([urlValue class])]
            ]
    };

    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    __block NSDictionary<NSString *, NSObject *> *returnedResult;
    [self.command handleMessage:@{@"id": @"999", @"url": urlValue}
                    resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                        returnedResult = result;
                        [exp fulfill];
                    }];
    [EMSWaiter waitForExpectations:@[exp]
                           timeout:30];

    XCTAssertEqualObjects(returnedResult, expected);
}

- (void)testHandleMessage_success {
    NSString *link = @"https://www.google.com";

    OCMStub([self.mockApplication canOpenURL:[OCMArg any]]).andReturn(YES);
    OCMStub([self.mockApplication openURL:[OCMArg any]
                                  options:@{}
                        completionHandler:([OCMArg invokeBlockWithArgs:@YES, nil])]);

    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    [self.command handleMessage:@{@"url": link, @"id": @1}
                    resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                        [exp fulfill];
                    }];
    [EMSWaiter waitForExpectations:@[exp]
                           timeout:5];

    OCMVerify([self.mockApplication openURL:[NSURL URLWithString:link]
                                    options:@{}
                          completionHandler:[OCMArg isNotNil]]);
}

@end


