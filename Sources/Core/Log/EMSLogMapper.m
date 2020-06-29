//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSLogMapper.h"
#import "EMSRequestModel.h"
#import "EMSShard.h"
#import "EMSDeviceInfo.h"
#import "EMSLogEndpoints.h"

@interface EMSLogMapper ()
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) NSString *applicationCode;
@property(nonatomic, strong) NSString *merchantId;
@end

@implementation EMSLogMapper

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext
                       applicationCode:(NSString *)applicationCode
                            merchantId:(NSString *)merchantId {
    NSParameterAssert(requestContext);
    if (self = [super init]) {
        _requestContext = requestContext;
        _applicationCode = applicationCode;
        _merchantId = merchantId;
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
                NSMutableDictionary *mutableDeviceInfoDictionary = [NSMutableDictionary dictionary];
                mutableDeviceInfoDictionary[@"platform"] = deviceInfo.platform;
                mutableDeviceInfoDictionary[@"appVersion"] = deviceInfo.applicationVersion;
                mutableDeviceInfoDictionary[@"sdkVersion"] = deviceInfo.sdkVersion;
                mutableDeviceInfoDictionary[@"osVersion"] = deviceInfo.osVersion;
                mutableDeviceInfoDictionary[@"model"] = deviceInfo.deviceModel;
                mutableDeviceInfoDictionary[@"hwId"] = deviceInfo.hardwareId;
                mutableDeviceInfoDictionary[@"applicationCode"] = weakSelf.applicationCode;
                mutableDeviceInfoDictionary[@"merchantId"] = weakSelf.merchantId;

                for (EMSShard *shard in shards) {
                    NSMutableDictionary<NSString *, id> *shardData = [NSMutableDictionary dictionaryWithDictionary:shard.data];
                    shardData[@"type"] = shard.type;
                    shardData[@"deviceInfo"] = [NSDictionary dictionaryWithDictionary:mutableDeviceInfoDictionary];

                    [logs addObject:[NSDictionary dictionaryWithDictionary:shardData]];
                }
                [builder setUrl:EMSLogEndpoint];
                [builder setMethod:HTTPMethodPOST];
                [builder setPayload:@{@"logs": [NSArray arrayWithArray:logs]}];
            }
                          timestampProvider:self.requestContext.timestampProvider
                               uuidProvider:self.requestContext.uuidProvider];
}

@end
