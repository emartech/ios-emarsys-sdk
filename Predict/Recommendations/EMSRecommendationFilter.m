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
    return [[EMSRecommendationFilter alloc] initWithType:@"exclude"
                                          withComparison:@"is"
                                               withField:field
                                        withExpectations:@[expectation]];
}

+ (id <EMSRecommendationFilterProtocol>)excludeWithField:(NSString *)field
                                          inExpectations:(NSArray <NSString *> *)expectations {
    NSParameterAssert(field);
    NSParameterAssert(expectations);
    return [[EMSRecommendationFilter alloc] initWithType:@"exclude"
                                          withComparison:@"in"
                                               withField:field
                                        withExpectations:expectations];
}

+ (id <EMSRecommendationFilterProtocol>)excludeWithField:(NSString *)field
                                          hasExpectation:(NSString *)expectation {
    NSParameterAssert(field);
    NSParameterAssert(expectation);
    return [[EMSRecommendationFilter alloc] initWithType:@"exclude"
                                          withComparison:@"has"
                                               withField:field
                                        withExpectations:@[expectation]];
}

+ (id <EMSRecommendationFilterProtocol>)excludeWithField:(NSString *)field
                                    overlapsExpectations:(NSArray <NSString *> *)expectations {
    NSParameterAssert(field);
    NSParameterAssert(expectations);
    return [[EMSRecommendationFilter alloc] initWithType:@"exclude"
                                          withComparison:@"overlaps"
                                               withField:field
                                        withExpectations:expectations];
}

+ (id <EMSRecommendationFilterProtocol>)includeWithField:(NSString *)field
                                           isExpectation:(NSString *)expectation {
    NSParameterAssert(field);
    NSParameterAssert(expectation);
    return [[EMSRecommendationFilter alloc] initWithType:@"include"
                                          withComparison:@"is"
                                               withField:field
                                        withExpectations:@[expectation]];
}

+ (id <EMSRecommendationFilterProtocol>)includeWithField:(NSString *)field
                                          inExpectations:(NSArray <NSString *> *)expectations {
    NSParameterAssert(field);
    NSParameterAssert(expectations);
    return [[EMSRecommendationFilter alloc] initWithType:@"include"
                                          withComparison:@"in"
                                               withField:field
                                        withExpectations:expectations];
}

+ (id <EMSRecommendationFilterProtocol>)includeWithField:(NSString *)field
                                          hasExpectation:(NSString *)expectation {
    NSParameterAssert(field);
    NSParameterAssert(expectation);
    return [[EMSRecommendationFilter alloc] initWithType:@"include"
                                          withComparison:@"has"
                                               withField:field
                                        withExpectations:@[expectation]];
}

+ (id <EMSRecommendationFilterProtocol>)includeWithField:(NSString *)field
                                    overlapsExpectations:(NSArray <NSString *> *)expectations {
    NSParameterAssert(field);
    NSParameterAssert(expectations);
    return [[EMSRecommendationFilter alloc] initWithType:@"include"
                                          withComparison:@"overlaps"
                                               withField:field
                                        withExpectations:expectations];
}

@end