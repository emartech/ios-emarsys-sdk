//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSQueueDelegator.h"
#import "EMSBlocks.h"
#import "EMSDispatchWaiter.h"

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
@property(nonatomic, strong) EMSDispatchWaiter *dispatchWaiter;

@end

@implementation EMSQueueDelegatorTests

- (void)setUp {
    _operationQueue = [NSOperationQueue new];
    [self.operationQueue setName:@"testOperationQueue"];
    [self.operationQueue setMaxConcurrentOperationCount:1];
    _backgroundQueue = [NSOperationQueue new];
    [self.backgroundQueue setName:@"testBackgroundQueue"];
    
    _queueChecker = [QueueChecker new];
    
    _dispatchWaiter = [EMSDispatchWaiter new];
    
    id queueDelegator = [EMSQueueDelegator alloc];
    [queueDelegator setupWithQueue:self.operationQueue
                       emptyTarget:[QueueChecker new]
                    dispatchWaiter:self.dispatchWaiter];
    
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
                      emptyTarget:[QueueChecker new]
                   dispatchWaiter:self.dispatchWaiter];
        XCTFail(@"Expected Exception when queue is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: queue");
    }
}

- (void)testProxyWithTargetObjectQueue_emptyTarget_mustNotBeNil {
    @try {
        EMSQueueDelegator *delegator = [EMSQueueDelegator alloc];
        [delegator setupWithQueue:self.operationQueue
                      emptyTarget:nil
                   dispatchWaiter:self.dispatchWaiter];
        XCTFail(@"Expected Exception when emptyTarget is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: emptyTarget");
    }
}

- (void)testProxyWithTargetObjectQueue_dispatchWaiter_mustNotBeNil {
    @try {
        EMSQueueDelegator *delegator = [EMSQueueDelegator alloc];
        [delegator setupWithQueue:self.operationQueue
                      emptyTarget:[QueueChecker new]
                   dispatchWaiter:nil];
        XCTFail(@"Expected Exception when dispatchWaiter is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: dispatchWaiter");
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

- (void)testDelegateToGivenQueue_sync_wait {
    id mockDispatchWaiter = OCMStrictClassMock([EMSDispatchWaiter class]);
    [mockDispatchWaiter setExpectationOrderMatters:YES];
    
    OCMExpect([mockDispatchWaiter enter]);
    OCMExpect([mockDispatchWaiter waitWithInterval:5]);
    OCMExpect([mockDispatchWaiter exit];);
    
    id delegator = [EMSQueueDelegator alloc];
    [delegator setupWithQueue:self.operationQueue
                  emptyTarget:[QueueChecker new]
               dispatchWaiter:mockDispatchWaiter];
    
    [delegator proxyWithTargetObject:self.queueChecker];
    
    ((id <QueueCheckerProtocol>) delegator).completionBlock;
}

- (void)testDelegateToGivenQueue_sync_withoutWait {
    EMSDispatchWaiter *mockDispatchWaiter = OCMClassMock([EMSDispatchWaiter class]);
    
    OCMReject([mockDispatchWaiter enter]);
    OCMReject([mockDispatchWaiter exit];);
    OCMReject([mockDispatchWaiter waitWithInterval:5]);
    
    id delegator = [EMSQueueDelegator alloc];
    [delegator setupWithQueue:self.operationQueue
                  emptyTarget:[QueueChecker new]
               dispatchWaiter:mockDispatchWaiter];
    
    [delegator proxyWithTargetObject:self.queueChecker];
    
    
    [((id <QueueCheckerProtocol>) delegator) setCompletionBlock:^(NSError *error) {
    }];
}

@end
