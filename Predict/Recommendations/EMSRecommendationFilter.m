//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSRecommendationFilterProtocol.h"
#import "EMSRecommendationFilter.h"

@interface EMSRecommendationFilter ()

@property(nonatomic, strong) NSString *type;
@property(nonatomic, strong) NSString *comparison;
@property(nonatomic, strong) NSString *field;
@property(nonatomic, strong) NSArray <NSString *> *expectations;

@end

@implementation EMSRecommendationFilter

- (instancetype)initWithType:(NSString *)type
              withComparison:(NSString *)comparison
                   withField:(NSString *)field
            withExpectations:(NSArray <NSString *> *)expectations {
    if (self = [super init]) {
        _type = type;
        _comparison = comparison;
        _field = field;
        _expectations = expectations;
    }
    return self;
}

+ (id <EMSRecommendationFilterProtocol>)excludeFilterWithField:(NSString *)field
                                                       isValue:(NSString *)value {
    NSParameterAssert(field);
    NSParameterAssert(value);
    return [[EMSRecommendationFilter alloc] initWithType:@"EXCLUDE"
                                          withComparison:@"IS"
                                               withField:field
                                        withExpectations:@[value]];
}

+ (id <EMSRecommendationFilterProtocol>)excludeFilterWithField:(NSString *)field
                                                      inValues:(NSArray <NSString *> *)values {
    NSParameterAssert(field);
    NSParameterAssert(values);
    return [[EMSRecommendationFilter alloc] initWithType:@"EXCLUDE"
                                          withComparison:@"IN"
                                               withField:field
                                        withExpectations:values];
}

+ (id <EMSRecommendationFilterProtocol>)excludeFilterWithField:(NSString *)field
                                                      hasValue:(NSString *)value {
    NSParameterAssert(field);
    NSParameterAssert(value);
    return [[EMSRecommendationFilter alloc] initWithType:@"EXCLUDE"
                                          withComparison:@"HAS"
                                               withField:field
                                        withExpectations:@[value]];
}

+ (id <EMSRecommendationFilterProtocol>)excludeFilterWithField:(NSString *)field
                                                overlapsValues:(NSArray <NSString *> *)values {
    NSParameterAssert(field);
    NSParameterAssert(values);
    return [[EMSRecommendationFilter alloc] initWithType:@"EXCLUDE"
                                          withComparison:@"OVERLAPS"
                                               withField:field
                                        withExpectations:values];
}

+ (id <EMSRecommendationFilterProtocol>)includeFilterWithField:(NSString *)field
                                                       isValue:(NSString *)value {
    NSParameterAssert(field);
    NSParameterAssert(value);
    return [[EMSRecommendationFilter alloc] initWithType:@"INCLUDE"
                                          withComparison:@"IS"
                                               withField:field
                                        withExpectations:@[value]];
}

+ (id <EMSRecommendationFilterProtocol>)includeFilterWithField:(NSString *)field
                                                      inValues:(NSArray <NSString *> *)values {
    NSParameterAssert(field);
    NSParameterAssert(values);
    return [[EMSRecommendationFilter alloc] initWithType:@"INCLUDE"
                                          withComparison:@"IN"
                                               withField:field
                                        withExpectations:values];
}

+ (id <EMSRecommendationFilterProtocol>)includeFilterWithField:(NSString *)field
                                                      hasValue:(NSString *)value {
    NSParameterAssert(field);
    NSParameterAssert(value);
    return [[EMSRecommendationFilter alloc] initWithType:@"INCLUDE"
                                          withComparison:@"HAS"
                                               withField:field
                                        withExpectations:@[value]];
}

+ (id <EMSRecommendationFilterProtocol>)includeFilterWithField:(NSString *)field
                                                overlapsValues:(NSArray <NSString *> *)values {
    NSParameterAssert(field);
    NSParameterAssert(values);
    return [[EMSRecommendationFilter alloc] initWithType:@"INCLUDE"
                                          withComparison:@"OVERLAPS"
                                               withField:field
                                        withExpectations:values];
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToFilter:other];
}

- (BOOL)isEqualToFilter:(EMSRecommendationFilter *)filter {
    if (self == filter)
        return YES;
    if (filter == nil)
        return NO;
    if (self.type != filter.type && ![self.type isEqualToString:filter.type])
        return NO;
    if (self.comparison != filter.comparison && ![self.comparison isEqualToString:filter.comparison])
        return NO;
    if (self.field != filter.field && ![self.field isEqualToString:filter.field])
        return NO;
    if (self.expectations != filter.expectations && ![self.expectations isEqualToArray:filter.expectations])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.type hash];
    hash = hash * 31u + [self.comparison hash];
    hash = hash * 31u + [self.field hash];
    hash = hash * 31u + [self.expectations hash];
    return hash;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.type=%@", self.type];
    [description appendFormat:@", self.comparison=%@", self.comparison];
    [description appendFormat:@", self.field=%@", self.field];
    [description appendFormat:@", self.expectations=%@", self.expectations];
    [description appendString:@">"];
    return description;
}

@end