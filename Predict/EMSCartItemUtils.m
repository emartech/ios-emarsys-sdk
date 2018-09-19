//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "EMSCartItemUtils.h"


@implementation EMSCartItemUtils {

}

+ (NSString *)queryParamFromCartItems:(NSArray<id <EMSCartItemProtocol>> *)cartItems {
    NSMutableString *result = [NSMutableString new];
    for (id <EMSCartItemProtocol> cartItem in cartItems) {
        [result appendString:[self queryParamFromCartItem:cartItem]];

        if (cartItem != [cartItems lastObject]) {
            [result appendString:@"|"];
        }
    }
    return [NSString stringWithString:result];
}

+ (NSString *)queryParamFromCartItem:(id <EMSCartItemProtocol>)cartItem {
    return [NSString stringWithFormat:@"i:%@,p:%0.1f,q:%.01f", [cartItem itemId], [cartItem price], [cartItem quantity]];
}

@end