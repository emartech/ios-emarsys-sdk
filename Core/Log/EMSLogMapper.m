//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSLogMapper.h"
#import "EMSRequestModel.h"
#import "EMSShard.h"
#import "EMSDeviceInfo.h"

@interface EMSLogMapper ()
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) NSString *applicationCode;
@end

@implementation EMSLogMapper

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext
                       applicationCode:(NSString *)applicationCode {
    NSParameterAssert(requestContext);
    NSParameterAssert(applicationCode);
    if (self = [super init]) {
        _applicationCode = applicationCode;
        _requestContext = requestContext;
    }
    return self;
}

- (EMSRequestModel *)requestFromShards:(NSArray<EMSShard *> *)shards {
    NSParameterAssert(shards);
    NSParameterAssert([shards count] > 0);
    __weak typeof(self) weakSelf = self;
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                NSMutableArray<NSDictionary<NSString *, id> *> *logs = [NSMutableArray new];
                EMSDeviceInfo *deviceInfo = weakSelf.requestContext.deviceInfo;
                for (EMSShard *shard in shards) {
                    NSMutableDictionary<NSString *, id> *shardData = [NSMutableDictionary dictionaryWithDictionary:shard.data];
                    shardData[@"type"] = shard.type;
                    shardData[@"device_info"] = @{
                            @"platform": deviceInfo.platform,
                            @"app_version": deviceInfo.applicationVersion,
                            @"sdk_version": deviceInfo.sdkVersion,
                            @"os_version": deviceInfo.osVersion,
                            @"model": deviceInfo.deviceModel,
                            @"hw_id": deviceInfo.hardwareId,
                        @"application_code": weakSelf.applicationCode
                    };
                    [logs addObject:[NSDictionary dictionaryWithDictionary:shardData]];
                }
                [builder setUrl:@"https://log-dealer.eservice.emarsys.net/v1/log"];
                [builder setMethod:HTTPMethodPOST];
                [builder setPayload:@{@"logs": [NSArray arrayWithArray:logs]}];
            }
                          timestampProvider:self.requestContext.timestampProvider
                               uuidProvider:self.requestContext.uuidProvider];
}

@end
