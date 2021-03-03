//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "EMSLogger.h"
#import "EMSLogEntryProtocol.h"
#import "EMSShard.h"
#import "EMSLogEndpoints.h"
#import "EMSRemoteConfig.h"
#import "EMSStorage.h"
#import "EMSLogLevelProtocol.h"
#import "EMSLogLevel.h"

@interface EMSLogger ()

@property(nonatomic, strong) EMSShardRepository *shardRepository;
@property(nonatomic, strong) NSOperationQueue *operationQueue;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *uuidProvider;
@property(nonatomic, strong) EMSStorage *storage;

@end

@implementation EMSLogger

#pragma mark - Public methods

- (instancetype)initWithShardRepository:(id <EMSShardRepositoryProtocol>)shardRepository
                         opertaionQueue:(NSOperationQueue *)operationQueue
                      timestampProvider:(EMSTimestampProvider *)timestampProvider
                           uuidProvider:(EMSUUIDProvider *)uuidProvider
                                storage:(EMSStorage *)storage {
    NSParameterAssert(shardRepository);
    NSParameterAssert(operationQueue);
    NSParameterAssert(timestampProvider);
    NSParameterAssert(uuidProvider);
    NSParameterAssert(storage);
    if (self = [super init]) {
        _shardRepository = shardRepository;
        _operationQueue = operationQueue;
        _timestampProvider = timestampProvider;
        _uuidProvider = uuidProvider;
        _storage = storage;
        NSNumber *logLevel = [storage numberForKey:kEMSLogLevelKey];
        _logLevel = logLevel ? [logLevel intValue] : LogLevelError;
        _consoleLogLevels = @[EMSLogLevel.basic];
    }
    return self;
}

- (void)setConsoleLogLevels:(NSArray *)consoleLogLevels {
    if (consoleLogLevels) {
        _consoleLogLevels = consoleLogLevels;
    }
}

- (void)log:(id <EMSLogEntryProtocol>)entry
      level:(LogLevel)level {
    [self consoleLogLogEntry:entry
                  entryLevel:level];
    id url = entry.data[@"url"];
    if ((!([entry.topic isEqualToString:@"log_request"] && url && [url isEqualToString:EMSLogEndpoint]) && level >= self.logLevel)
            || [entry.topic isEqualToString:@"app:start"]) {
        [self.operationQueue addOperationWithBlock:^{
            [self.shardRepository add:[EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                        [builder setType:[entry topic]];
                        NSMutableDictionary *mutableData = [entry.data mutableCopy];
                        mutableData[@"level"] = [self logLevelStringFromLogLevel:level];
                        [builder addPayloadEntries:[NSDictionary dictionaryWithDictionary:mutableData]];
                    }
                                              timestampProvider:self.timestampProvider
                                                   uuidProvider:self.uuidProvider]];
        }];
    } else {
        return;
    }
}

- (void)consoleLogLogEntry:(id <EMSLogEntryProtocol>)entry
                entryLevel:(LogLevel)entryLevel {
#ifdef DEBUG
    NSString *entryLevelStringRepresentation = [self logLevelStringFromLogLevel:entryLevel];
    NSMutableArray<NSString *> *consoleLogLevelsStringRepresentation = [NSMutableArray array];
    for (id <EMSLogLevelProtocol> consoleLogLevel in self.consoleLogLevels) {
        [consoleLogLevelsStringRepresentation addObject:consoleLogLevel.level];
    }
    NSString *icon = nil;
    if ([self.consoleLogLevels containsObject:EMSLogLevel.basic] && [entry.topic isEqualToString:@"log_method_not_allowed"]) {
        icon = @"🔵";
    } else if ([consoleLogLevelsStringRepresentation containsObject:entryLevelStringRepresentation]) {
        if (entryLevel == LogLevelTrace) {
            icon = @"🟣";
        } else if (entryLevel == LogLevelDebug) {
            icon = @"🔵";
        } else if (entryLevel == LogLevelInfo) {
            icon = @"🟡";
        } else if (entryLevel == LogLevelWarn) {
            icon = @"🟠";
        } else if (entryLevel == LogLevelError) {
            icon = @"🔴";
        }
    }
    if (icon) {
        NSLog(@"EmarsysSDK - %@ - %@ \n Data: \n %@", icon, entry.topic, [self dataStringRepresentation:entry.data]);
    }
#endif
}

- (void)updateWithRemoteConfig:(EMSRemoteConfig *)remoteConfig {
    self.logLevel = remoteConfig.logLevel;
    [self.storage setNumber:@(remoteConfig.logLevel)
                     forKey:kEMSLogLevelKey];
}

- (void)reset {
    self.logLevel = LogLevelError;
    [self.storage setNumber:nil
                     forKey:kEMSLogLevelKey];
}

- (NSString *)dataStringRepresentation:(NSDictionary *)data {
    NSMutableString *result = [NSMutableString string];
    for (NSString *key in [data allKeys]) {
        [result appendString:[NSString stringWithFormat:@"%@: %@ \n",
                                                        key,
                                                        data[key]]];
    }
    return [NSString stringWithString:result];
}

- (NSString *)logLevelStringFromLogLevel:(LogLevel)level {
    NSString *result = @"TRACE";
    if (level == LogLevelDebug) {
        result = @"DEBUG";
    } else if (level == LogLevelInfo) {
        result = @"INFO";
    } else if (level == LogLevelWarn) {
        result = @"WARN";
    } else if (level == LogLevelError) {
        result = @"ERROR";
    } else if (level == LogLevelMetric) {
        result = @"METRIC";
    }
    return result;
}

@end
