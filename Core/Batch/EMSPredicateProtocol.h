//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol EMSPredicateProtocol <NSObject>

- (BOOL)evaluate:(id)value;

@end