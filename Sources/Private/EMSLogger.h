//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSShardRepository.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"

#define kEMSLogLevelKey @"EMSLogLevelKey"

typedef enum {
    LogLevelTrace,
    LogLevelDebug,
    LogLevelInfo,
    LogLevelWarn,
    LogLevelError,
    LogLevelMetric
} LogLevel;

@protocol EMSLogEntryProtocol;
@protocol EMSLogLevelProtocol;
@protocol EMSStorageProtocol;
@class EMSRemoteConfig;
@class EMSWrapperChecker;

@interface EMSLogger : NSObject

@property(nonatomic, strong) NSArray<id <EMSLogLevelProtocol>> *consoleLogLevels;
@property(nonatomic, assign) LogLevel logLevel;

- (instancetype)initWithShardRepository:(id <EMSShardRepositoryProtocol>)shardRepository
                         opertaionQueue:(NSOperationQueue *)operationQueue
                      timestampProvider:(EMSTimestampProvider *)timestampProvider
                           uuidProvider:(EMSUUIDProvider *)uuidProvider
                                storage:(id<EMSStorageProtocol>)storage
                         wrapperChecker:(EMSWrapperChecker *)wrapperChecker;

- (void)log:(id <EMSLogEntryProtocol>)entry
      level:(LogLevel)level;

- (void)updateWithRemoteConfig:(EMSRemoteConfig *)remoteConfig;
- (void)reset;

@end