//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSLogMapper.h"
#import "EMSShard.h"
#import "EMSRequestModel.h"
#import "EMSUUIDProvider.h"
#import "EMSDeviceInfo.h"

@interface EMSLogMapperTests : XCTestCase

@property(nonatomic, strong) EMSLogMapper *logMapper;
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) NSArray *shards;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *uuidProvider;
@property(nonatomic, strong) EMSDeviceInfo *deviceInfo;
@property(nonatomic, strong) NSString *applicationCode;
@property(nonatomic, strong) NSString *merchantId;

@end

@implementation EMSLogMapperTests

- (void)setUp {
    _timestampProvider = OCMClassMock([EMSTimestampProvider class]);
    _uuidProvider = OCMClassMock([EMSUUIDProvider class]);
    _deviceInfo = OCMClassMock([EMSDeviceInfo class]);
    _requestContext = OCMClassMock([MERequestContext class]);
    _applicationCode = @"applicationCode";
    _merchantId = @"merchantId";

    OCMStub(self.timestampProvider.provideTimestamp).andReturn([NSDate date]);
    OCMStub(self.uuidProvider.provideUUIDString).andReturn(@"requestId");
    OCMStub(self.deviceInfo.applicationVersion).andReturn(@"applicationVersion");
    OCMStub(self.deviceInfo.osVersion).andReturn(@"osVersion");
    OCMStub(self.deviceInfo.deviceModel).andReturn(@"deviceModel");
    OCMStub(self.deviceInfo.hardwareId).andReturn(@"hardwareId");
    OCMStub(self.deviceInfo.platform).andReturn(@"ios");
    OCMStub(self.deviceInfo.sdkVersion).andReturn(@"sdkVersion");
    OCMStub(self.requestContext.timestampProvider).andReturn(self.timestampProvider);
    OCMStub(self.requestContext.uuidProvider).andReturn(self.uuidProvider);
    OCMStub(self.requestContext.deviceInfo).andReturn(self.deviceInfo);

    _logMapper = [[EMSLogMapper alloc] initWithRequestContext:self.requestContext applicationCode:_applicationCode merchantId: _merchantId];
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

- (void)testInit_shouldThrowException_when_requestContextIsNil {
    @try {
        [[EMSLogMapper alloc] initWithRequestContext:nil applicationCode:_applicationCode merchantId:_merchantId];
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
    NSDictionary *expectedDeviceInfo = @{
            @"platform": @"ios",
            @"app_version": @"applicationVersion",
            @"sdk_version": @"sdkVersion",
            @"os_version": @"osVersion",
            @"model": @"deviceModel",
            @"hw_id": @"hardwareId",
            @"application_code": _applicationCode,
            @"merchant_id": _merchantId,
    };

    EMSRequestModel *expectedRequestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"https://log-dealer.eservice.emarsys.net/v1/log"];
                [builder setMethod:HTTPMethodPOST];
                [builder setPayload:@{
                        @"logs": @[
                                @{
                                        @"type": @"type1",
                                        @"shardData1Key": @"shardData1Value",
                                        @"device_info": expectedDeviceInfo
                                },
                                @{
                                        @"type": @"type2",
                                        @"shardData2Key": @"shardData2Value",
                                        @"device_info": expectedDeviceInfo
                                },
                                @{
                                        @"type": @"type3",
                                        @"shardData3Key": @"shardData3Value",
                                        @"device_info": expectedDeviceInfo
                                },
                                @{
                                        @"type": @"type4",
                                        @"shardData4Key": @"shardData4Value",
                                        @"device_info": expectedDeviceInfo
                                },
                                @{
                                        @"type": @"type5",
                                        @"shardData5Key": @"shardData5Value",
                                        @"device_info": expectedDeviceInfo
                                }
                        ]
                }];
            }
                                                           timestampProvider:self.timestampProvider
                                                                uuidProvider:self.uuidProvider];

    EMSRequestModel *returnedRequestModel = [self.logMapper requestFromShards:self.shards];

    XCTAssertTrue([returnedRequestModel isEqual:expectedRequestModel]);
}

- (void)testRequestFromShards_shouldReturnWithRequestModelWithoutMerchantId_when_merchantIdIsNil {
    NSDictionary *expectedDeviceInfo = @{
            @"platform": @"ios",
            @"app_version": @"applicationVersion",
            @"sdk_version": @"sdkVersion",
            @"os_version": @"osVersion",
            @"model": @"deviceModel",
            @"hw_id": @"hardwareId",
            @"application_code": _applicationCode,
    };

    EMSLogMapper *logMapper = [[EMSLogMapper alloc] initWithRequestContext:self.requestContext applicationCode:self.applicationCode merchantId:nil];

    EMSRequestModel *returnedRequestModel = [logMapper requestFromShards:self.shards];

    XCTAssertTrue([returnedRequestModel.payload[@"logs"][0][@"device_info"] isEqual:expectedDeviceInfo]);
}

@end
