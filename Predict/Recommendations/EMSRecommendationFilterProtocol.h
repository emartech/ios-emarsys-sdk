//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol EMSRecommendationFilterProtocol <NSObject>

- (NSString *)type;

- (NSString *)field;

- (NSString *)comparison;

- (NSArray<NSString *> *)expectations;

@end