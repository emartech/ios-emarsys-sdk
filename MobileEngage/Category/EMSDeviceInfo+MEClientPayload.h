//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSDeviceInfo.h"

@interface EMSDeviceInfo (MEClientPayload)

- (NSDictionary<NSString *, NSString *> *)clientPayload;

@end