//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSRequestModelRepository.h"

@interface FakeRequestRepository : EMSRequestModelRepository

@property (nonatomic, strong) NSDictionary *queryResponseMapping;
@property (nonatomic, assign) BOOL isEmpty;

@end