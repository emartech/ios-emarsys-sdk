#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSNotificationCenterManager.h"
#import "EMSWaiter.h"

@interface EMSNotificationCenterManagerTests : XCTestCase

@property(nonatomic, strong) EMSNotificationCenterManager *ncm;

@end

@implementation EMSNotificationCenterManagerTests

- (void)setUp {
    _ncm = [[EMSNotificationCenterManager alloc] initWithNotificationCenter:[NSNotificationCenter defaultCenter]];
}

- (void)tearDown {
    [self.ncm removeHandlers];
}

- (void)testInit_notificationCenter_mustNotBeNil {
    @try {
        [[EMSNotificationCenterManager alloc] initWithNotificationCenter:nil];
        XCTFail(@"Expected Exception when notificationCenter is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: notificationCenter");
    }
}

- (void)testInit_observers_mustNotBeNil {
    EMSNotificationCenterManager *ncm = [[EMSNotificationCenterManager alloc] initWithNotificationCenter:OCMClassMock([NSNotificationCenter class])];
    XCTAssertNotNil(ncm.observers);
}

- (void)testAddHandler {
    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"expectation"];

    [self.ncm addHandlerBlock:^{
                [exp fulfill];
            }
              forNotification:@"testNotification"];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification"
                                                        object:nil];

    [EMSWaiter waitForExpectations:@[exp]
                           timeout:10];

    XCTAssertGreaterThan([self.ncm.observers count], 0);
}

- (void)testRemoveHandlers {
    NSNotificationCenter *mockNotificationCenter = OCMClassMock([NSNotificationCenter class]);
    OCMStub([mockNotificationCenter addObserverForName:[OCMArg any]
                                                object:nil
                                                 queue:nil
                                            usingBlock:[OCMArg any]]).andReturn([NSObject new]);

    _ncm = [[EMSNotificationCenterManager alloc] initWithNotificationCenter:mockNotificationCenter];

    [self.ncm addHandlerBlock:^{
            }
              forNotification:@"1"];
    [self.ncm addHandlerBlock:^{
            }
              forNotification:@"2"];

    NSArray *observersCopy = [self.ncm.observers copy];

    [self.ncm removeHandlers];

    OCMVerify([mockNotificationCenter removeObserver:observersCopy[0]]);
    OCMVerify([mockNotificationCenter removeObserver:observersCopy[1]]);

    XCTAssertEqual([self.ncm.observers count], 0);
}

@end
