//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSLogicProtocol.h"

@protocol EMSCartItemProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface EMSLogic : NSObject <EMSLogicProtocol>

+ (EMSLogic *)search;

+ (EMSLogic *)searchWithSearchTerm:(nullable NSString *)searchTerm
    NS_SWIFT_NAME(search(searchTerm:));

+ (EMSLogic *)cart;

+ (EMSLogic *)cartWithCartItems:(nullable NSArray<id <EMSCartItemProtocol>> *)cartItems
    NS_SWIFT_NAME(cart(cartItems:));

+ (EMSLogic *)related;

+ (EMSLogic *)relatedWithViewItemId:(nullable NSString *)itemId
    NS_SWIFT_NAME(related(itemId:));

+ (EMSLogic *)category;

+ (EMSLogic *)categoryWithCategoryPath:(nullable NSString *)categoryPath
    NS_SWIFT_NAME(category(categoryPath:));

+ (EMSLogic *)alsoBought;

+ (EMSLogic *)alsoBoughtWithViewItemId:(nullable NSString *)itemId
    NS_SWIFT_NAME(alsoBought(itemId:));

+ (EMSLogic *)popular;

+ (EMSLogic *)popularWithCategoryPath:(nullable NSString *)categoryPath
    NS_SWIFT_NAME(popular(categoryPath:));

+ (EMSLogic *)personal;

+ (EMSLogic *)personalWithVariants:(nullable NSArray<NSString *> *)variants
    NS_SWIFT_NAME(personal(variants:));

+ (EMSLogic *)home;

+ (EMSLogic *)homeWithVariants:(nullable NSArray<NSString *> *)variants
    NS_SWIFT_NAME(home(variants:));

@end

NS_ASSUME_NONNULL_END
