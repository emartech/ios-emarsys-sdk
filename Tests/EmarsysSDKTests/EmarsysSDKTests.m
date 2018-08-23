//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Kiwi.h"
#import "EmarsysSDK.h"

SPEC_BEGIN(EmarsysSDKTests)

        describe(@"setCustomerWithCustomerId:resultBlock:", ^{
            it(@"should throw exception when customerId is nil", ^{
                @try {
                    [EmarsysSDK setCustomerWithCustomerId:nil
                                              resultBlock:^(NSError *error) {}];
                    fail(@"Expected Exception when customerId is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: customerId"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });
        });
SPEC_END
