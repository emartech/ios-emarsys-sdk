//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSBatchingShardTrigger.h"
#import "EMSListChunker.h"
#import "EMSRequestManager.h"
#import "EMSShard.h"
#import "EMSRequestFromShardsMapperProtocol.h"
#import "EMSPredicate.h"
#import "EMSFilterByValuesSpecification.h"
#import "EMSSchemaContract.h"
#import "EMSConnectionWatchdog.h"

@interface EMSBatchingShardTriggerTests : XCTestCase

@property(nonatomic, strong) EMSBatchingShardTrigger *trigger;
@property(nonatomic, strong) id shardRepository;
@property(nonatomic, strong) id specification;
@property(nonatomic, strong) id mapper;
@property(nonatomic, strong) EMSListChunker *chunker;
@property(nonatomic, strong) id predicate;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSConnectionWatchdog *connectionWatchdog;
@property(nonatomic, strong) NSArray *shards;
@property(nonatomic, strong) NSArray<NSArray *> *chunkedShards;
@property(nonatomic, strong) NSArray *requestModels;

@end

@implementation EMSBatchingShardTriggerTests

- (void)setUp {
    _shardRepository = OCMProtocolMock(@protocol(EMSShardRepositoryProtocol));
    _specification = OCMProtocolMock(@protocol(EMSSQLSpecificationProtocol));
    _mapper = OCMProtocolMock(@protocol(EMSRequestFromShardsMapperProtocol));
    _chunker = OCMClassMock([EMSListChunker class]);
    _predicate = OCMClassMock([EMSPredicate class]);
    _requestManager = OCMClassMock([EMSRequestManager class]);
    _connectionWatchdog = OCMClassMock([EMSConnectionWatchdog class]);
    _shards = [self shardMocks];
    _chunkedShards = @[
            @[self.shards[0], self.shards[1], self.shards[2]],
            @[self.shards[3], self.shards[4]]
    ];
    _requestModels = @[
            OCMClassMock([EMSRequestModel class]),
            OCMClassMock([EMSRequestModel class])];

    OCMStub([self.shardRepository query:self.specification]).andReturn(self.shards);

    _trigger = [self persistentTrigger];
}

- (void)testInit_shardRepository_mustNotBeNil {
    @try {
        [[EMSBatchingShardTrigger alloc] initWithRepository:nil
                                              specification:self.specification
                                                     mapper:self.mapper
                                                    chunker:self.chunker
                                                  predicate:self.predicate
                                             requestManager:self.requestManager
                                                 persistent:NO
                                         connectionWatchdog:self.connectionWatchdog];
        XCTFail(@"Expected Exception when shardRepository is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: shardRepository");
    }
}

- (void)testInit_specification_mustNotBeNil {
    @try {
        [[EMSBatchingShardTrigger alloc] initWithRepository:self.shardRepository
                                              specification:nil
                                                     mapper:self.mapper
                                                    chunker:self.chunker
                                                  predicate:self.predicate
                                             requestManager:self.requestManager
                                                 persistent:NO
                                         connectionWatchdog:self.connectionWatchdog];
        XCTFail(@"Expected Exception when specification is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: specification");
    }
}

- (void)testInit_mapper_mustNotBeNil {
    @try {
        [[EMSBatchingShardTrigger alloc] initWithRepository:self.shardRepository
                                              specification:self.specification
                                                     mapper:nil
                                                    chunker:self.chunker
                                                  predicate:self.predicate
                                             requestManager:self.requestManager
                                                 persistent:NO
                                         connectionWatchdog:self.connectionWatchdog];
        XCTFail(@"Expected Exception when mapper is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: mapper");
    }
}

- (void)testInit_chunker_mustNotBeNil {
    @try {
        [[EMSBatchingShardTrigger alloc] initWithRepository:self.shardRepository
                                              specification:self.specification
                                                     mapper:self.mapper
                                                    chunker:nil
                                                  predicate:self.predicate
                                             requestManager:self.requestManager
                                                 persistent:NO
                                         connectionWatchdog:self.connectionWatchdog];
        XCTFail(@"Expected Exception when chunker is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: chunker");
    }
}

