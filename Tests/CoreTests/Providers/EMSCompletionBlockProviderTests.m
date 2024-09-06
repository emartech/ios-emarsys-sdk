//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSCompletionProvider.h"
#import "EMSOperationQueue.h"
#import "XCTestCase+Helper.h"
#import "EmarsysTestUtils.h"

@interface EMSCompletionBlockProviderTests : XCTestCase

@property(nonatomic, strong) NSOperationQueue *queue;

@end

@implementation EMSCompletionBlockProviderTests

- (void)setUp {
    _queue = [self createTestOperationQueue];
}

- (void)tearDown {
    [EmarsysTestUtils tearDownOperationQueue:self.queue];
}

- (void)testInit_operationQueue_mustNotBeNil {
    @try {
        [[EMSCompletionProvider alloc] initWithOperationQueue:nil];
        XCTFail(@"Expected Exception when operationQueue is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: operationQueue");
    }
}

- (void)testProvideCompletion {
    EMSCompletionProvider *provider = [[EMSCompletionProvider alloc] initWithOperationQueue:self.queue];

    __block NSOperationQueue *usedOperationQueue;

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletionBlock"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMSCompletion triggerableBlock = [provider provideCompletion:^{
            usedOperationQueue = [NSOperationQueue currentQueue];
            [expectation fulfill];
        }];

        triggerableBlock();
    });

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(usedOperationQueue, self.queue);
}

@end
