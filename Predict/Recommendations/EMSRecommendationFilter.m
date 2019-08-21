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

+ (id <EMSRecommendationFilterProtocol>)excludeWithField:(NSString *)field
                                           isExpectation:(NSString *)expectation {
    NSParameterAssert(field);
    NSParameterAssert(expectation);
    return [[EMSRecommendationFilter alloc] initWithType:@"EXCLUDE"
                                          withComparison:@"IS"
                                               withField:field
                                        withExpectations:@[expectation]];
}

+ (id <EMSRecommendationFilterProtocol>)excludeWithField:(NSString *)field
                                          inExpectations:(NSArray <NSString *> *)expectations {
    NSParameterAssert(field);
    NSParameterAssert(expectations);
    return [[EMSRecommendationFilter alloc] initWithType:@"EXCLUDE"
                                          withComparison:@"IN"
                                               withField:field
                                        withExpectations:expectations];
}

+ (id <EMSRecommendationFilterProtocol>)excludeWithField:(NSString *)field
                                          hasExpectation:(NSString *)expectation {
    NSParameterAssert(field);
    NSParameterAssert(expectation);
    return [[EMSRecommendationFilter alloc] initWithType:@"EXCLUDE"
                                          withComparison:@"HAS"
                                               withField:field
                                        withExpectations:@[expectation]];
}

+ (id <EMSRecommendationFilterProtocol>)excludeWithField:(NSString *)field
                                    overlapsExpectations:(NSArray <NSString *> *)expectations {
    NSParameterAssert(field);
    NSParameterAssert(expectations);
    return [[EMSRecommendationFilter alloc] initWithType:@"EXCLUDE"
                                          withComparison:@"OVERLAPS"
                                               withField:field
                                        withExpectations:expectations];
}

+ (id <EMSRecommendationFilterProtocol>)includeWithField:(NSString *)field
                                           isExpectation:(NSString *)expectation {
    NSParameterAssert(field);
    NSParameterAssert(expectation);
    return [[EMSRecommendationFilter alloc] initWithType:@"INCLUDE"
                                          withComparison:@"IS"
                                               withField:field
                                        withExpectations:@[expectation]];
}

+ (id <EMSRecommendationFilterProtocol>)includeWithField:(NSString *)field
                                          inExpectations:(NSArray <NSString *> *)expectations {
    NSParameterAssert(field);
    NSParameterAssert(expectations);
    return [[EMSRecommendationFilter alloc] initWithType:@"INCLUDE"
                                          withComparison:@"IN"
                                               withField:field
                                        withExpectations:expectations];
}

+ (id <EMSRecommendationFilterProtocol>)includeWithField:(NSString *)field
                                          hasExpectation:(NSString *)expectation {
    NSParameterAssert(field);
    NSParameterAssert(expectation);
    return [[EMSRecommendationFilter alloc] initWithType:@"INCLUDE"
                                          withComparison:@"HAS"
                                               withField:field
                                        withExpectations:@[expectation]];
}

+ (id <EMSRecommendationFilterProtocol>)includeWithField:(NSString *)field
                                    overlapsExpectations:(NSArray <NSString *> *)expectations {
    NSParameterAssert(field);
    NSParameterAssert(expectations);
    return [[EMSRecommendationFilter alloc] initWithType:@"INCLUDE"
                                          withComparison:@"OVERLAPS"
                                               withField:field
                                        withExpectations:expectations];
}

@end