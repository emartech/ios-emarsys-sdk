//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSAppEventLog.h"

@interface EMSAppEventLogTests : XCTestCase

@property(nonatomic, strong) EMSAppEventLog *appEventLog;
@property(nonatomic, strong) NSString *eventName;
@property(nonatomic, strong) NSDictionary<NSString *, id> *payload;

@end

@implementation EMSAppEventLogTests

- (void)setUp {
    _eventName = @"testEventName";
    _payload = @{@"testKey": @"testValue"};
    _appEventLog = [[EMSAppEventLog alloc] initWithEventName:self.eventName
                                                  attributes:self.payload];
}

- (void)testInit_eventName_mustNotBeNil {
    @try {
        [[EMSAppEventLog alloc] initWithEventName:nil
                                       attributes:@{}];
        XCTFail(@"Expected Exception when eventName is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: eventName");
    }
}

- (void)testTopic {
    XCTAssertEqualObjects(self.appEventLog.topic, @"log_app_event");
}

- (void)testData {
    NSDictionary *expectedData = @{
        @"eventName": self.eventName,
        @"eventAttributes": self.payload
    };

    XCTAssertEqualObjects(self.appEventLog.data, expectedData);
}

@end
