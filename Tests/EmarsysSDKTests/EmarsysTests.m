//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Kiwi.h"
#import "Emarsys.h"
#import "PredictInternal.h"

@interface Emarsys ()
+ (void)setPredictInternal:(PredictInternal *)predictInternal;
@end

SPEC_BEGIN(EmarsysTests)

        describe(@"setCustomerWithCustomerId:resultBlock:", ^{
            it(@"should delegate the call to predictInternal", ^{

                [Emarsys setupWithConfig:nil];

                PredictInternal *const internal = [PredictInternal mock];
                NSString *const customerId = @"customerId";
                [Emarsys setPredictInternal:internal];


                [[internal should] receive:@selector(setCustomerWithId:) withArguments:customerId];
                [Emarsys setCustomerWithId:customerId];
            });
        });
SPEC_END
