//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MEIAMJSCommandProtocol.h"

@interface MEIAMOpenExternalLink : NSObject <MEIAMJSCommandProtocol>

- (instancetype)initWithApplication:(UIApplication *)application;

@end