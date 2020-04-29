//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSRemoteConfigResponseMapper.h"
#import "EMSRemoteConfig.h"
#import "EMSResponseModel.h"
#import "EMSRandomProvider.h"

@implementation EMSRemoteConfigResponseMapper
- (instancetype)initWithRandomProvider:(EMSRandomProvider *)randomProvider {
    NSParameterAssert(randomProvider);

    if (self = [super init]) {
        _randomProvider = randomProvider;
    }
    return self;
}


- (EMSRemoteConfig *)map:(EMSResponseModel *)responseModel {
    NSDictionary *parsedBody = [responseModel parsedBody];
    NSDictionary *serviceUrls = parsedBody[@"serviceUrls"];
    NSDictionary *luckyLog = parsedBody[@"luckyLogger"];

    return [[EMSRemoteConfig alloc] initWithEventService:[self validateEmarsysUrl:serviceUrls[@"eventService"]]
                                           clientService:[self validateEmarsysUrl:serviceUrls[@"clientService"]]
                                          predictService:[self validateEmarsysUrl:serviceUrls[@"predictService"]]
                                   mobileEngageV2Service:[self validateEmarsysUrl:serviceUrls[@"mobileEngageV2Service"]]
                                         deepLinkService:[self validateEmarsysUrl:serviceUrls[@"deepLinkService"]]
                                            inboxService:[self validateEmarsysUrl:serviceUrls[@"inboxService"]]
                                   v3MessageInboxService:[self validateEmarsysUrl:serviceUrls[@"v3MessageInboxService"]]
                                                logLevel:[self calculateLogLevel:parsedBody[@"logLevel"]
                                                                   withThreshold:luckyLog[@"threshold"]
                                                               withLuckyLogLevel:luckyLog[@"logLevel"]]];
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
    }
    return result;
}

@end
