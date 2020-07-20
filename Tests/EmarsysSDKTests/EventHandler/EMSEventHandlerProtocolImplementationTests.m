//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSEventHandlerProtocolImplementation.h"

@interface EMSEventHandlerProtocolImplementationTests : XCTestCase

@property(nonatomic, strong) EMSEventHandlerProtocolImplementation *eventHandlerImpl;

@end

@implementation EMSEventHandlerProtocolImplementationTests

- (void)setUp {
    [super setUp];
    _eventHandlerImpl = [EMSEventHandlerProtocolImplementation new];
}

- (void)testHandleEventPayload_withBlock {
    NSString *eventName = @"testEventName";
    NSDictionary *payload = @{@"testKey": @{}};

    __block NSString *returnedEventName = nil;
    __block NSDictionary *returnedPayload = nil;
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForBlock"];
    self.eventHandlerImpl.handlerBlock = ^(NSString *eventName, NSDictionary<NSString *, NSObject *> *payload) {
        returnedEventName = eventName;
        returnedPayload = payload;
        [expectation fulfill];
    };

    [self.eventHandlerImpl handleEvent:eventName
                               payload:payload];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:5];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(returnedEventName, eventName);
    XCTAssertEqualObjects(returnedPayload, payload);
}

- (void)testHandleEventPayload_withoutBlock_shouldNotCrash {
    NSString *eventName = @"testEventName";
    NSDictionary *payload = @{@"testKey": @{}};

    [self.eventHandlerImpl handleEvent:eventName
                               payload:payload];
}

@end