- (void)testInit_predicate_mustNotBeNil {
    @try {
        [[EMSBatchingShardTrigger alloc] initWithRepository:self.shardRepository
                                              specification:self.specification
                                                     mapper:self.mapper
                                                    chunker:self.chunker
                                                  predicate:nil
                                             requestManager:self.requestManager
                                                 persistent:NO
                                         connectionWatchdog:self.connectionWatchdog];
        XCTFail(@"Expected Exception when predicate is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: predicate");
    }
}

- (void)testInit_requestManager_mustNotBeNil {
    @try {
        [[EMSBatchingShardTrigger alloc] initWithRepository:self.shardRepository
                                              specification:self.specification
                                                     mapper:self.mapper
                                                    chunker:self.chunker
                                                  predicate:self.predicate
                                             requestManager:nil
                                                 persistent:NO
                                         connectionWatchdog:self.connectionWatchdog];
        XCTFail(@"Expected Exception when requestManager is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestManager");
    }
}

- (void)testInit_connectionWatchdog_mustNotBeNil {
    @try {
        [[EMSBatchingShardTrigger alloc] initWithRepository:self.shardRepository
                                              specification:self.specification
                                                     mapper:self.mapper
                                                    chunker:self.chunker
                                                  predicate:self.predicate
                                             requestManager:self.requestManager
                                                 persistent:NO
                                         connectionWatchdog:nil];
        XCTFail(@"Expected Exception when connectionWatchdog is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: connectionWatchdog");
    }
}

- (void)testTriggerBlock_persistent_submitsRequestModels_toRequestManager {
    OCMStub([self.predicate evaluate:self.shards]).andReturn(YES);
    OCMStub([self.chunker chunk:self.shards]).andReturn(self.chunkedShards);
    OCMStub([self.mapper requestFromShards:self.chunkedShards[0]]).andReturn(self.requestModels[0]);
    OCMStub([self.mapper requestFromShards:self.chunkedShards[1]]).andReturn(self.requestModels[1]);
    OCMStub([self.connectionWatchdog isConnected]).andReturn(YES);

    [self.trigger trigger];

    for (EMSRequestModel *requestModel in self.requestModels) {
        OCMVerify([self.requestManager submitRequestModel:requestModel
                                      withCompletionBlock:nil]);
    }
}

- (void)testTriggerBlock_persistent_shouldNotSubmitsRequestModels_toRequestManager_noConnection {
    for (EMSRequestModel *requestModel in self.requestModels) {
        OCMReject([self.requestManager submitRequestModel:requestModel
                                      withCompletionBlock:nil]);
    }
    OCMReject([self.shardRepository remove:[OCMArg any]]);

    OCMStub([self.predicate evaluate:self.shards]).andReturn(YES);
    OCMStub([self.chunker chunk:self.shards]).andReturn(self.chunkedShards);
    OCMStub([self.mapper requestFromShards:self.chunkedShards[0]]).andReturn(self.requestModels[0]);
    OCMStub([self.mapper requestFromShards:self.chunkedShards[1]]).andReturn(self.requestModels[1]);
    OCMStub([self.connectionWatchdog isConnected]).andReturn(NO);

    [self.trigger trigger];
}

- (void)testTriggerBlock_transient_submitsRequestModels_toRequestManager {
    OCMStub([self.predicate evaluate:self.shards]).andReturn(YES);
    OCMStub([self.chunker chunk:self.shards]).andReturn(self.chunkedShards);
    OCMStub([self.mapper requestFromShards:self.chunkedShards[0]]).andReturn(self.requestModels[0]);
    OCMStub([self.mapper requestFromShards:self.chunkedShards[1]]).andReturn(self.requestModels[1]);
    OCMStub([self.connectionWatchdog isConnected]).andReturn(YES);

    [[self transientTrigger] trigger];

    for (EMSRequestModel *requestModel in self.requestModels) {
        OCMVerify([self.requestManager submitRequestModelNow:requestModel]);
    }
}

