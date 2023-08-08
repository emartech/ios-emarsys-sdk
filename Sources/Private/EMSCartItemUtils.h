//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSCartItemProtocol.h"

@interface EMSCartItemUtils : NSObject

+ (NSString *)queryParamFromCartItems:(NSArray<id <EMSCartItemProtocol>> *)cartItems;

@end