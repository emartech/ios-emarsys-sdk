//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol EMSCartItemProtocol <NSObject>

- (NSString *)itemId;

- (int)price;

- (int)quantity;

@end