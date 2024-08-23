//
//  Copyright © 2021 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSWrapperChecker.h"
#import "EMSDispatchWaiter.h"
#import "XCTestCase+Helper.h"
#import "EmarsysTestUtils.h"
#import "EMSStorage.h"

@interface EMSWrapperCheckerTests : XCTestCase

@property(nonatomic, strong) EMSWrapperChecker *wrapperChecker;
@property(nonatomic, strong) NSOperationQueue *queue;
@property(nonatomic, strong) EMSDispatchWaiter *waiter;
@property(nonatomic, strong) NSObject *observer;
@property(nonatomic, strong) id<EMSStorageProtocol> storage;

@end

@implementation EMSWrapperCheckerTests

- (void)setUp {
    _queue = [self createTestOperationQueue];
    _waiter = [EMSDispatchWaiter new];
    _storage = OCMClassMock([EMSStorage class]);
    _wrapperChecker = [[EMSWrapperChecker alloc] initWithOperationQueue:self.queue
                                                                 waiter:self.waiter
                                                                storage:self.storage];
}

- (void)tearDown {
    [EmarsysTestUtils tearDownOperationQueue:self.queue];
    if (self.observer) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
        _observer = nil;
    }
}

- (void)testInit_queue_mustNotBeNil {
    @try {
        [[EMSWrapperChecker alloc] initWithOperationQueue:nil
                                                   waiter:self.waiter
                                                  storage:self.storage];
        XCTFail(@"Expected Exception when queue is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: queue");
    }
}

- (void)testInit_waiter_mustNotBeNil {
    @try {
        [[EMSWrapperChecker alloc] initWithOperationQueue:self.queue
                                                   waiter:nil
                                                  storage:self.storage];
        XCTFail(@"Expected Exception when waiter is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: waiter");
    }
}

- (void)testInit_storage_mustNotBeNil {
    @try {
        [[EMSWrapperChecker alloc] initWithOperationQueue:self.queue
                                                   waiter:self.waiter
                                                  storage:nil];
        XCTFail(@"Expected Exception when storage is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: storage");
    }
}

- (void)testWrapper_wrapperExists {
    XCTestExpectation *expectation = [self expectationForNotification:@"EmarsysSDKWrapperCheckerNotification" object:nil handler:^BOOL(NSNotification * _Nonnull notification) {
                [NSNotificationCenter.defaultCenter postNotificationName:@"EmarsysSDKWrapperExist"
                                                                  object:@"testWrapper"];
        return YES;
    }];

    self.wrapperChecker.wrapper;
    
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:2.0];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    
    [self waitATickOnOperationQueue:self.queue];
    
    NSString *wrapper = self.wrapperChecker.wrapper;
    
    XCTAssertEqualObjects(wrapper, @"testWrapper");
}

- (void)testWrapper_wrapperNotExists {
    NSString *wrapper = self.wrapperChecker.wrapper;

    XCTAssertEqualObjects(wrapper, @"none");
}

@end
