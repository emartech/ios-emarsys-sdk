//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EmarsysSDK/EMSLogicProtocol.h>

@protocol EMSCartItemProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface EMSLogic : NSObject <EMSLogicProtocol>

+ (EMSLogic *)search;

+ (EMSLogic *)searchWithSearchTerm:(nullable NSString *)searchTerm;

+ (EMSLogic *)cart;

+ (EMSLogic *)cartWithCartItems:(nullable NSArray<id <EMSCartItemProtocol>> *)cartItems;

+ (EMSLogic *)related;

+ (EMSLogic *)relatedWithViewItemId:(nullable NSString *)itemId;

+ (EMSLogic *)category;

+ (EMSLogic *)categoryWithCategoryPath:(nullable NSString *)categoryPath;

+ (EMSLogic *)alsoBought;

+ (EMSLogic *)alsoBoughtWithViewItemId:(nullable NSString *)itemId;

+ (EMSLogic *)popular;

+ (EMSLogic *)popularWithCategoryPath:(nullable NSString *)categoryPath;

+ (EMSLogic *)personal;

+ (EMSLogic *)personalWithVariants:(nullable NSArray<NSString *> *)variants;

+ (EMSLogic *)home;

+ (EMSLogic *)homeWithVariants:(nullable NSArray<NSString *> *)variants;

@end

NS_ASSUME_NONNULL_END
