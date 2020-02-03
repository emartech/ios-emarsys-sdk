//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSSQLStatementFactory.h"

@implementation EMSSQLStatementFactory

+ (NSString *)createQueryStatementWithTableName:(NSString *)tableName
                                      selection:(NSString *)selection
                                        orderBy:(NSString *)orderBy
                                          limit:(NSString *)limit {
    NSMutableString *statement = [EMSSQLStatementFactory createStatementWithCommand:@"SELECT *"
                                                                          tableName:tableName
                                                                          selection:selection];
    if (orderBy) {
        [statement appendString:[NSString stringWithFormat:@" ORDER BY %@", orderBy]];
    }
    if (limit) {
        [statement appendString:[NSString stringWithFormat:@" LIMIT %@", limit]];
    }
    [statement appendString:@";"];
    return statement;
}

+ (NSString *)createDeleteStatementWithTableName:(NSString *)tableName
                                       selection:(NSString *)selection {
    NSMutableString *statement = [EMSSQLStatementFactory createStatementWithCommand:@"DELETE *"
                                                                          tableName:tableName
                                                                          selection:selection];
    [statement appendString:@";"];
    return statement;
}

+ (NSMutableString *)createStatementWithCommand:(NSString *)command
                                      tableName:(NSString *)tableName
                                      selection:(NSString *)selection {
    NSMutableString *statement = [command mutableCopy];
    [statement appendString:[NSString stringWithFormat:@" FROM %@", tableName]];
    if (selection) {
        [statement appendString:[NSString stringWithFormat:@" WHERE %@", selection]];
    }
    return statement;
}

@end