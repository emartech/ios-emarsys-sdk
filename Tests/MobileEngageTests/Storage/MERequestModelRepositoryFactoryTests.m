//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "EMSRequestModelRepository.h"
#import "Kiwi.h"
#import "MERequestModelRepositoryFactory.h"
#import "MEInApp.h"
#import "MERequestContext.h"
#import "MEButtonClickRepository.h"
#import "MEDisplayedIAMRepository.h"
#import "EMSSqliteSchemaHandler.h"
#import "EMSEndpoint.h"

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestDB.db"]

SPEC_BEGIN(MERequestModelRepositoryFactoryTests)


        describe(@"initWithInApp:requestContext:dbHelper:buttonClickRepository:displayedIAMRepository:endpoint:", ^{
            it(@"should set inApp after init", ^{
                MEInApp *inApp = [MEInApp mock];
                MERequestModelRepositoryFactory *factory = [[MERequestModelRepositoryFactory alloc] initWithInApp:inApp
                                                                                                   requestContext:[MERequestContext mock]
                                                                                                         dbHelper:[[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                                                                                                                 schemaDelegate:[EMSSqliteSchemaHandler new]]
                                                                                            buttonClickRepository:[MEButtonClickRepository mock]
                                                                                           displayedIAMRepository:[MEDisplayedIAMRepository mock]
                                                                                                         endpoint:[EMSEndpoint mock]];
                [[factory.inApp shouldNot] beNil];
            });

            it(@"should set requestContext after init", ^{
                MEInApp *inApp = [MEInApp mock];
                MERequestModelRepositoryFactory *factory = [[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                                   requestContext:[MERequestContext mock]
                                                                                                         dbHelper:[[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                                                                                                                 schemaDelegate:[EMSSqliteSchemaHandler new]]
                                                                                            buttonClickRepository:[MEButtonClickRepository mock]
                                                                                           displayedIAMRepository:[MEDisplayedIAMRepository mock]
                                                                                                         endpoint:[EMSEndpoint mock]];
                [[factory.inApp shouldNot] beNil];
            });

            it(@"should throw an exception when there is no inApp", ^{
                @try {
                    MERequestModelRepositoryFactory *factory = [[MERequestModelRepositoryFactory alloc] initWithInApp:nil
                                                                                                       requestContext:[MERequestContext mock]
                                                                                                             dbHelper:[[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                                                                                                                     schemaDelegate:[EMSSqliteSchemaHandler new]]
                                                                                                buttonClickRepository:[MEButtonClickRepository mock]
                                                                                               displayedIAMRepository:[MEDisplayedIAMRepository mock]
                                                                                                             endpoint:[EMSEndpoint mock]];
                    fail(@"Expected Exception when inApp is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: inApp"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw an exception when there is no requestContext", ^{
                @try {
                    MERequestModelRepositoryFactory *factory = [[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                                       requestContext:nil
                                                                                                             dbHelper:[[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                                                                                                                     schemaDelegate:[EMSSqliteSchemaHandler new]]
                                                                                                buttonClickRepository:[MEButtonClickRepository mock]
                                                                                               displayedIAMRepository:[MEDisplayedIAMRepository mock]
                                                                                                             endpoint:[EMSEndpoint mock]];
                    fail(@"Expected Exception when requestContext is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: requestContext"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw an exception when there is no dbHelper", ^{
                @try {
                    MERequestModelRepositoryFactory *factory = [[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                                       requestContext:[MERequestContext mock]
                                                                                                             dbHelper:nil
                                                                                                buttonClickRepository:[MEButtonClickRepository mock]
                                                                                               displayedIAMRepository:[MEDisplayedIAMRepository mock]
                                                                                                             endpoint:[EMSEndpoint mock]];
                    fail(@"Expected Exception when dbHelper is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: dbHelper"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw an exception when there is no buttonClickRepository", ^{
                @try {
                    MERequestModelRepositoryFactory *factory = [[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                                       requestContext:[MERequestContext mock]
                                                                                                             dbHelper:[EMSSQLiteHelper mock]
                                                                                                buttonClickRepository:nil
                                                                                               displayedIAMRepository:[MEDisplayedIAMRepository mock]
                                                                                                             endpoint:[EMSEndpoint mock]];
                    fail(@"Expected Exception when buttonClickRepository is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: buttonClickRepository"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw an exception when there is no displayedIAMRepository", ^{
                @try {
                    MERequestModelRepositoryFactory *factory = [[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                                       requestContext:[MERequestContext mock]
                                                                                                             dbHelper:[EMSSQLiteHelper mock]
                                                                                                buttonClickRepository:[MEButtonClickRepository mock]
                                                                                               displayedIAMRepository:nil
                                                                                                             endpoint:[EMSEndpoint mock]];
                    fail(@"Expected Exception when displayedIAMRepository is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: displayedIAMRepository"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw an exception when there is no endpoint", ^{
                @try {
                    MERequestModelRepositoryFactory *factory = [[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                                       requestContext:[MERequestContext mock]
                                                                                                             dbHelper:[EMSSQLiteHelper mock]
                                                                                                buttonClickRepository:[MEButtonClickRepository mock]
                                                                                               displayedIAMRepository:[MEDisplayedIAMRepository mock]
                                                                                                             endpoint:nil];
                    fail(@"Expected Exception when endpoint is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: endpoint"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });
        });

        describe(@"create", ^{
            it(@"should not return nil for parameter NO", ^{
                MERequestModelRepositoryFactory *factory = [[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                                   requestContext:[MERequestContext mock]
                                                                                                         dbHelper:[[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                                                                                                                 schemaDelegate:[EMSSqliteSchemaHandler new]]
                                                                                            buttonClickRepository:[MEButtonClickRepository mock]
                                                                                           displayedIAMRepository:[MEDisplayedIAMRepository mock]
                                                                                                         endpoint:[EMSEndpoint mock]];
                [[((NSObject *) [factory createWithBatchCustomEventProcessing:NO]) shouldNot] beNil];
            });

            it(@"should not return nil for parameter YES", ^{
                MERequestModelRepositoryFactory *factory = [[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                                   requestContext:[MERequestContext mock]
                                                                                                         dbHelper:[[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                                                                                                                 schemaDelegate:[EMSSqliteSchemaHandler new]]
                                                                                            buttonClickRepository:[MEButtonClickRepository mock]
                                                                                           displayedIAMRepository:[MEDisplayedIAMRepository mock]
                                                                                                         endpoint:[EMSEndpoint mock]];
                [[((NSObject *) [factory createWithBatchCustomEventProcessing:YES]) shouldNot] beNil];
            });

            it(@"should return EMSRequestModelRepository for parameter NO", ^{
                MERequestModelRepositoryFactory *factory = [[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                                   requestContext:[MERequestContext mock]
                                                                                                         dbHelper:[[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                                                                                                                 schemaDelegate:[EMSSqliteSchemaHandler new]]
                                                                                            buttonClickRepository:[MEButtonClickRepository mock]
                                                                                           displayedIAMRepository:[MEDisplayedIAMRepository mock]
                                                                                                         endpoint:[EMSEndpoint mock]];

                id <EMSRequestModelRepositoryProtocol> repository = [factory createWithBatchCustomEventProcessing:NO];
                [[[[repository class] description] should] equal:@"EMSRequestModelRepository"];
            });

            it(@"should return MERequestRepositoryProxy for parameter YES", ^{
                MERequestModelRepositoryFactory *factory = [[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                                   requestContext:[MERequestContext mock]
                                                                                                         dbHelper:[[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                                                                                                                 schemaDelegate:[EMSSqliteSchemaHandler new]]
                                                                                            buttonClickRepository:[MEButtonClickRepository mock]
                                                                                           displayedIAMRepository:[MEDisplayedIAMRepository mock]
                                                                                                         endpoint:[EMSEndpoint mock]];

                id <EMSRequestModelRepositoryProtocol> repository = [factory createWithBatchCustomEventProcessing:YES];
                [[[[repository class] description] should] equal:@"MERequestRepositoryProxy"];
            });
        });

SPEC_END
