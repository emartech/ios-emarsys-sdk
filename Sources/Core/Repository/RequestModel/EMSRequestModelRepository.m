//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "EMSRequestModelRepository.h"
#import "EMSRequestModelMapper.h"
#import "EMSSchemaContract.h"
#import "EMSCountMapper.h"
#import "EMSSQLiteHelper.h"
#import <UIKit/UIKit.h>

@interface EMSRequestModelRepository ()

@property(nonatomic, strong) EMSSQLiteHelper *dbHelper;
@property(nonatomic, strong) EMSRequestModelMapper *mapper;

@end

@implementation EMSRequestModelRepository

#pragma mark - Init

- (instancetype)initWithDbHelper:(EMSSQLiteHelper *)sqliteHelper {
    if (self = [super init]) {
        _dbHelper = sqliteHelper;
        _mapper = [EMSRequestModelMapper new];
        _dbHelper = sqliteHelper;
        [_dbHelper open];

        __weak typeof(self) weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          [weakSelf.dbHelper close];
                                                      }];
    }
    return self;
}

#pragma mark - EMSRequestModelRepository

- (void)add:(EMSRequestModel *)item {
    NSParameterAssert(item);
    [self.dbHelper insertModel:item
                     withQuery:SQL_REQUEST_INSERT
                        mapper:self.mapper];
}

- (void)remove:(id <EMSSQLSpecificationProtocol>)sqlSpecification {
    [self.dbHelper removeFromTable:self.mapper.tableName
                         selection:sqlSpecification.selection
                     selectionArgs:sqlSpecification.selectionArgs];
}

- (NSArray<EMSRequestModel *> *)query:(id <EMSSQLSpecificationProtocol>)sqlSpecification {
    NSArray *result = [self.dbHelper queryWithTable:self.mapper.tableName
                                          selection:sqlSpecification.selection
                                      selectionArgs:sqlSpecification.selectionArgs
                                            orderBy:sqlSpecification.orderBy
                                              limit:sqlSpecification.limit
                                             mapper:self.mapper];
    if (!result) {
        result = @[];
    }
    return result;
}

- (BOOL)isEmpty {
    NSNumber *count = [[self.dbHelper executeQuery:SQL_REQUEST_COUNT mapper:[EMSCountMapper new]] firstObject];
    return [count integerValue] == 0;
}

@end