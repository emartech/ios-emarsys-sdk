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
    LogLevelError
} LogLevel;

@protocol EMSLogEntryProtocol;
@class EMSRemoteConfig;
@class EMSStorage;

@interface EMSLogger : NSObject

@property(nonatomic, assign) LogLevel logLevel;

- (instancetype)initWithShardRepository:(id <EMSShardRepositoryProtocol>)shardRepository
                         opertaionQueue:(NSOperationQueue *)operationQueue
                      timestampProvider:(EMSTimestampProvider *)timestampProvider
                           uuidProvider:(EMSUUIDProvider *)uuidProvider
                                storage:(EMSStorage *)storage;

- (void)log:(id <EMSLogEntryProtocol>)entry
      level:(LogLevel)level;

- (void)updateWithRemoteConfig:(EMSRemoteConfig *)remoteConfig;
- (void)reset;

@end