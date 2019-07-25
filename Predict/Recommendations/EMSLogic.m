//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSLogic.h"

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

+ (id <EMSLogicProtocol>)search {
    return [[EMSLogic alloc] initWithLogic:@"SEARCH"
                                      data:nil];
}

+ (id <EMSLogicProtocol>)searchWithSearchTerm:(NSString *)searchTerm {
    return [[EMSLogic alloc] initWithLogic:@"SEARCH"
                                      data:@{@"q": searchTerm}];
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