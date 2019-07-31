//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSLogicProtocol.h"

@protocol EMSCartItemProtocol;

@interface EMSLogic : NSObject <EMSLogicProtocol>

+ (EMSLogic *)search;

+ (EMSLogic *)searchWithSearchTerm:(nullable NSString *)searchTerm;

+ (EMSLogic *)cart;

+ (EMSLogic *)cartWithCartItems:(nullable NSArray<id <EMSCartItemProtocol>> *)cartItems;

+ (EMSLogic *)related;

+ (EMSLogic *)relatedWithViewItemId:(nullable NSString *)itemId;

+ (EMSLogic *)category;

+ (EMSLogic *)categoryWithCategoryPath:(NSString *)categoryPath;

@end