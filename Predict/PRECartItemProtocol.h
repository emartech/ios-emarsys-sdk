//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol PRECartItemProtocol <NSObject>

- (NSString *)itemId;

- (int)price;

- (int)quantity;

@end