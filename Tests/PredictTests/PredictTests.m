//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "Predict.h"

SPEC_BEGIN(PredictTests)

        describe(@"trackCategoryViewWithCategoryPath:", ^{
            it(@"should throw exception when categoryPath is nil", ^{
                @try {
                    [Predict trackCategoryViewWithCategoryPath:nil];
                    fail(@"Expected Exception when categoryPath is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: categoryPath"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });
        });
SPEC_END
