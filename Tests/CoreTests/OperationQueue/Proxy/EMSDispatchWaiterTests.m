//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSDispatchWaiter.h"

@interface EMSDispatchWaiterTests : XCTestCase

@end

@implementation EMSDispatchWaiterTests

- (void)testWaiter {
    __block NSObject *expectedObject = [NSObject new];
    __block NSObject *resultObject = nil;

    EMSDispatchWaiter *waiter = [EMSDispatchWaiter new];

    [waiter enter];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        resultObject = expectedObject;
        [waiter exit];
    });
    [waiter waitWithInterval:0];

    XCTAssertEqualObjects(resultObject, expectedObject);
}

- (void)testWaiterWithInterval {
    __block NSObject *expectedObject = [NSObject new];
    __block NSObject *resultObject = nil;

    EMSDispatchWaiter *waiter = [EMSDispatchWaiter new];

    [waiter enter];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        resultObject = expectedObject;
        [waiter exit];
    });
    [waiter waitWithInterval:1];

    XCTAssertEqualObjects(resultObject, expectedObject);
}

@end
