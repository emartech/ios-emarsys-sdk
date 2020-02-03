//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol EMSCartItemProtocol <NSObject>

- (NSString *)itemId;

- (double)price;

- (double)quantity;

@end