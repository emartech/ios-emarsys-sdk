//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSActionProtocol.h"

@interface EMSOpenExternalEventAction : NSObject <EMSActionProtocol>

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithActionDictionary:(NSDictionary<NSString *, id> *)action
                             application:(UIApplication *)application;

@end