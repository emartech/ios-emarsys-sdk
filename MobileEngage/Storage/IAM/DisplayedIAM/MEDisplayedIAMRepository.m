//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "MEDisplayedIAMRepository.h"
#import "MEDisplayedIAMMapper.h"
#import "MEDisplayedIAMContract.h"

@interface MEDisplayedIAMRepository ()

@property(nonatomic, strong) MEDisplayedIAMMapper *mapper;
@property(nonatomic, strong) EMSSQLiteHelper *sqliteHelper;
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
    [self.sqliteHelper insertModel:item withQuery:SQL_REQUEST_INSERT_DISPLAYED_IAM mapper:self.mapper];
}

- (void)remove:(id <EMSSQLSpecificationProtocol>)sqlSpecification {
    [self.sqliteHelper removeFromTable:self.mapper.tableName
                             selection:sqlSpecification.selection
                         selectionArgs:sqlSpecification.selectionArgs];
}

- (NSArray <MEDisplayedIAM *> *)query:(id <EMSSQLSpecificationProtocol>)sqlSpecification {
    return [self.sqliteHelper queryWithTable:self.mapper.tableName
                                   selection:sqlSpecification.selection
                               selectionArgs:sqlSpecification.selectionArgs
                                     orderBy:sqlSpecification.orderBy
                                       limit:sqlSpecification.limit
                                      mapper:self.mapper];
}

@end
