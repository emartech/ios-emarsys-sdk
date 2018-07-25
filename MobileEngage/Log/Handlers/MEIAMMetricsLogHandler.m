//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "MEIAMMetricsLogHandler.h"
#import "MERequestMatcher.h"

static NSString *kRequestId = @"request_id";
static NSString *kInDatabaseTime = @"in_database_time";
static NSString *kNetworkingTime = @"networking_time";
static NSString *kLoadingTime = @"loading_time";
static NSString *kCampaignId = @"campaign_id";
static NSString *kUrl = @"url";

@interface MEIAMMetricsLogHandler ()

@property(nonatomic, strong) NSMutableDictionary<NSString *, NSDictionary<NSString *, NSObject *> *> *metricsBuffer;

@end

@implementation MEIAMMetricsLogHandler

- (instancetype)initWithMetricsBuffer:(NSMutableDictionary<NSString *, NSDictionary<NSString *, NSObject *> *> *)metricsBuffer {
    NSParameterAssert(metricsBuffer);
    if (self = [super init]) {
        _metricsBuffer = metricsBuffer;
    }
    return self;
}

- (NSDictionary<NSString *, NSObject *> *)handle:(NSDictionary<NSString *, NSObject *> *)item {
    NSParameterAssert(item);
    NSDictionary<NSString *, NSObject *> *result = nil;
    if ([self hasValidRequestId:item] && ([self isInDatabaseMetric:item] || [self isNetworkingMetric:item] || [self isLoadingMetric:item])) {
        NSString *requestId = (NSString *) item[kRequestId];
        NSMutableDictionary<NSString *, NSObject *> *metricsForRequest = self.metricsBuffer[requestId] ? [self.metricsBuffer[requestId] mutableCopy] : [NSMutableDictionary dictionary];
        [metricsForRequest addEntriesFromDictionary:item];
        result = [self finalizeMetric:[NSDictionary dictionaryWithDictionary:metricsForRequest]];
    }
    return result;
}

- (NSDictionary<NSString *, NSObject *> *)finalizeMetric:(NSDictionary<NSString *, NSObject *> *)metric {
    id requestId = metric[kRequestId];
    NSDictionary<NSString *, NSObject *> *result;
    if ([self isMetricComplete:metric]) {
        self.metricsBuffer[requestId] = nil;
        result = metric;
    } else {
        self.metricsBuffer[requestId] = metric;
    }
    return result;
}

- (BOOL)isMetricComplete:(NSDictionary<NSString *, NSObject *> *)metric {
    return metric[kRequestId] && metric[kInDatabaseTime] && metric[kNetworkingTime] && metric[kLoadingTime];
}

- (BOOL)hasValidRequestId:(NSDictionary<NSString *, NSObject *> *)item {
    id requestId = item[kRequestId];
    return requestId && [requestId isKindOfClass:[NSString class]];
}

- (BOOL)hasValidCustomEventUrl:(NSDictionary<NSString *, NSObject *> *)item {
    id url = item[kUrl];
    return url && [url isKindOfClass:[NSString class]] && [MERequestMatcher isV3CustomEventUrl:url];
}

- (BOOL)isInDatabaseMetric:(NSDictionary<NSString *, NSObject *> *)item {
    return item[kInDatabaseTime] != nil && [self hasValidCustomEventUrl:item];
}

- (BOOL)isNetworkingMetric:(NSDictionary<NSString *, NSObject *> *)item {
    return item[kNetworkingTime] != nil && [self hasValidCustomEventUrl:item];
}

- (BOOL)isLoadingMetric:(NSDictionary<NSString *, NSObject *> *)item {
    return item[kLoadingTime] != nil && item[kCampaignId];
}

@end