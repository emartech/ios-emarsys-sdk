//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSCompletionBlockProvider.h"
#import "EMSOperationQueue.h"

@interface EMSCompletionBlockProviderTests : XCTestCase

@end

@implementation EMSCompletionBlockProviderTests

- (void)setUp {

}

- (void)testInit_operationQueue_mustNotBeNil {
    @try {
        [[EMSCompletionBlockProvider alloc] initWithOperationQueue:nil];
        XCTFail(@"Expected Exception when operationQueue is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: operationQueue");
    }
}

- (void)testProvideCompletion {
    EMSOperationQueue *expectedOperationQueue = [EMSOperationQueue new];
    expectedOperationQueue.maxConcurrentOperationCount = 1;
    expectedOperationQueue.qualityOfService = NSQualityOfServiceUtility;
    EMSCompletionBlockProvider *provider = [[EMSCompletionBlockProvider alloc] initWithOperationQueue:expectedOperationQueue];

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
                                                          timeout:5];

    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(usedOperationQueue, expectedOperationQueue);
}

@end
