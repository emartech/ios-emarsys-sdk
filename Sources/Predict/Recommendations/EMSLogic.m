//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSLogic.h"
#import "EMSCartItemProtocol.h"
#import "EMSCartItemUtils.h"

@interface EMSLogic ()

@property(nonatomic, strong) NSString *logic;
@property(nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *data;
@property(nonatomic, strong, nullable) NSArray <NSString *> *variants;

@end

@implementation EMSLogic

- (instancetype)initWithLogic:(NSString *)logic
                         data:(nullable NSDictionary<NSString *, NSString *> *)data
                     variants:(nullable NSArray <NSString *> *)variants {
    if (self = [super init]) {
        _logic = logic;
        _data = data;
        _variants = variants;
    }
    return self;
}

+ (EMSLogic *)search {
    return [EMSLogic searchWithSearchTerm:nil];
}

+ (EMSLogic *)searchWithSearchTerm:(nullable NSString *)searchTerm {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"q"] = searchTerm;
    return [[EMSLogic alloc] initWithLogic:@"SEARCH"
                                      data:[NSDictionary dictionaryWithDictionary:data]
                                  variants:nil];
}

+ (EMSLogic *)cart {
    return [EMSLogic cartWithCartItems:nil];
}

+ (EMSLogic *)cartWithCartItems:(nullable NSArray<id <EMSCartItemProtocol>> *)cartItems {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    if (cartItems) {
        data[@"cv"] = @"1";
        data[@"ca"] = [EMSCartItemUtils queryParamFromCartItems:cartItems];
    }
    return [[EMSLogic alloc] initWithLogic:@"CART"
                                      data:[NSDictionary dictionaryWithDictionary:data]
                                  variants:nil];
}

+ (EMSLogic *)related {
    return [EMSLogic relatedWithViewItemId:nil];
}

+ (EMSLogic *)relatedWithViewItemId:(nullable NSString *)itemId {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    if (itemId) {
        data[@"v"] = [NSString stringWithFormat:@"i:%@", itemId];
    }
    return [[EMSLogic alloc] initWithLogic:@"RELATED"
                                      data:[NSDictionary dictionaryWithDictionary:data]
                                  variants:nil];
}

+ (EMSLogic *)category {
    return [EMSLogic categoryWithCategoryPath:nil];
}

+ (EMSLogic *)categoryWithCategoryPath:(nullable NSString *)categoryPath {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"vc"] = categoryPath;
    return [[EMSLogic alloc] initWithLogic:@"CATEGORY"
                                      data:[NSDictionary dictionaryWithDictionary:data]
                                  variants:nil];
}

+ (EMSLogic *)alsoBought {
    return [EMSLogic alsoBoughtWithViewItemId:nil];
}

+ (EMSLogic *)alsoBoughtWithViewItemId:(nullable NSString *)itemId {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    if (itemId) {
        data[@"v"] = [NSString stringWithFormat:@"i:%@", itemId];
    }
    return [[EMSLogic alloc] initWithLogic:@"ALSO_BOUGHT"
                                      data:[NSDictionary dictionaryWithDictionary:data]
                                  variants:nil];
}

+ (EMSLogic *)popular {
    return [EMSLogic popularWithCategoryPath:nil];
}

+ (EMSLogic *)popularWithCategoryPath:(nullable NSString *)categoryPath {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"vc"] = categoryPath;
    return [[EMSLogic alloc] initWithLogic:@"POPULAR"
                                      data:[NSDictionary dictionaryWithDictionary:data]
                                  variants:nil];
}

+ (EMSLogic *)personal {
    return [EMSLogic personalWithVariants:nil];
}

+ (EMSLogic *)personalWithVariants:(nullable NSArray<NSString *> *)variants {
    return [[EMSLogic alloc] initWithLogic:@"PERSONAL"
                                      data:@{}
                                  variants:variants];
}

+ (EMSLogic *)home {
    return [EMSLogic homeWithVariants:nil];
}

+ (EMSLogic *)homeWithVariants:(nullable NSArray<NSString *> *)variants {
    return [[EMSLogic alloc] initWithLogic:@"HOME"
                                      data:@{}
                                  variants:variants];
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToLogic:other];
}

- (BOOL)isEqualToLogic:(EMSLogic *)logic {
    if (self == logic)
        return YES;
    if (logic == nil)
        return NO;
    if (self.logic != logic.logic && ![self.logic isEqualToString:logic.logic])
        return NO;
    if (self.data != logic.data && ![self.data isEqualToDictionary:logic.data])
        return NO;
    if (self.variants != logic.variants && ![self.variants isEqualToArray:logic.variants])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.logic hash];
    hash = hash * 31u + [self.data hash];
    hash = hash * 31u + [self.variants hash];
    return hash;
}


@end