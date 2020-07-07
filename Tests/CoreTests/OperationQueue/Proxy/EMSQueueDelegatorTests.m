//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSQueueDelegator.h"
#import "EMSBlocks.h"

@protocol QueueCheckerProtocol

@property(nonatomic, strong) EMSCompletionBlock completionBlock;

- (void)triggerBlock;

@end

@interface QueueChecker : NSObject <QueueCheckerProtocol>

@property(nonatomic, strong) EMSCompletionBlock completionBlock;

@end

@implementation QueueChecker

- (void)triggerBlock {
    self.completionBlock(nil);
}

@end

@interface EMSQueueDelegatorTests : XCTestCase

@property(nonatomic, strong) id <QueueCheckerProtocol> queueDelegator;
@property(nonatomic, strong) NSOperationQueue *operationQueue;
@property(nonatomic, strong) NSOperationQueue *backgroundQueue;
@property(nonatomic, strong) QueueChecker *queueChecker;

@end

@implementation EMSQueueDelegatorTests

- (void)setUp {
    _operationQueue = [NSOperationQueue new];
    [self.operationQueue setName:@"testOperationQueue"];
    [self.operationQueue setMaxConcurrentOperationCount:1];
    _backgroundQueue = [NSOperationQueue new];
    [self.backgroundQueue setName:@"testBackgroundQueue"];
    
    _queueChecker = [QueueChecker new];
    
    id queueDelegator = [EMSQueueDelegator alloc];
    [queueDelegator setupWithQueue:self.operationQueue
                       emptyTarget:[QueueChecker new]];
    
    [queueDelegator proxyWithTargetObject:self.queueChecker];
    
    _queueDelegator = queueDelegator;
}

- (void)testProxyWithTargetObjectQueue_targetObject_mustNotBeNil {
    @try {
        EMSQueueDelegator *delegator = [EMSQueueDelegator alloc];
        [delegator proxyWithTargetObject:nil];
        XCTFail(@"Expected Exception when object is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: object");
    }
}

- (void)testProxyWithTargetObjectQueue_queue_mustNotBeNil {
    @try {
        EMSQueueDelegator *delegator = [EMSQueueDelegator alloc];
        [delegator setupWithQueue:nil
                      emptyTarget:[QueueChecker new]];
        XCTFail(@"Expected Exception when queue is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: queue");
    }
}

- (void)testProxyWithTargetObjectQueue_emptyTarget_mustNotBeNil {
    @try {
        EMSQueueDelegator *delegator = [EMSQueueDelegator alloc];
        [delegator setupWithQueue:self.operationQueue
                      emptyTarget:nil];
        XCTFail(@"Expected Exception when emptyTarget is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: emptyTarget");
    }
}

- (void)testDelegateToGivenQueue {
    __block NSOperationQueue *returnedQueue = nil;
    __block NSOperationQueue *initialQueue = nil;
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForDescription"];
    __weak typeof(self) weakSelf = self;
    [self.backgroundQueue addOperationWithBlock:^{
        initialQueue = [NSOperationQueue currentQueue];
        [weakSelf.queueDelegator setCompletionBlock:^(NSError *error) {
            returnedQueue = [NSOperationQueue currentQueue];
            [expectation fulfill];
        }];
        [weakSelf.queueDelegator triggerBlock];
    }];
    
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(initialQueue, self.backgroundQueue);
    XCTAssertEqualObjects(returnedQueue, self.operationQueue);
}

- (void)testDelegateToGivenQueue_sync {
    EMSCompletionBlock completionBlock = ^(NSError *error) {
    };
    
    [self.queueDelegator setCompletionBlock:completionBlock];
    
    EMSCompletionBlock returnedCompletionBlock = self.queueDelegator.completionBlock;
    
    XCTAssertEqual(returnedCompletionBlock, completionBlock);
}

- (void)testDelegateToGivenQueue_sync_sameQueue {
    NSOperationQueue *partialMockOperationQueue = OCMPartialMock(self.operationQueue);

    id delegator = [EMSQueueDelegator alloc];
    [delegator setupWithQueue:self.operationQueue
                  emptyTarget:[QueueChecker new]];
    
    [delegator proxyWithTargetObject:self.queueChecker];

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForOperation"];
    [partialMockOperationQueue addOperationWithBlock:^{
        OCMReject([partialMockOperationQueue addOperation:[OCMArg any]]);
        OCMReject([partialMockOperationQueue waitUntilAllOperationsAreFinished]);
        
        ((id <QueueCheckerProtocol>) delegator).completionBlock;
        
        [expectation fulfill];
    }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:5];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
}

- (void)testDelegateToGivenQueue_sync_wait {
    id delegator = [EMSQueueDelegator alloc];
    [delegator setupWithQueue:self.operationQueue
                  emptyTarget:[QueueChecker new]];
    
    [delegator proxyWithTargetObject:self.queueChecker];
    
    ((id <QueueCheckerProtocol>) delegator).completionBlock;
}

- (void)testDelegateToGivenQueue_sync_withoutWait {
    id delegator = [EMSQueueDelegator alloc];
    [delegator setupWithQueue:self.operationQueue
                  emptyTarget:[QueueChecker new]];
    
    [delegator proxyWithTargetObject:self.queueChecker];
    
    [((id <QueueCheckerProtocol>) delegator) setCompletionBlock:^(NSError *error) {
    }];
}

@end
