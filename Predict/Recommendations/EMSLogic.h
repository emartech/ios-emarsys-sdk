//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSLogicProtocol.h"

@interface EMSLogic : NSObject <EMSLogicProtocol>

+ (id<EMSLogicProtocol>)search;
+ (id<EMSLogicProtocol>)searchWithSearchTerm:(NSString *)searchTerm;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToLogic:(EMSLogic *)logic;

- (NSUInteger)hash;

@end