- (void)testTriggerBlock_transient_shouldNotSubmitsRequestModels_toRequestManager_noConnection {
    for (EMSRequestModel *requestModel in self.requestModels) {
        OCMReject([self.requestManager submitRequestModelNow:requestModel]);
    }
    OCMReject([self.shardRepository remove:[OCMArg any]]);

    OCMStub([self.predicate evaluate:self.shards]).andReturn(YES);
    OCMStub([self.chunker chunk:self.shards]).andReturn(self.chunkedShards);
    OCMStub([self.mapper requestFromShards:self.chunkedShards[0]]).andReturn(self.requestModels[0]);
    OCMStub([self.mapper requestFromShards:self.chunkedShards[1]]).andReturn(self.requestModels[1]);
    OCMStub([self.connectionWatchdog isConnected]).andReturn(NO);

    [[self transientTrigger] trigger];
}

- (void)testTriggerBlock_doesNothing_whenPredicateReturns_false {
    OCMStub([self.predicate evaluate:self.shards]).andReturn(NO);
    OCMReject([self.requestManager submitRequestModel:[OCMArg any]
                                  withCompletionBlock:[OCMArg any]]);

    [self.trigger trigger];
}

- (void)testTriggerBlock_removesHandledShards_fromDatabase {
    OCMStub([self.predicate evaluate:self.shards]).andReturn(YES);
    OCMStub([self.chunker chunk:self.shards]).andReturn(self.chunkedShards);
    OCMStub([self.mapper requestFromShards:self.chunkedShards[0]]).andReturn(self.requestModels[0]);
    OCMStub([self.mapper requestFromShards:self.chunkedShards[1]]).andReturn(self.requestModels[1]);
    OCMStub([self.connectionWatchdog isConnected]).andReturn(YES);

    [self.trigger trigger];


    EMSFilterByValuesSpecification *removeSpecForRequest1 = [[EMSFilterByValuesSpecification alloc] initWithValues:@[@"0", @"1", @"2"]
                                                                                                            column:SHARD_COLUMN_NAME_SHARD_ID];
    EMSFilterByValuesSpecification *removeSpecForRequest2 = [[EMSFilterByValuesSpecification alloc] initWithValues:@[@"3", @"4"]
                                                                                                            column:SHARD_COLUMN_NAME_SHARD_ID];

    OCMVerify([self.shardRepository remove:removeSpecForRequest1]);
    OCMVerify([self.shardRepository remove:removeSpecForRequest2]);
}

- (NSArray *)shardMocks {
    NSMutableArray *shards = [@[] mutableCopy];
    for (int i = 0; i < 5; i++) {
        EMSShard *shard = OCMClassMock([EMSShard class]);
        NSString *shardId = [NSString stringWithFormat:@"%d", i];
        OCMStub([shard shardId]).andReturn(shardId);
        [shards addObject:shard];
    }
    return [NSArray arrayWithArray:shards];
}

- (EMSBatchingShardTrigger *)persistentTrigger {
    return [self triggerWithPersistentFlag:YES];
}

- (EMSBatchingShardTrigger *)transientTrigger {
    return [self triggerWithPersistentFlag:NO];
}

- (EMSBatchingShardTrigger *)triggerWithPersistentFlag:(BOOL)flag {
    return [[EMSBatchingShardTrigger alloc] initWithRepository:self.shardRepository
                                                 specification:self.specification
                                                        mapper:self.mapper
                                                       chunker:self.chunker
                                                     predicate:self.predicate
                                                requestManager:self.requestManager
                                                    persistent:flag
                                            connectionWatchdog:self.connectionWatchdog];
}

@end
