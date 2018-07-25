//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "EMSRequestModelRepository.h"
#import "Kiwi.h"
#import "MERequestModelRepositoryFactory.h"
#import "MEInApp.h"
#import "MERequestContext.h"

SPEC_BEGIN(MERequestModelRepositoryFactoryTests)


        describe(@"initWithInApp:requestContext:", ^{
            it(@"should set inApp after init", ^{
                MEInApp *inApp = [MEInApp mock];
                MERequestModelRepositoryFactory *factory = [[MERequestModelRepositoryFactory alloc] initWithInApp:inApp
                                                                                                   requestContext:[MERequestContext mock]];
                [[factory.inApp shouldNot] beNil];
            });

            it(@"should set requestContext after init", ^{
                MEInApp *inApp = [MEInApp mock];
                MERequestModelRepositoryFactory *factory = [[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                                   requestContext:[MERequestContext mock]];
                [[factory.inApp shouldNot] beNil];
            });

            it(@"should throw an exception when there is no inApp", ^{
                @try {
                    MERequestModelRepositoryFactory *factory = [[MERequestModelRepositoryFactory alloc] initWithInApp:nil
                                                                                                       requestContext:[MERequestContext mock]];
                    fail(@"Expected Exception when inApp is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: inApp"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw an exception when there is no requestContext", ^{
                @try {
                    MERequestModelRepositoryFactory *factory = [[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                                       requestContext:nil];
                    fail(@"Expected Exception when requestContext is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: requestContext"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });
        });

        describe(@"create", ^{
            it(@"should not return nil for parameter NO", ^{
                MERequestModelRepositoryFactory *factory = [[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                                   requestContext:[MERequestContext mock]];
                [[((NSObject *) [factory createWithBatchCustomEventProcessing:NO]) shouldNot] beNil];
            });

            it(@"should not return nil for parameter YES", ^{
                MERequestModelRepositoryFactory *factory = [[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                                   requestContext:[MERequestContext mock]];
                [[((NSObject *) [factory createWithBatchCustomEventProcessing:YES]) shouldNot] beNil];
            });

            it(@"should return EMSRequestModelRepository for parameter NO", ^{
                MERequestModelRepositoryFactory *factory = [[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                                   requestContext:[MERequestContext mock]];

                id <EMSRequestModelRepositoryProtocol> repository = [factory createWithBatchCustomEventProcessing:NO];
                [[[[repository class] description] should] equal:@"EMSRequestModelRepository"];
            });

            it(@"should return MERequestRepositoryProxy for parameter YES", ^{
                MERequestModelRepositoryFactory *factory = [[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                                   requestContext:[MERequestContext mock]];

                id <EMSRequestModelRepositoryProtocol> repository = [factory createWithBatchCustomEventProcessing:YES];
                [[[[repository class] description] should] equal:@"MERequestRepositoryProxy"];
            });
        });

SPEC_END
