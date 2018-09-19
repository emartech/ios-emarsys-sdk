//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSCartItem.h"
#import "EMSCartItemUtils.h"

SPEC_BEGIN(EMSCartItemUtilsTests)

        describe(@"queryParamFromCartItems:", ^{

            it(@"should return empty string for empty array", ^{
                [[[EMSCartItemUtils queryParamFromCartItems:@[]] should] equal:@""];
            });

            it(@"should return the correct string for one item", ^{
                [[[EMSCartItemUtils queryParamFromCartItems:@[[EMSCartItem itemWithItemId:@"1" price:100.0 quantity:2.0]]] should] equal:@"i:1,p:100.0,q:2.0"];
            });

            it(@"should return the correct string for multiple items", ^{
                [[[EMSCartItemUtils queryParamFromCartItems:@[
                        [EMSCartItem itemWithItemId:@"1" price:100.0 quantity:2.0],
                        [EMSCartItem itemWithItemId:@"2" price:200.0 quantity:4.0],
                        [EMSCartItem itemWithItemId:@"3" price:300.0 quantity:8.0]
                ]] should]
                        equal:@"i:1,p:100.0,q:2.0|i:2,p:200.0,q:4.0|i:3,p:300.0,q:8.0"];
            });

        });

SPEC_END
