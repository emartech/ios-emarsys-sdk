//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEIAMClose.h"
#import "MEIAMProtocol.h"

@interface MEIAMClose ()

@property(weak, nonatomic) id <EMSIAMCloseProtocol> closeProtocol;

@end

@implementation MEIAMClose

+ (NSString *)commandName {
    return @"close";
}

- (instancetype)initWithEMSIAMCloseProtocol:(id <EMSIAMCloseProtocol>)closeProtocol {
    if (self = [super init]) {
        _closeProtocol = closeProtocol;
    }
    return self;
}

- (void)handleMessage:(NSDictionary *)message
          resultBlock:(MEIAMJSResultBlock)resultBlock {
    [self.closeProtocol closeInAppWithCompletionHandler:nil];
}

@end