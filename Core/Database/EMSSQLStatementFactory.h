//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol EMSModelMapperProtocol;
@protocol EMSSQLSpecificationProtocol;

@interface EMSSQLStatementFactory : NSObject

+ (NSString *)createQueryStatementWithTableName:(NSString *)tableName
                                      selection:(NSString *)selection
                                        orderBy:(NSString *)orderBy
                                          limit:(NSString *)limit;

+ (NSString *)createDeleteStatementWithTableName:(NSString *)tableName
                                       selection:(NSString *)selection;

@end