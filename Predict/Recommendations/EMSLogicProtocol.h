//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EMSLogicProtocol <NSObject>

- (NSString *)logic;

- (NSDictionary<NSString *, NSString *> *)data;

- (NSArray <NSString *> *)variants;

@end