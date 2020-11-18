//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEIAMJSCommandProtocol.h"

@interface FakeCommand : NSObject<MEIAMJSCommandProtocol>

@property (nonatomic, strong) void (^completionBlock)(void);

@end