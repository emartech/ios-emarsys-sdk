//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEIAMClose.h"
#import "MEIAMProtocol.h"

@interface MEIAMClose ()

@property(weak, nonatomic) id <MEIAMProtocol> meiam;

@end

@implementation MEIAMClose

+ (NSString *)commandName {
    return @"close";
}

- (instancetype)initWithMEIAM:(id <MEIAMProtocol>)meiam {
    if (self = [super init]) {
        _meiam = meiam;
    }
    return self;
}

- (void)handleMessage:(NSDictionary *)message
          resultBlock:(MEIAMJSResultBlock)resultBlock {
    [self.meiam closeInAppMessageWithCompletionBlock:nil];
}

@end