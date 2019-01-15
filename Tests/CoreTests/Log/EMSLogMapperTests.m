//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSLogMapper.h"
#import "EMSShard.h"
#import "EMSRequestModel.h"
#import "EMSUUIDProvider.h"

@interface EMSLogMapperTests : XCTestCase

@property(nonatomic, strong) EMSLogMapper *logMapper;
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) NSArray *shards;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *uuidProvider;

@end

@implementation EMSLogMapperTests

- (void)setUp {
    _timestampProvider = OCMClassMock([EMSTimestampProvider class]);
    _uuidProvider = OCMClassMock([EMSUUIDProvider class]);
    _requestContext = OCMClassMock([MERequestContext class]);

    OCMStub(self.timestampProvider.provideTimestamp).andReturn([NSDate date]);
    OCMStub(self.uuidProvider.provideUUIDString).andReturn(@"requestId");
    OCMStub(self.requestContext.timestampProvider).andReturn(self.timestampProvider);
    OCMStub(self.requestContext.uuidProvider).andReturn(self.uuidProvider);

    _logMapper = [[EMSLogMapper alloc] initWithRequestContext:self.requestContext];
    _shards = @[
        [[EMSShard alloc] initWithShardId:@"shardId1"
                                     type:@"type1"
                                     data:@{@"shardData1Key": @"shardData1Value"}
                                timestamp:[NSDate date]
                                      ttl:2.0],
        [[EMSShard alloc] initWithShardId:@"shardId2"
                                     type:@"type2"
                                     data:@{@"shardData2Key": @"shardData2Value"}
                                timestamp:[NSDate date]
                                      ttl:2.0],
        [[EMSShard alloc] initWithShardId:@"shardId3"
                                     type:@"type3"
                                     data:@{@"shardData3Key": @"shardData3Value"}
                                timestamp:[NSDate date]
                                      ttl:2.0],
        [[EMSShard alloc] initWithShardId:@"shardId4"
                                     type:@"type4"
                                     data:@{@"shardData4Key": @"shardData4Value"}
                                timestamp:[NSDate date]
                                      ttl:2.0],
        [[EMSShard alloc] initWithShardId:@"shardId5"
                                     type:@"type5"
                                     data:@{@"shardData5Key": @"shardData5Value"}
                                timestamp:[NSDate date]
                                      ttl:2.0]
    ];
}

- (void)testInitWithRequestContext_shouldThrowException_when_requestContextIsNil {
    @try {
        [[EMSLogMapper alloc] initWithRequestContext:nil];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: requestContext"]);
    }
}

- (void)testRequestFromShards_shouldThrowException_when_shardsIsNil {
    @try {
        [self.logMapper requestFromShards:nil];
        XCTFail(@"Expected Exception when shards is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: shards"]);
    }
}

- (void)testRequestFromShards_shouldThrowException_when_shardsArrayIsEmpty {
    @try {
        [self.logMapper requestFromShards:@[]];
        XCTFail(@"Expected Exception when shards array is empty!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: [shards count] > 0"]);
    }
}

- (void)testRequestFromShards_shouldReturnWithRequestModel {
    EMSRequestModel *expectedRequestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setUrl:@"https://ems-log-dealer.herokuapp.com/log"];
            [builder setMethod:HTTPMethodPOST];
            [builder setPayload:@{
                @"logs": @[
                    @{
                        @"type": @"type1",
                        @"shardData1Key": @"shardData1Value"
                    },
                    @{
                        @"type": @"type2",
                        @"shardData2Key": @"shardData2Value"
                    },
                    @{
                        @"type": @"type3",
                        @"shardData3Key": @"shardData3Value"
                    },
                    @{
                        @"type": @"type4",
                        @"shardData4Key": @"shardData4Value"
                    },
                    @{
                        @"type": @"type5",
                        @"shardData5Key": @"shardData5Value"
                    }
                ]
            }];
        }
                                                           timestampProvider:self.timestampProvider
                                                                uuidProvider:self.uuidProvider];

    EMSRequestModel *returnedRequestModel = [self.logMapper requestFromShards:self.shards];

    XCTAssertTrue([returnedRequestModel isEqual:expectedRequestModel]);
}

@end
