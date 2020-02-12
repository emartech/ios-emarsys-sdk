//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSActionProtocol.h"
#import <UIKit/UIKit.h>

@interface EMSBadgeCountAction : NSObject<EMSActionProtocol>

- (instancetype)initWithActionDictionary:(NSDictionary<NSString *, id> *)action
                             application:(UIApplication *)application;

@end