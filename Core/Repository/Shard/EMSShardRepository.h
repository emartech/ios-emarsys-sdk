//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSShardRepositoryProtocol.h"

@class EMSSQLiteHelper;


@interface EMSShardRepository : NSObject <EMSShardRepositoryProtocol>

- (instancetype)initWithDbHelper:(EMSSQLiteHelper *)sqliteHelper;

@end