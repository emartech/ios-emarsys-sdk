//
//  Copyright © 2021 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSWrapperChecker.h"
#import "EMSDispatchWaiter.h"
#import "XCTestCase+Helper.h"

@interface EMSWrapperCheckerTests : XCTestCase

@property(nonatomic, strong) EMSWrapperChecker *wrapperChecker;
@property(nonatomic, strong) NSOperationQueue *queue;
@property(nonatomic, strong) EMSDispatchWaiter *waiter;
@property(nonatomic, strong) NSObject *observer;

@end

@implementation EMSWrapperCheckerTests

- (void)setUp {
    _queue = [self createTestOperationQueue];

    _waiter = [EMSDispatchWaiter new];
    _wrapperChecker = [[EMSWrapperChecker alloc] initWithOperationQueue:self.queue
                                                                 waiter:self.waiter];
}

- (void)tearDown {
    [self tearDownOperationQueue:self.queue];
    if (self.observer) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
        _observer = nil;
    }
}

- (void)testInit_queue_mustNotBeNil {
    @try {
        [[EMSWrapperChecker alloc] initWithOperationQueue:nil
                                                   waiter:self.waiter];
        XCTFail(@"Expected Exception when queue is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: queue");
    }
}

- (void)testInit_waiter_mustNotBeNil {
    @try {
        [[EMSWrapperChecker alloc] initWithOperationQueue:self.queue
                                                   waiter:nil];
        XCTFail(@"Expected Exception when waiter is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: waiter");
    }
}

- (void)testWrapper_wrapperExists {
    _observer = [NSNotificationCenter.defaultCenter addObserverForName:@"EmarsysSDKWrapperCheckerNotification"
                                                                object:nil
                                                                 queue:nil
                                                            usingBlock:^(NSNotification *note) {
                                                                [NSNotificationCenter.defaultCenter postNotificationName:@"EmarsysSDKWrapperExist"
                                                                                                                  object:@"testWrapper"];
                                                            }];
    NSString *wrapper = self.wrapperChecker.wrapper;

    XCTAssertEqualObjects(wrapper, @"testWrapper");
}

- (void)testWrapper_wrapperNotExists {
    NSString *wrapper = self.wrapperChecker.wrapper;

    XCTAssertEqualObjects(wrapper, @"none");
}

@end
