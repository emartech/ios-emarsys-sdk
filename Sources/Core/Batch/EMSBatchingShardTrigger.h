//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSTrigger.h"
#import "EMSDBTriggerProtocol.h"

@class EMSRequestManager;
@protocol EMSRequestFromShardsMapperProtocol;
@protocol EMSShardRepositoryProtocol;
@class EMSListChunker;
@protocol EMSSQLSpecificationProtocol;
@class EMSPredicate;
@class EMSConnectionWatchdog;

@interface EMSBatchingShardTrigger : NSObject <EMSDBTriggerProtocol>

- (instancetype)initWithRepository:(id <EMSShardRepositoryProtocol>)shardRepository
                     specification:(id <EMSSQLSpecificationProtocol>)specification
                            mapper:(id <EMSRequestFromShardsMapperProtocol>)mapper
                           chunker:(EMSListChunker *)chunker
                         predicate:(EMSPredicate *)predicate
                    requestManager:(EMSRequestManager *)requestManager
                        persistent:(BOOL)persistent
                connectionWatchdog:(EMSConnectionWatchdog *)connectionWatchdog;

@end