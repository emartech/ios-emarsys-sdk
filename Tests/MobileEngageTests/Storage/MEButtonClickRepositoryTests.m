//
// Copyright (c) 2017 Emarsys. All rights reserved.
//
#import "Kiwi.h"
#import "EMSSqliteSchemaHandler.h"
#import "MEButtonClickRepository.h"
#import "MEButtonClickFilterNoneSpecification.h"
#import "MEButtonClickFilterByCampaignIdSpecification.h"

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestMEDB.db"]

SPEC_BEGIN(MEButtonClickRepositoryTests)

        __block EMSSQLiteHelper *helper;
        __block MEButtonClickRepository *repository;

        beforeEach(^{
            [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                                       error:nil];
            helper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                    schemaDelegate:[EMSSqliteSchemaHandler new]];
            [helper open];
            repository = [[MEButtonClickRepository alloc] initWithDbHelper:helper];
        });

        afterEach(^{
            [helper close];
            [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                                       error:nil];
        });

        describe(@"requestModelRepository", ^{
            it(@"should add the element to the database", ^{
                MEButtonClick *buttonClick = [[MEButtonClick alloc] initWithCampaignId:@"campaignId"
                                                                              buttonId:@"buttonId"
                                                                             timestamp:[NSDate date]];
                [repository add:buttonClick];

                NSArray<MEButtonClick *> *items = [repository query:[MEButtonClickFilterNoneSpecification new]];
                [[theValue([items count]) should] equal:theValue(1)];
                [[[items lastObject] should] equal:buttonClick];
            });

            it(@"should delete element from database", ^{
                MEButtonClick *buttonClickFirst = [[MEButtonClick alloc] initWithCampaignId:@"kamp1"
                                                                                   buttonId:@"button1"
                                                                                  timestamp:[NSDate date]];
                MEButtonClick *buttonClickSecond = [[MEButtonClick alloc] initWithCampaignId:@"kamp2"
                                                                                    buttonId:@"button2"
                                                                                   timestamp:[NSDate date]];

                [repository add:buttonClickFirst];
                [repository add:buttonClickSecond];

                [repository remove:[[MEButtonClickFilterByCampaignIdSpecification alloc] initWithCampaignId:@"kamp2"]];

                NSArray<MEButtonClick *> *items = [repository query:[MEButtonClickFilterNoneSpecification new]];
                [[theValue([items count]) should] equal:theValue(1)];
                [[[items lastObject] should] equal:buttonClickFirst];
            });
        });

SPEC_END
