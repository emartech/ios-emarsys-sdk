//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSLogger.h"
#import "EMSShard.h"
#import "FakeShardRepository.h"
#import "EMSWaiter.h"
#import "EMSStorage.h"
#import "EMSRemoteConfig.h"
#import "EMSLogLevel.h"

@interface EMSLoggerTests : XCTestCase

@property(nonatomic, strong) NSString *topic;
@property(nonatomic, strong) NSDictionary<NSString *, id> *data;
@property(nonatomic, strong) NSDate *timestamp;
@property(nonatomic, strong) NSString *shardId;
@property(nonatomic, strong) EMSTimestampProvider *mockTimestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *mockUuidProvider;
@property(nonatomic, strong) EMSStorage *mockStorage;
@property(nonatomic, strong) id mockLogEntry;
@property(nonatomic, strong) NSOperationQueue *operationQueue;
@property(nonatomic, strong) NSOperationQueue *runnerQueue;
@property(nonatomic, strong) EMSLogger *logger;

@end

@implementation EMSLoggerTests

- (void)setUp {
    _topic = @"general_topic";
    _data = @{
            @"key1": @"value1"
    };
    _timestamp = [NSDate date];
    _shardId = @"shardId";

    _mockTimestampProvider = OCMClassMock([EMSTimestampProvider class]);
    OCMStub([self.mockTimestampProvider provideTimestamp]).andReturn(self.timestamp);
    _mockUuidProvider = OCMClassMock([EMSUUIDProvider class]);
    OCMStub([self.mockUuidProvider provideUUIDString]).andReturn(self.shardId);
    _mockStorage = OCMClassMock([EMSStorage class]);
    OCMStub([self.mockStorage numberForKey:@"EMSLogLevelKey"]).andReturn(@(LogLevelDebug));

    id logEntry = OCMProtocolMock(@protocol(EMSLogEntryProtocol));

    OCMStub([logEntry data]).andReturn(self.data);
    OCMStub([logEntry topic]).andReturn(self.topic);

    _mockLogEntry = logEntry;

    _operationQueue = [NSOperationQueue new];
    self.operationQueue.name = @"operationQueueForTesting";
    _runnerQueue = [NSOperationQueue new];
    self.runnerQueue.name = @"testRunnerQueue";

    _logger = [[EMSLogger alloc] initWithShardRepository:OCMClassMock([EMSShardRepository class])
                                          opertaionQueue:self.operationQueue
                                       timestampProvider:self.mockTimestampProvider
                                            uuidProvider:self.mockUuidProvider
                                                 storage:self.mockStorage];
}

- (void)tearDown {
    _topic = nil;
    _data = nil;
    _timestamp = nil;
    _shardId = nil;
    _mockTimestampProvider = nil;
    _mockUuidProvider = nil;
    _mockLogEntry = nil;
    _mockStorage = nil;
    _operationQueue = nil;
}

- (void)testInitShouldThrowExceptionWhenShardRepositoryIsNil {
    @try {
        [[EMSLogger alloc] initWithShardRepository:nil
                                    opertaionQueue:self.operationQueue
                                 timestampProvider:self.mockTimestampProvider
                                      uuidProvider:self.mockUuidProvider
                                           storage:self.mockStorage];
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
                                      uuidProvider:self.mockUuidProvider
                                           storage:self.mockStorage];
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
                                      uuidProvider:self.mockUuidProvider
                                           storage:self.mockStorage];
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
                                      uuidProvider:nil
                                           storage:self.mockStorage];
        XCTFail(@"Expected Exception when uuidProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: uuidProvider"]);
    }
}

- (void)testInit_storage_mustNotBeNil {
    @try {
        [[EMSLogger alloc] initWithShardRepository:OCMClassMock([EMSShardRepository class])
                                    opertaionQueue:self.operationQueue
                                 timestampProvider:self.mockTimestampProvider
                                      uuidProvider:self.mockUuidProvider
                                           storage:nil];
        XCTFail(@"Expected Exception when storage is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: storage"]);
    }
}

- (void)testInit_shouldSetStoredLogLevel {
    XCTAssertEqual(self.logger.logLevel, LogLevelDebug);
}

