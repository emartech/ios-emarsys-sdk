//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSConfigProtocol.h"
#import "EMSConfig.h"

@interface EMSConfigInternal : NSObject<EMSConfigProtocol>

- (instancetype)initWithConfig:(EMSConfig *)config;

@end