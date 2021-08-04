//
//  Copyright © 2021 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MERequestContext.h"
#import "EMSEndpoint.h"
#import "EMSSdkStateLogger.h"
#import "EMSStorage.h"

@interface EMSSdkStateLoggerTests : XCTestCase

@property(nonatomic, strong) MERequestContext *mockMeRequestContext;
@property(nonatomic, strong) EMSEndpoint *mockEndpoint;
@property(nonatomic, strong) EMSConfig *mockConfig;
@property(nonatomic, strong) EMSStorage *mockStorage;

@end

@implementation EMSSdkStateLoggerTests

- (void)setUp {
    _mockMeRequestContext = OCMClassMock([MERequestContext class]);
    _mockEndpoint = OCMClassMock([EMSEndpoint class]);
    _mockConfig = OCMClassMock([EMSConfig class]);
    _mockStorage = OCMClassMock([EMSStorage class]);
}

- (void)testInit_endpoint_mustNotBeNil {
    @try {
        [[EMSSdkStateLogger alloc] initWithEndpoint:nil
                                   meRequestContext:self.mockMeRequestContext
                                             config:self.mockConfig
                                            storage:self.mockStorage];
        XCTFail(@"Expected Exception when endpoint is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: endpoint");
    }
}

- (void)testInit_meRequestContext_mustNotBeNil {
    @try {
        [[EMSSdkStateLogger alloc] initWithEndpoint:self.mockEndpoint
                                   meRequestContext:nil
                                             config:self.mockConfig
                storage:self.mockStorage];
        XCTFail(@"Expected Exception when meRequestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: meRequestContext");
    }
}

- (void)testInit_config_mustNotBeNil {
    @try {
        [[EMSSdkStateLogger alloc] initWithEndpoint:self.mockEndpoint
                                   meRequestContext:self.mockMeRequestContext
                                             config:nil
                storage:self.mockStorage];
        XCTFail(@"Expected Exception when config is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: config");
    }
}

- (void)testInit_storage_mustNotBeNil {
    @try {
        [[EMSSdkStateLogger alloc] initWithEndpoint:self.mockEndpoint
                                   meRequestContext:self.mockMeRequestContext
                                             config:self.mockConfig
                                            storage:nil];
        XCTFail(@"Expected Exception when storage is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: storage");
    }
}

@end
