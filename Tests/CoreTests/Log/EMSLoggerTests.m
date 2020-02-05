//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSLogger.h"
#import "EMSShard.h"
#import "FakeShardRepository.h"
#import "EMSWaiter.h"

@interface EMSLoggerTests : XCTestCase

@property(nonatomic, strong) NSString *topic;
@property(nonatomic, strong) NSDictionary<NSString *, id> *data;
@property(nonatomic, strong) NSDate *timestamp;
@property(nonatomic, strong) NSString *shardId;
@property(nonatomic, strong) EMSTimestampProvider *mockTimestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *mockUuidProvider;
@property(nonatomic, strong) id mockLogEntry;
@property(nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation EMSLoggerTests

- (void)setUp {
    _topic = @"general_topic";
    _data = @{@"key1": @"value1"};
    _timestamp = [NSDate date];
    _shardId = @"shardId";

    _mockTimestampProvider = OCMClassMock([EMSTimestampProvider class]);
    OCMStub([self.mockTimestampProvider provideTimestamp]).andReturn(self.timestamp);
    _mockUuidProvider = OCMClassMock([EMSUUIDProvider class]);
    OCMStub([self.mockUuidProvider provideUUIDString]).andReturn(self.shardId);

    id logEntry = OCMProtocolMock(@protocol(EMSLogEntryProtocol));

    OCMStub([logEntry data]).andReturn(self.data);
    OCMStub([logEntry topic]).andReturn(self.topic);

    _mockLogEntry = logEntry;

    _operationQueue = [NSOperationQueue new];
    self.operationQueue.name = @"operationQueueForTesting";
}

- (void)tearDown {
    _topic = nil;
    _data = nil;
    _timestamp = nil;
    _shardId = nil;
    _mockTimestampProvider = nil;
    _mockUuidProvider = nil;
    _mockLogEntry = nil;
    _operationQueue = nil;
}

- (void)testInitShouldThrowExceptionWhenShardRepositoryIsNil {
    @try {
        [[EMSLogger alloc] initWithShardRepository:nil
                                    opertaionQueue:self.operationQueue
                                 timestampProvider:self.mockTimestampProvider
                                      uuidProvider:self.mockUuidProvider];
        XCTFail(@"Expected Exception when shardRepository is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: shardRepository"]);
    }
}

- (void)testInitShouldThrowExceptionWhenOperationQueueIsNil {
    @try {
        [[EMSLogger alloc] initWithShardRepository:OCMClassMock([EMSShardRepository class])
                                    opertaionQueue:nil
                                 timestampProvider:self.mockTimestampProvider
                                      uuidProvider:self.mockUuidProvider];
        XCTFail(@"Expected Exception when operationQueue is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: operationQueue"]);
    }
}

- (void)testInitShouldThrowExceptionWhenTimestampProviderIsNil {
    @try {
        [[EMSLogger alloc] initWithShardRepository:OCMClassMock([EMSShardRepository class])
                                    opertaionQueue:self.operationQueue
                                 timestampProvider:nil
                                      uuidProvider:self.mockUuidProvider];
        XCTFail(@"Expected Exception when timestampProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: timestampProvider"]);
    }
}

- (void)testInitShouldThrowExceptionWhenUuidProviderIsNil {
    @try {
        [[EMSLogger alloc] initWithShardRepository:OCMClassMock([EMSShardRepository class])
                                    opertaionQueue:self.operationQueue
                                 timestampProvider:self.mockTimestampProvider
                                      uuidProvider:nil];
        XCTFail(@"Expected Exception when uuidProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: uuidProvider"]);
    }
}

- (void)testLogShouldInsertEntryToShardRepository {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];

    FakeShardRepository *shardRepository = [[FakeShardRepository alloc] initWithCompletionBlock:^(NSOperationQueue *currentQueue) {
        [expectation fulfill];
    }];

    EMSShardRepository *partialMockRepository = OCMPartialMock(shardRepository);

    EMSLogger *logger = [[EMSLogger alloc] initWithShardRepository:partialMockRepository
                                                    opertaionQueue:self.operationQueue
                                                 timestampProvider:self.mockTimestampProvider
                                                      uuidProvider:self.mockUuidProvider];

    [logger log:self.mockLogEntry
          level:LogLevelError];

    [EMSWaiter waitForExpectations:@[expectation]];

    OCMVerify([partialMockRepository add:[self shardWithLogLevel:LogLevelError]]);


}

- (void)testLogShouldCallRepositoryOnTheGivenOperationQueue {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];

    __block NSOperationQueue *returnedOperationQueue = nil;
    FakeShardRepository *shardRepository = [[FakeShardRepository alloc] initWithCompletionBlock:^(NSOperationQueue *currentQueue) {
        returnedOperationQueue = currentQueue;
        [expectation fulfill];
    }];

    EMSLogger *logger = [[EMSLogger alloc] initWithShardRepository:shardRepository
                                                    opertaionQueue:self.operationQueue
                                                 timestampProvider:self.mockTimestampProvider
                                                      uuidProvider:self.mockUuidProvider];

    [logger log:self.mockLogEntry
          level:LogLevelError];

    [EMSWaiter waitForExpectations:@[expectation]];

    XCTAssertNotNil(returnedOperationQueue);
    XCTAssertEqual(returnedOperationQueue, self.operationQueue);
}


- (void)testLog_shouldNotLogLog_whenURLIsLogDealerAndTopicIsLogRequest {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];

    FakeShardRepository *shardRepository = [[FakeShardRepository alloc] initWithCompletionBlock:^(NSOperationQueue *currentQueue) {
        [expectation fulfill];
    }];

    EMSShardRepository *partialMockRepository = OCMPartialMock(shardRepository);

    OCMReject([partialMockRepository add:[OCMArg any]]);

    EMSLogger *logger = [[EMSLogger alloc] initWithShardRepository:partialMockRepository
                                                    opertaionQueue:self.operationQueue
                                                 timestampProvider:self.mockTimestampProvider
                                                      uuidProvider:self.mockUuidProvider];


    id logEntry = OCMProtocolMock(@protocol(EMSLogEntryProtocol));

    OCMStub([logEntry data]).andReturn(@{@"url": @"https://log-dealer.eservice.emarsys.net/v1/log"});
    OCMStub([logEntry topic]).andReturn(@"log_request");

    [logger log:logEntry
          level:LogLevelInfo];

    [XCTWaiter waitForExpectations:@[expectation]
                           timeout:1];
}

- (EMSShard *)shardWithLogLevel:(LogLevel)level {
    NSMutableDictionary *mutableData = [self.data mutableCopy];
    if (level == LogLevelDebug) {
        mutableData[@"level"] = @"DEBUG";
    } else if (level == LogLevelInfo) {
        mutableData[@"level"] = @"INFO";
    } else if (level == LogLevelError) {
        mutableData[@"level"] = @"ERROR";
    }
    return [[EMSShard alloc] initWithShardId:self.shardId
                                        type:self.topic
                                        data:[NSDictionary dictionaryWithDictionary:mutableData]
                                   timestamp:self.timestamp
                                         ttl:FLT_MAX];
}

@end
