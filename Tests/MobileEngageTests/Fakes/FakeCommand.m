//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "FakeCommand.h"


@implementation FakeCommand

+ (NSString *)commandName {
    return @"FakeCommand";
}

- (void)handleMessage:(NSDictionary *)message
          resultBlock:(MEIAMJSResultBlock)resultBlock {
    self.completionBlock();
}


@end