- (void)testInit_shouldSetLogLevelToError_whenStorageIsEmpty {
    EMSStorage *emptyMockStorage = OCMClassMock([EMSStorage class]);
    EMSLogger *logger = [[EMSLogger alloc] initWithShardRepository:OCMClassMock([EMSShardRepository class])
                                                    opertaionQueue:self.operationQueue
                                                 timestampProvider:self.mockTimestampProvider
                                                      uuidProvider:self.mockUuidProvider
                                                           storage:emptyMockStorage];

    XCTAssertEqual(logger.logLevel, LogLevelError);
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
                                                      uuidProvider:self.mockUuidProvider
                                                           storage:self.mockStorage];

    [self.runnerQueue addOperationWithBlock:^{
        [logger log:self.mockLogEntry
              level:LogLevelError];
    }];

    [EMSWaiter waitForExpectations:@[expectation]];

    OCMVerify([partialMockRepository add:[self shardWithLogLevel:LogLevelError
                                                  additionalData:@{@"queue": @"testRunnerQueue"}]]);
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
                                                      uuidProvider:self.mockUuidProvider
                                                           storage:self.mockStorage];

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
                                                      uuidProvider:self.mockUuidProvider
                                                           storage:self.mockStorage];


    id logEntry = OCMProtocolMock(@protocol(EMSLogEntryProtocol));

    OCMStub([logEntry data]).andReturn(@{@"url": @"https://log-dealer.eservice.emarsys.net/v1/log"});
    OCMStub([logEntry topic]).andReturn(@"log_request");

    [logger log:logEntry
          level:LogLevelInfo];

    [XCTWaiter waitForExpectations:@[expectation]
                           timeout:1];
}

- (void)testUpdate {
    EMSRemoteConfig *remoteConfig = [[EMSRemoteConfig alloc] initWithEventService:nil
                                                                    clientService:nil
                                                                   predictService:nil
                                                            mobileEngageV2Service:nil
                                                                  deepLinkService:nil
                                                                     inboxService:nil
                                                            v3MessageInboxService:nil
                                                                         logLevel:LogLevelDebug
                                                                         features:nil];

    [self.logger updateWithRemoteConfig:remoteConfig];

    OCMVerify([self.mockStorage setNumber:@(LogLevelDebug)
                                   forKey:@"EMSLogLevelKey"]);
    XCTAssertEqual(self.logger.logLevel, LogLevelDebug);
}

- (void)testReset {
    [self.logger reset];

    OCMVerify([self.mockStorage setNumber:nil
                                   forKey:@"EMSLogLevelKey"]);
    XCTAssertEqual(self.logger.logLevel, LogLevelError);
}

- (void)testShouldNotLog_whenLogLevelOfLogEntry_isBelowOfLogLevel {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];

    FakeShardRepository *shardRepository = [[FakeShardRepository alloc] initWithCompletionBlock:^(NSOperationQueue *currentQueue) {
        [expectation fulfill];
    }];

    EMSShardRepository *partialMockRepository = OCMPartialMock(shardRepository);

    OCMReject([partialMockRepository add:[self shardWithLogLevel:LogLevelInfo
                                                  additionalData:@{@"queue": @"testRunnerQueue"}]]);

    EMSLogger *logger = [[EMSLogger alloc] initWithShardRepository:partialMockRepository
                                                    opertaionQueue:self.operationQueue
                                                 timestampProvider:self.mockTimestampProvider
                                                      uuidProvider:self.mockUuidProvider
                                                           storage:self.mockStorage];

    [logger setLogLevel:LogLevelWarn];

    [self.runnerQueue addOperationWithBlock:^{
        [logger log:self.mockLogEntry
              level:LogLevelInfo];
    }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:0.5];
    XCTAssertEqual(waiterResult, XCTWaiterResultTimedOut);
}

