//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSLogic.h"
#import "EMSCartItemProtocol.h"
#import "EMSCartItemUtils.h"

@interface EMSLogic ()

@property(nonatomic, strong) NSString *logic;
@property(nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *data;

@end

@implementation EMSLogic

- (instancetype)initWithLogic:(NSString *)logic
                         data:(nullable NSDictionary<NSString *, NSString *> *)data {
    if (self = [super init]) {
        _logic = logic;
        _data = data;
    }
    return self;
}

+ (EMSLogic *)search {
    return [EMSLogic searchWithSearchTerm:nil];
}

+ (EMSLogic *)searchWithSearchTerm:(NSString *)searchTerm {
    return [[EMSLogic alloc] initWithLogic:@"SEARCH"
                                      data:@{@"q": searchTerm ? searchTerm : @""}];
}

+ (EMSLogic *)cart {
    return [EMSLogic cartWithCartItems:nil];
}

+ (EMSLogic *)cartWithCartItems:(NSArray<id <EMSCartItemProtocol>> *)cartItems {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"cv"] = @"1";
    data[@"ca"] = [EMSCartItemUtils queryParamFromCartItems:cartItems];

    return [[EMSLogic alloc] initWithLogic:@"CART"
                                      data:data];
}

+ (EMSLogic *)related {
    return [EMSLogic relatedWithViewItemId:nil];
}

+ (EMSLogic *)relatedWithViewItemId:(NSString *)itemId {
    return [[EMSLogic alloc] initWithLogic:@"RELATED"
                                      data:@{@"v": itemId ? [NSString stringWithFormat:@"i:%@", itemId] : @""}];
}

+ (EMSLogic *)category {
    return [EMSLogic categoryWithCategoryPath:nil];
}

+ (EMSLogic *)categoryWithCategoryPath:(NSString *)categoryPath {
    return [[EMSLogic alloc] initWithLogic:@"CATEGORY"
                                      data:@{@"vc": categoryPath ? categoryPath : @""}];
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
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.logic hash];
    hash = hash * 31u + [self.data hash];
    return hash;
}

@end