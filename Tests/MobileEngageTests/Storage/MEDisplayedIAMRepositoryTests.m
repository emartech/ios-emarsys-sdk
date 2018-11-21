//
// Copyright (c) 2017 Emarsys. All rights reserved.
//
#import "Kiwi.h"
#import "MEDisplayedIAMRepository.h"
#import "EMSFilterByNothingSpecification.h"
#import "EMSFilterByValuesSpecification.h"
#import "EMSSqliteSchemaHandler.h"
#import "EMSSchemaContract.h"

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestMEDB.db"]

SPEC_BEGIN(MEDisplayedIAMRepositoryTests)

    __block EMSSQLiteHelper *helper;
    __block MEDisplayedIAMRepository *repository;

    beforeEach(^{
        [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                                   error:nil];
        helper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH schemaDelegate:[EMSSqliteSchemaHandler new]];
        [helper open];
        repository = [[MEDisplayedIAMRepository alloc] initWithDbHelper:helper];
    });

    afterEach(^{
        [helper close];
    });

    describe(@"requestModelRepository", ^{
        it(@"should add the element to the database", ^{
            MEDisplayedIAM *displayedIAM = [[MEDisplayedIAM alloc] initWithCampaignId:@"12345678" timestamp:[NSDate date]];

            [repository add:displayedIAM];

            NSArray<MEDisplayedIAM *> *items = [repository query:[EMSFilterByNothingSpecification new]];
            [[theValue([items count]) should] equal:theValue(1)];
            [[[items lastObject] should] equal:displayedIAM];
        });

        it(@"should delete element from database", ^{
            MEDisplayedIAM *displayedIAMFirst = [[MEDisplayedIAM alloc] initWithCampaignId:@"12345678" timestamp:[NSDate date]];
            MEDisplayedIAM *displayedIAMSecond = [[MEDisplayedIAM alloc] initWithCampaignId:@"98765432" timestamp:[NSDate date]];

            [repository add:displayedIAMFirst];
            [repository add:displayedIAMSecond];

            EMSFilterByValuesSpecification *filterByIdSpecification = [[EMSFilterByValuesSpecification alloc] initWithValues:@[@"98765432"]
                                                                                                                      column:COLUMN_NAME_CAMPAIGN_ID];
            [repository remove:filterByIdSpecification];

            NSArray<MEDisplayedIAM *> *items = [repository query:[EMSFilterByNothingSpecification new]];
            [[theValue([items count]) should] equal:theValue(1)];
            [[[items lastObject] should] equal:displayedIAMFirst];
        });
    });

SPEC_END
