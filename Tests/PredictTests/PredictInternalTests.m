//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "PredictInternal.h"
#import "PRERequestContext.h"
#import "EMSRequestManager.h"

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
                PRERequestContext *requestContextMock = [PRERequestContext mock];
                EMSRequestManager *requestManagerMock = [EMSRequestManager mock];
                NSString *const customerId = @"customerID";
                PredictInternal *internal = [[PredictInternal alloc] initWithRequestContext:requestContextMock
                                                                             requestManager:requestManagerMock];

                [[requestContextMock should] receive:@selector(setCustomerId:) withArguments:customerId];
                [internal setCustomerWithId:customerId];
            });

        });
SPEC_END
