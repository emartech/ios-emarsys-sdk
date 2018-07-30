//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "MEDisplayedIAMRepository.h"
#import "MEDisplayedIAMMapper.h"
#import "MEDisplayedIAMContract.h"

@interface MEDisplayedIAMRepository ()

@property (nonatomic, strong) MEDisplayedIAMMapper *mapper;
@property (nonatomic, strong) EMSSQLiteHelper *sqliteHelper;
@end

@implementation MEDisplayedIAMRepository

- (instancetype)initWithDbHelper:(EMSSQLiteHelper *)sqliteHelper {
    self = [super init];
    if (self) {
        _sqliteHelper = sqliteHelper;
        _mapper = [MEDisplayedIAMMapper new];
    }
    return self;
}

- (void)add:(MEDisplayedIAM *)item {
    [self.sqliteHelper insertModel:item withQuery:SQL_REQUEST_INSERT mapper:self.mapper];
}

- (void)remove:(id <EMSSQLSpecificationProtocol>)sqlSpecification {
    [self.sqliteHelper execute:SQL_REQUEST_DELETE_ITEM(sqlSpecification.sql) withBindBlock:^(sqlite3_stmt *statement) {
        [sqlSpecification bindStatement:statement];
    }];
}

- (NSArray <MEDisplayedIAM *> *)query:(id <EMSSQLSpecificationProtocol>)sqlSpecification {
    return [self.sqliteHelper executeQuery:SQL_SELECT(sqlSpecification.sql) mapper:self.mapper];
}

@end