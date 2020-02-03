//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@protocol EMSModelMapperProtocol <NSObject>

- (id)modelFromStatement:(sqlite3_stmt *)statement;

- (sqlite3_stmt *)bindStatement:(sqlite3_stmt *)statement fromModel:(id)model;

- (NSString *)tableName;

- (NSUInteger)fieldCount;

@end