//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Kiwi.h"
#import "EMSLogger.h"
#import "EMSShard.h"
#import "FakeShardRepository.h"
#import "EMSWaiter.h"

@interface EMSLoggerTests : XCTestCase

@property(nonatomic, strong) NSString *type;
@property(nonatomic, strong) NSDictionary<NSString *, id> *data;
@property(nonatomic, strong) NSDate *timestamp;
@property(nonatomic, strong) NSString *shardId;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *uuidProvider;
@property(nonatomic, strong) EMSShard *shard;
@property(nonatomic, strong) id logEntry;
@property(nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation EMSLoggerTests

- (void)setUp {
    _type = @"general_topic";
    _data = @{@"key1": @"value1"};
    _timestamp = [NSDate date];
    _shardId = @"shardId";

    _shard = [[EMSShard alloc] initWithShardId:self.shardId
                                          type:self.type
                                          data:self.data
                                     timestamp:self.timestamp
                                           ttl:FLT_MAX];

    _timestampProvider = [EMSTimestampProvider mock];
    [[self.timestampProvider should] receive:@selector(provideTimestamp)
                                   andReturn:self.timestamp];
    _uuidProvider = [EMSUUIDProvider mock];
    [[self.uuidProvider should] receive:@selector(provideUUIDString)
                              andReturn:self.shardId];

    _logEntry = [KWMock mockForProtocol:@protocol(EMSLogEntryProtocol)];
    [[self.logEntry should] receive:@selector(topic)
                          andReturn:self.type];
    [[self.logEntry should] receive:@selector(data)
                          andReturn:self.data];
    _operationQueue = [NSOperationQueue new];
    self.operationQueue.name = @"operationQueueForTesting";
}

- (void)tearDown {
    _type = nil;
    _data = nil;
    _timestamp = nil;
    _shardId = nil;
    _shard = nil;
    _timestampProvider = nil;
    _uuidProvider = nil;
    _logEntry = nil;
    _operationQueue = nil;
}

- (void)testInitShouldThrowExceptionWhenShardRepositoryIsNil {
    @try {
        [[EMSLogger alloc] initWithShardRepository:nil
                                    opertaionQueue:self.operationQueue
                                 timestampProvider:self.timestampProvider
                                      uuidProvider:self.uuidProvider];
        XCTFail(@"Expected Exception when shardRepository is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: shardRepository"]);
    }
}

- (void)testInitShouldThrowExceptionWhenOperationQueueIsNil {
    @try {
        [[EMSLogger alloc] initWithShardRepository:[EMSShardRepository mock]
                                    opertaionQueue:nil
                                 timestampProvider:self.timestampProvider
                                      uuidProvider:self.uuidProvider];
        XCTFail(@"Expected Exception when operationQueue is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: operationQueue"]);
    }
}

- (void)testInitShouldThrowExceptionWhenTimestampProviderIsNil {
    @try {
        [[EMSLogger alloc] initWithShardRepository:[EMSShardRepository mock]
                                    opertaionQueue:self.operationQueue
                                 timestampProvider:nil
                                      uuidProvider:self.uuidProvider];
        XCTFail(@"Expected Exception when timestampProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: timestampProvider"]);
    }
}

- (void)testInitShouldThrowExceptionWhenUuidProviderIsNil {
    @try {
        [[EMSLogger alloc] initWithShardRepository:[EMSShardRepository mock]
                                    opertaionQueue:self.operationQueue
                                 timestampProvider:self.timestampProvider
                                      uuidProvider:nil];
        XCTFail(@"Expected Exception when uuidProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: uuidProvider"]);
    }
}

- (void)testLogShouldInsertEntryToShardRepository {
    EMSShardRepository *shardRepository = [EMSShardRepository mock];
    EMSLogger *logger = [[EMSLogger alloc] initWithShardRepository:shardRepository
                                                    opertaionQueue:self.operationQueue
                                                 timestampProvider:self.timestampProvider
                                                      uuidProvider:self.uuidProvider];

    [[shardRepository should] receive:@selector(add:)
                            withCount:1
                            arguments:self.shard];

    [logger log:self.logEntry];
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
                                                 timestampProvider:self.timestampProvider
                                                      uuidProvider:self.uuidProvider];

    [logger log:self.logEntry];

    [EMSWaiter waitForExpectations:@[expectation]];

    XCTAssertNotNil(returnedOperationQueue);
    XCTAssertEqual(returnedOperationQueue, self.operationQueue);
}

@end
