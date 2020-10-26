//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSRemoteConfigResponseMapper.h"
#import "EMSRemoteConfig.h"
#import "EMSResponseModel.h"
#import "EMSRandomProvider.h"
#import "EMSDeviceInfo.h"
#import "NSDictionary+EMSCore.h"

@interface EMSRemoteConfigResponseMapper ()

@property(nonatomic, strong) EMSDeviceInfo *deviceInfo;

@end

@implementation EMSRemoteConfigResponseMapper

- (instancetype)initWithRandomProvider:(EMSRandomProvider *)randomProvider
                            deviceInfo:(id)deviceInfo {
    NSParameterAssert(randomProvider);
    NSParameterAssert(deviceInfo);
    if (self = [super init]) {
        _randomProvider = randomProvider;
        _deviceInfo = deviceInfo;
    }
    return self;
}

- (EMSRemoteConfig *)map:(EMSResponseModel *)responseModel {
    NSDictionary *parsedBody = [responseModel parsedBody];
    NSDictionary *hardwareIdSpecificConfig = parsedBody[@"overrides"][self.deviceInfo.hardwareId];


    NSMutableDictionary *activeConfig = [[parsedBody mergeWithDictionary:hardwareIdSpecificConfig] mutableCopy];
    activeConfig[@"serviceUrls"] = [parsedBody[@"serviceUrls"] mergeWithDictionary:hardwareIdSpecificConfig[@"serviceUrls"]];
    activeConfig[@"luckyLogger"] = [parsedBody[@"luckyLogger"] mergeWithDictionary:hardwareIdSpecificConfig[@"luckyLogger"]];
    activeConfig[@"features"] = [parsedBody[@"features"] mergeWithDictionary:hardwareIdSpecificConfig[@"features"]];

    return [[EMSRemoteConfig alloc] initWithEventService:[self validateEmarsysUrl:activeConfig[@"serviceUrls"][@"eventService"]]
                                           clientService:[self validateEmarsysUrl:activeConfig[@"serviceUrls"][@"clientService"]]
                                          predictService:[self validateEmarsysUrl:activeConfig[@"serviceUrls"][@"predictService"]]
                                   mobileEngageV2Service:[self validateEmarsysUrl:activeConfig[@"serviceUrls"][@"mobileEngageV2Service"]]
                                         deepLinkService:[self validateEmarsysUrl:activeConfig[@"serviceUrls"][@"deepLinkService"]]
                                            inboxService:[self validateEmarsysUrl:activeConfig[@"serviceUrls"][@"inboxService"]]
                                   v3MessageInboxService:[self validateEmarsysUrl:activeConfig[@"serviceUrls"][@"v3MessageInboxService"]]
                                                logLevel:[self calculateLogLevel:activeConfig[@"logLevel"]
                                                                   withThreshold:activeConfig[@"luckyLogger"][@"threshold"]
                                                               withLuckyLogLevel:activeConfig[@"luckyLogger"][@"logLevel"]]
                                                features:[self extractFeatures:activeConfig[@"features"]]];
}

- (NSDictionary *)extractFeatures:(NSDictionary *)features {
    if (!features) {
        return nil;
    }
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=[a-z])([A-Z])|([A-Z])(?=[a-z])"
                                                                           options:0
                                                                             error:nil];
    for (NSString *key in features) {
        NSString *underscoreString = [[regex stringByReplacingMatchesInString:key
                                                                      options:0
                                                                        range:NSMakeRange(0, key.length)
                                                                 withTemplate:@"_$1$2"] lowercaseString];
        result[underscoreString] = features[key];
    }

    return result;
}

- (LogLevel)calculateLogLevel:(NSString *)defaultLogLevel
                withThreshold:(NSNumber *)threshold
            withLuckyLogLevel:(NSString *)luckyLogLevel {
    LogLevel result = [self logLevelFromRawLogLevel:defaultLogLevel];
    NSNumber *randomValue = [[self randomProvider] provideDoubleUntil:@1];
    if ([threshold doubleValue] != 0 && [randomValue doubleValue] <= [threshold doubleValue]) {
        result = [self logLevelFromRawLogLevel:luckyLogLevel];
    }
    return result;
}

- (NSString *)validateEmarsysUrl:(NSString *)url {
    NSString *result = url;
    NSString *host = url ? [[NSURLComponents alloc] initWithString:url].host : nil;
    if (!host || (![host.lowercaseString hasSuffix:@".emarsys.net"] && ![host.lowercaseString hasSuffix:@".emarsys.com"])) {
        result = nil;
    }
    return result;
}

- (LogLevel)logLevelFromRawLogLevel:(NSString *)rawLogLevel {
    LogLevel result = LogLevelError;
    if ([rawLogLevel.lowercaseString isEqualToString:@"trace"]) {
        result = LogLevelTrace;
    } else if ([rawLogLevel.lowercaseString isEqualToString:@"debug"]) {
        result = LogLevelDebug;
    } else if ([rawLogLevel.lowercaseString isEqualToString:@"info"]) {
        result = LogLevelInfo;
    } else if ([rawLogLevel.lowercaseString isEqualToString:@"warn"]) {
        result = LogLevelWarn;
    } else if ([rawLogLevel.lowercaseString isEqualToString:@"error"]) {
        result = LogLevelError;
    } else if ([rawLogLevel.lowercaseString isEqualToString:@"metric"]) {
        result = LogLevelMetric;
    }
    return result;
}

@end
