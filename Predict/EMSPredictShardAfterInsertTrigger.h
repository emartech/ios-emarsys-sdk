//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@class EMSSQLiteHelper;
@class EMSRequestManager;
@class EMSPredictMapper;
@class EMSShardRepository;

@interface EMSPredictShardAfterInsertTrigger : NSObject

@property(nonatomic, readonly) EMSSQLiteHelper *sqliteHelper;
@property(nonatomic, readonly) EMSRequestManager *requestManager;
@property(nonatomic, readonly) EMSPredictMapper *predictMapper;
@property(nonatomic, readonly) EMSShardRepository *shardRepository;

- (instancetype)initWithSqliteHelper:(EMSSQLiteHelper *)sqliteHelper
                      requestManager:(EMSRequestManager *)requestManager
                              mapper:(EMSPredictMapper *)predictMapper
                          repository:(EMSShardRepository *)shardRepository;

- (void)register;

@end