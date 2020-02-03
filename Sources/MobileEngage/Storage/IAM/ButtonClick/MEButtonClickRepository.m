//
//  Copyright © 2018 Emarsys. All rights reserved.
//

#import "MEButtonClickRepository.h"
#import "MEButtonClickMapper.h"
#import "MEButtonClickContract.h"

@interface MEButtonClickRepository ()

@property(nonatomic, strong) MEButtonClickMapper *mapper;
@property(nonatomic, strong) EMSSQLiteHelper *sqliteHelper;

@end

@implementation MEButtonClickRepository

- (instancetype)initWithDbHelper:(EMSSQLiteHelper *)sqliteHelper {
    if (self = [super init]) {
        _sqliteHelper = sqliteHelper;
        _mapper = [MEButtonClickMapper new];
    }
    return self;
}

- (void)add:(MEButtonClick *)item {
    [self.sqliteHelper insertModel:item
                         withQuery:SQL_INSERT_BUTTON_CLICK
                            mapper:self.mapper];
}

- (void)remove:(id <EMSSQLSpecificationProtocol>)sqlSpecification {
    [self.sqliteHelper removeFromTable:self.mapper.tableName
                             selection:sqlSpecification.selection
                         selectionArgs:sqlSpecification.selectionArgs];
}

- (NSArray<MEButtonClick *> *)query:(id <EMSSQLSpecificationProtocol>)sqlSpecification {
    return [self.sqliteHelper queryWithTable:self.mapper.tableName
                                   selection:sqlSpecification.selection
                               selectionArgs:sqlSpecification.selectionArgs
                                     orderBy:sqlSpecification.orderBy
                                       limit:sqlSpecification.limit
                                      mapper:self.mapper];
}

@end
