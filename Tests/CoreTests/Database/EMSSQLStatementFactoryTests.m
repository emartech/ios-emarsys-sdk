//
//  Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSSQLStatementFactory.h"
#import "FakeSQLSpecification.h"
#import "EMSRequestModelMapper.h"

SPEC_BEGIN(EMSSQLStatementFactoryTests)

        beforeEach(^{
        });

        afterEach(^{
        });

        describe(@"createQueryStatementWithSpecification:mapper:", ^{

            it(@"should return with correct statement when selection set", ^{
                id <EMSSQLSpecificationProtocol> specification = [[FakeSQLSpecification alloc] initWithSelection:@"a = ?"
                                                                                                   selectionArgs:@[@"10"]
                                                                                                         orderBy:nil
                                                                                                           limit:nil];
                EMSRequestModelMapper *mapper = [[EMSRequestModelMapper alloc] init];

                NSString *statement = [EMSSQLStatementFactory createQueryStatementWithTableName:mapper.tableName
                                                                                      selection:specification.selection
                                                                                        orderBy:specification.orderBy
                                                                                          limit:specification.limit];
                [[statement should] equal:@"SELECT * FROM request WHERE a = ?;"];
            });

            it(@"should return with correct statement when orderBy set", ^{
                id <EMSSQLSpecificationProtocol> specification = [[FakeSQLSpecification alloc] initWithSelection:nil
                                                                                                   selectionArgs:nil
                                                                                                         orderBy:@"ROWID ASC"
                                                                                                           limit:nil];
                EMSRequestModelMapper *mapper = [[EMSRequestModelMapper alloc] init];

                NSString *statement = [EMSSQLStatementFactory createQueryStatementWithTableName:mapper.tableName
                                                                                      selection:specification.selection
                                                                                        orderBy:specification.orderBy
                                                                                          limit:specification.limit];
                [[statement should] equal:@"SELECT * FROM request ORDER BY ROWID ASC;"];
            });

            it(@"should return with correct statement when limit set", ^{
                id <EMSSQLSpecificationProtocol> specification = [[FakeSQLSpecification alloc] initWithSelection:nil
                                                                                                   selectionArgs:nil
                                                                                                         orderBy:nil
                                                                                                           limit:@"1"];
                EMSRequestModelMapper *mapper = [[EMSRequestModelMapper alloc] init];

                NSString *statement = [EMSSQLStatementFactory createQueryStatementWithTableName:mapper.tableName
                                                                                      selection:specification.selection
                                                                                        orderBy:specification.orderBy
                                                                                          limit:specification.limit];
                [[statement should] equal:@"SELECT * FROM request LIMIT 1;"];
            });
            it(@"should return with correct statement when everything is set", ^{
                id <EMSSQLSpecificationProtocol> specification = [[FakeSQLSpecification alloc] initWithSelection:@"a = ?"
                                                                                                   selectionArgs:@[@"10"]
                                                                                                         orderBy:@"ROWID ASC"
                                                                                                           limit:@"1"];
                EMSRequestModelMapper *mapper = [[EMSRequestModelMapper alloc] init];

                NSString *statement = [EMSSQLStatementFactory createQueryStatementWithTableName:mapper.tableName
                                                                                      selection:specification.selection
                                                                                        orderBy:specification.orderBy
                                                                                          limit:specification.limit];
                [[statement should] equal:@"SELECT * FROM request WHERE a = ? ORDER BY ROWID ASC LIMIT 1;"];
            });
        });

        describe(@"createDeleteStatementWithSpecification:mapper:", ^{

            it(@"should return with correct statement", ^{
                id <EMSSQLSpecificationProtocol> specification = [[FakeSQLSpecification alloc] initWithSelection:@"a = ?"
                                                                                                   selectionArgs:@[@"10"]
                                                                                                         orderBy:@"ROWID ASC"
                                                                                                           limit:@"1"];
                EMSRequestModelMapper *mapper = [[EMSRequestModelMapper alloc] init];

                NSString *statement = [EMSSQLStatementFactory createDeleteStatementWithTableName:mapper.tableName
                                                                                       selection:specification.selection];
                [[statement should] equal:@"DELETE * FROM request WHERE a = ?;"];
            });
        });

SPEC_END
