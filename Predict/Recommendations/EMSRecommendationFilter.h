//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <EmarsysSDK/EMSRecommendationFilterProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMSRecommendationFilter : NSObject <EMSRecommendationFilterProtocol>

+ (id <EMSRecommendationFilterProtocol>)excludeFilterWithField:(NSString *)field
                                                       isValue:(NSString *)value;

+ (id <EMSRecommendationFilterProtocol>)excludeFilterWithField:(NSString *)field
                                                      inValues:(NSArray <NSString *> *)values;

+ (id <EMSRecommendationFilterProtocol>)excludeFilterWithField:(NSString *)field
                                                      hasValue:(NSString *)value;

+ (id <EMSRecommendationFilterProtocol>)excludeFilterWithField:(NSString *)field
                                                overlapsValues:(NSArray <NSString *> *)values;

+ (id <EMSRecommendationFilterProtocol>)includeFilterWithField:(NSString *)field
                                                       isValue:(NSString *)value;

+ (id <EMSRecommendationFilterProtocol>)includeFilterWithField:(NSString *)field
                                                      inValues:(NSArray <NSString *> *)values;

+ (id <EMSRecommendationFilterProtocol>)includeFilterWithField:(NSString *)field
                                                      hasValue:(NSString *)value;

+ (id <EMSRecommendationFilterProtocol>)includeFilterWithField:(NSString *)field
                                                overlapsValues:(NSArray <NSString *> *)values;

@end

NS_ASSUME_NONNULL_END
