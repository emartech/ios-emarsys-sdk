//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

#import "EMSTestColumnInfoMapper.h"
#import "EMSTestColumnInfo.h"

@interface EMSTestColumnInfoMapper()

@property(nonatomic, strong) NSString *tableName;

- (int)columnIndexByName:(NSString *)columnName
             inStatement:(sqlite3_stmt *)statement;

@end

@implementation EMSTestColumnInfoMapper

- (nonnull instancetype)initWithTableName:(nonnull NSString *)tableName {
    if (self = [super init]) {
        _tableName = tableName;
    }
    return self;
}


- (sqlite3_stmt *)bindStatement:(sqlite3_stmt *)statement 
                      fromModel:(id)model {
    return NULL;
}

- (NSUInteger)fieldCount { 
    return 5;
}

- (id)modelFromStatement:(sqlite3_stmt *)statement { 
    NSString *columnName = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, [self columnIndexByName:@"name" inStatement:statement])];
    NSString *columnType = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, [self columnIndexByName:@"type" inStatement:statement])];
    int primaryKey = sqlite3_column_int(statement, [self columnIndexByName:@"pk" inStatement:statement]);
    int notNull = sqlite3_column_int(statement, [self columnIndexByName:@"notnull" inStatement:statement]);
    const unsigned char *defValue = sqlite3_column_text(statement, [self columnIndexByName:@"dflt_value" inStatement:statement]);
    NSString *defaultValue;
    if (defValue != nil) {
        defaultValue = [NSString stringWithUTF8String:(const char *) defValue];
    }
    return [[EMSTestColumnInfo alloc] initWithColumnName:columnName 
                                              columnType:columnType
                                            defaultValue:defaultValue
                                              primaryKey:[@(primaryKey) boolValue]
                                                 notNull:[@(notNull) boolValue]];
}

- (NSString *)tableName { 
    return self.tableName;
}

- (int)columnIndexByName:(NSString *)columnName 
             inStatement:(sqlite3_stmt *)statement {
    int columnIndex = -1;
    for (int i = 0; i < sqlite3_column_count(statement); i++) {
        NSString *currentColumnName = [NSString stringWithUTF8String:sqlite3_column_name(statement, i)];
        if ([currentColumnName isEqualToString:columnName]) {
            columnIndex = i;
            break;
        }
    }
    return columnIndex;
}

@end
