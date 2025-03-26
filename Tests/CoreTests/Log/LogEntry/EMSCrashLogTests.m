//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSCrashLog.h"
#import "NSDictionary+EMSCore.h"

@interface EMSCrashLogTests : XCTestCase

@property(nonatomic, strong) EMSCrashLog *logCrash;
@end

@implementation EMSCrashLogTests

- (void)setUp {
    NSException *exc = OCMClassMock([NSException class]);
    OCMStub(exc.name).andReturn(@"exceptionName");
    OCMStub(exc.reason).andReturn(@"reasonOfTheException");
    NSArray<NSString *> *stackSymbols = @[@"stack1", @"stack2", @"stack3"];
    OCMStub(exc.callStackSymbols).andReturn(stackSymbols);
    OCMStub(exc.userInfo).andReturn(@{@"userInfoKey": @"userInfoValue"});

    self.logCrash = [[EMSCrashLog alloc] initWithException:exc];
}

- (void)testInit_shouldNotAccept_nilException {
    @try {
        [[EMSCrashLog alloc] initWithException:nil];
        XCTFail(@"Expected exception when exception is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: exception");
    }
}

- (void)testTopic {
    XCTAssertEqualObjects(self.logCrash.topic, @"log_crash");
}

- (void)testData {
    NSDictionary *expectedData = @{
        @"exception": @"exceptionName",
        @"reason": @"reasonOfTheException",
        @"stackTrace": @"stack1\nstack2\nstack3\n",
        @"userInfo": [@{
            @"userInfoKey": @"userInfoValue"
        } asJSONString]
    };
    XCTAssertEqualObjects(self.logCrash.data, expectedData);
}

@end
