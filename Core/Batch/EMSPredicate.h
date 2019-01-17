//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface EMSPredicate<__covariant T> : NSObject

- (BOOL)evaluate:(T)value;

@end