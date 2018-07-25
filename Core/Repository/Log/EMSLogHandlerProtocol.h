//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol EMSLogHandlerProtocol <NSObject>

- (NSDictionary<NSString *, NSObject *> *)handle:(NSDictionary<NSString *, NSObject *> *)item;

@end