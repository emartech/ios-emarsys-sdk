//
//  Copyright © 2018 Emarsys. All rights reserved.
//

#import "MEButtonClickRepository.h"
#import "MEButtonClickMapper.h"
#import "MEButtonClickContract.h"

@interface MEButtonClickRepository()

@property (nonatomic, strong) MEButtonClickMapper *mapper;
@property (nonatomic, strong) EMSSQLiteHelper *sqliteHelper;

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
    [self.sqliteHelper execute:SQL_DELETE_ITEM_FROM_BUTTON_CLICK(sqlSpecification.sql)
                 withBindBlock:^(sqlite3_stmt *statement) {
                     [sqlSpecification bindStatement:statement];
                 }];
}

- (NSArray<MEButtonClick *> *)query:(id <EMSSQLSpecificationProtocol>)sqlSpecification {
    return [self.sqliteHelper executeQuery:SQL_SELECT_BUTTON_CLICK(sqlSpecification.sql)
                                    mapper:self.mapper];
}

@end
