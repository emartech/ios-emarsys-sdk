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
    return [NSString stringWithFormat:@"i:%@,p:%@,q:%@",
                                      [cartItem itemId],
                                      @([cartItem price]).stringValue,
                                      @([cartItem quantity]).stringValue];
}

@end