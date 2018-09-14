//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSTrigger.h"

@class EMSSQLiteHelper;
@class EMSRequestManager;
@class EMSPredictMapper;
@class EMSShardRepository;

@interface EMSPredictAggregateShardsTrigger : NSObject

- (EMSTriggerBlock)createTriggerBlockWithRequestManager:(EMSRequestManager *)requestManager
                                                 mapper:(EMSPredictMapper *)predictMapper
                                             repository:(EMSShardRepository *)shardRepository;

@end