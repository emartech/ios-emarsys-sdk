//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSTrigger.h"

@class EMSRequestManager;
@protocol EMSRequestFromShardsMapperProtocol;
@protocol EMSShardRepositoryProtocol;
@class EMSListChunker;
@protocol EMSSQLSpecificationProtocol;
@protocol EMSPredicateProtocol;

@interface EMSBatchingShardTriggerFactory : NSObject

- (EMSTriggerBlock)createTriggerBlockWithRepository:(id <EMSShardRepositoryProtocol>)shardRepository
                                      specification:(id <EMSSQLSpecificationProtocol>)specification
                                             mapper:(id <EMSRequestFromShardsMapperProtocol>)mapper
                                            chunker:(EMSListChunker *)chunker
                                          predicate:(id <EMSPredicateProtocol>)predicate
                                     requestManager:(EMSRequestManager *)requestManager;

@end