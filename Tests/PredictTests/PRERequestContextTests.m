//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "PRERequestContext.h"

SPEC_BEGIN(PRERequestContextTests)

        describe(@"setCustomerId:", ^{
            it(@"should persist the parameter", ^{
                NSString *const customerId = @"testId";
                [[[PRERequestContext alloc] initWithConfig:nil] setCustomerId:customerId];
                [[[[[PRERequestContext alloc] initWithConfig:nil] customerId] should] equal:customerId];
            });
        });

SPEC_END
