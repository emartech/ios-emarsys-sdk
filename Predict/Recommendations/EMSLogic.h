//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSLogicProtocol.h"

@protocol EMSCartItemProtocol;

@interface EMSLogic : NSObject <EMSLogicProtocol>

+ (id<EMSLogicProtocol>)search;
+ (id<EMSLogicProtocol>)searchWithSearchTerm:(NSString *)searchTerm;

+ (id <EMSLogicProtocol>)cart;
+ (id <EMSLogicProtocol>)cartWithCartItems:(NSArray<id <EMSCartItemProtocol>> *)cartItems;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToLogic:(EMSLogic *)logic;

- (NSUInteger)hash;

@end