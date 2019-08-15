//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSRecommendationFilterProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSRecommendationFilter : NSObject <EMSRecommendationFilterProtocol>

+ (id <EMSRecommendationFilterProtocol>)excludeWithField:(NSString *)field
                                           isExpectation:(NSString *)expectation;

+ (id <EMSRecommendationFilterProtocol>)excludeWithField:(NSString *)field
                                          inExpectations:(NSArray <NSString *> *)expectations;

+ (id <EMSRecommendationFilterProtocol>)excludeWithField:(NSString *)field
                                          hasExpectation:(NSString *)expectation;

+ (id <EMSRecommendationFilterProtocol>)excludeWithField:(NSString *)field
                                    overlapsExpectations:(NSArray <NSString *> *)expectations;

+ (id <EMSRecommendationFilterProtocol>)includeWithField:(NSString *)field
                                           isExpectation:(NSString *)expectation;

+ (id <EMSRecommendationFilterProtocol>)includeWithField:(NSString *)field
                                          inExpectations:(NSArray <NSString *> *)expectations;

+ (id <EMSRecommendationFilterProtocol>)includeWithField:(NSString *)field
                                          hasExpectation:(NSString *)expectation;

+ (id <EMSRecommendationFilterProtocol>)includeWithField:(NSString *)field
                                    overlapsExpectations:(NSArray <NSString *> *)expectations;

@end

NS_ASSUME_NONNULL_END