- (void)testShouldLog_whenLogLevelOfLogEntry_isBelowOfLogLevel_butIsAppStartLog {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];

    FakeShardRepository *shardRepository = [[FakeShardRepository alloc] initWithCompletionBlock:^(NSOperationQueue *currentQueue) {
        [expectation fulfill];
    }];

    EMSShardRepository *partialMockRepository = OCMPartialMock(shardRepository);

    EMSLogger *logger = [[EMSLogger alloc] initWithShardRepository:partialMockRepository
                                                    opertaionQueue:self.operationQueue
                                                 timestampProvider:self.mockTimestampProvider
                                                      uuidProvider:self.mockUuidProvider
                                                           storage:self.mockStorage];
    id logEntry = OCMProtocolMock(@protocol(EMSLogEntryProtocol));

    OCMStub([logEntry data]).andReturn(self.data);
    OCMStub([logEntry topic]).andReturn(@"app:start");

    [logger setLogLevel:LogLevelError];

    [self.runnerQueue addOperationWithBlock:^{
        [logger log:logEntry
              level:LogLevelInfo];
    }];

    [EMSWaiter waitForExpectations:@[expectation]];


    NSMutableDictionary *mutableData = [self.data mutableCopy];
    mutableData[@"level"] = @"INFO";
    mutableData[@"queue"] = @"testRunnerQueue";

    OCMVerify([partialMockRepository add:[[EMSShard alloc] initWithShardId:self.shardId
                                                                      type:@"app:start"
                                                                      data:[NSDictionary dictionaryWithDictionary:mutableData]
                                                                 timestamp:self.timestamp
                                                                       ttl:FLT_MAX]]);
}

- (void)testLogLevel_useDBSafeDictionaryData {
    NSDate *date = [NSDate date];
    self.data = @{
            @"key1": @"value1",
            @"key2": date
    };

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];

    FakeShardRepository *shardRepository = [[FakeShardRepository alloc] initWithCompletionBlock:^(NSOperationQueue *currentQueue) {
        [expectation fulfill];
    }];

    EMSShardRepository *partialMockRepository = OCMPartialMock(shardRepository);

    EMSLogger *logger = [[EMSLogger alloc] initWithShardRepository:partialMockRepository
                                                    opertaionQueue:self.operationQueue
                                                 timestampProvider:self.mockTimestampProvider
                                                      uuidProvider:self.mockUuidProvider
                                                           storage:self.mockStorage];
    id logEntry = OCMProtocolMock(@protocol(EMSLogEntryProtocol));

    OCMStub([logEntry data]).andReturn(self.data);
    OCMStub([logEntry topic]).andReturn(@"testTopic");

    [logger setLogLevel:LogLevelTrace];

    [self.runnerQueue addOperationWithBlock:^{
        [logger log:logEntry
              level:LogLevelInfo];
    }];

    [EMSWaiter waitForExpectations:@[expectation]];


    NSMutableDictionary *mutableData = [@{
            @"key1": @"value1",
            @"key2": [date description]
    } mutableCopy];
    mutableData[@"level"] = @"INFO";
    mutableData[@"queue"] = @"testRunnerQueue";

    OCMVerify([partialMockRepository add:[[EMSShard alloc] initWithShardId:self.shardId
                                                                      type:@"testTopic"
                                                                      data:[NSDictionary dictionaryWithDictionary:mutableData]
                                                                 timestamp:self.timestamp
                                                                       ttl:FLT_MAX]]);
}

- (void)testConsoleLogLevels {
    XCTAssertEqualObjects([self.logger consoleLogLevels], @[EMSLogLevel.basic]);
}

- (EMSShard *)shardWithLogLevel:(LogLevel)level
                 additionalData:(NSDictionary *)additionalData {
    NSMutableDictionary *mutableData = [self.data mutableCopy];
    if (level == LogLevelDebug) {
        mutableData[@"level"] = @"DEBUG";
    } else if (level == LogLevelInfo) {
        mutableData[@"level"] = @"INFO";
    } else if (level == LogLevelError) {
        mutableData[@"level"] = @"ERROR";
    }
    if (additionalData) {
        [mutableData addEntriesFromDictionary:additionalData];
    }
    return [[EMSShard alloc] initWithShardId:self.shardId
                                        type:self.topic
                                        data:[NSDictionary dictionaryWithDictionary:mutableData]
                                   timestamp:self.timestamp
                                         ttl:FLT_MAX];
}

@end
