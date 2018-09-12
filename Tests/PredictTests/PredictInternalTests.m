//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "PredictInternal.h"
#import "PRERequestContext.h"
#import "EMSRequestManager.h"
#import "EMSShard.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"

SPEC_BEGIN(PredictInternalTests)

        describe(@"setCustomerWithId:", ^{

            it(@"should throw exception when customerId is nil", ^{
                @try {
                    [[PredictInternal new] setCustomerWithId:nil];
                    fail(@"Expected Exception when customerId is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: customerId"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should set the customerId in RequestContext", ^{
                PRERequestContext *requestContextMock = [PRERequestContext mock];
                EMSRequestManager *requestManagerMock = [EMSRequestManager mock];
                NSString *const customerId = @"customerID";
                PredictInternal *internal = [[PredictInternal alloc] initWithRequestContext:requestContextMock
                                                                             requestManager:requestManagerMock];

                [[requestContextMock should] receive:@selector(setCustomerId:) withArguments:customerId];
                [internal setCustomerWithId:customerId];
            });

        });

        describe(@"trackCategoryViewWithCategoryPath:", ^{

            it(@"should throw exception when categoryPath is nil", ^{
                @try {
                    [[PredictInternal new] trackCategoryViewWithCategoryPath:nil];
                    fail(@"Expected Exception when categoryPath is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: categoryPath"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

        });

        describe(@"trackItemViewWithItemId:", ^{

            it(@"should throw exception when itemId is nil", ^{
                @try {
                    [[PredictInternal new] trackItemViewWithItemId:nil];
                    fail(@"Expected Exception when itemId is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: itemId"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should submit shard to requestManager", ^{
                NSString *itemId = @"idOfTheItem";
                NSDate *timestamp = [NSDate date];
                NSUUID *uuid = [NSUUID UUID];

                EMSTimestampProvider *timestampProvider = [EMSTimestampProvider mock];
                EMSUUIDProvider *uuidProvider = [EMSUUIDProvider mock];
                [[uuidProvider should] receive:@selector(provideUUID)
                                     andReturn:uuid
                                     withCount:2];
                [[timestampProvider should] receive:@selector(provideTimestamp)
                                          andReturn:timestamp
                                          withCount:2];

                EMSShard *expectedShard = [EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                        [builder setType:@"predict_item_view"];
                        [builder payloadEntryWithKey:@"v"
                                               value:[NSString stringWithFormat:@"i:%@", itemId]];
                    }
                                                  timestampProvider:timestampProvider
                                                       uuidProvider:uuidProvider];

                EMSRequestManager *requestManager = [EMSRequestManager mock];
                [[requestManager should] receive:@selector(submitShard:)
                                   withArguments:expectedShard];

                PRERequestContext *requestContext = [[PRERequestContext alloc] initWithTimestampProvider:timestampProvider
                                                                                            uuidProvider:uuidProvider];
                PredictInternal *internal = [[PredictInternal alloc] initWithRequestContext:requestContext
                                                                             requestManager:requestManager];
                [internal trackItemViewWithItemId:itemId];
            });

        });
SPEC_END
