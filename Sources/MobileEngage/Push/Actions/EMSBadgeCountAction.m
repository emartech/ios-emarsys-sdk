//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSBadgeCountAction.h"

@interface EMSBadgeCountAction ()

@property(nonatomic, strong) UIApplication *application;
@property(nonatomic, strong) NSDictionary *action;

@end

@implementation EMSBadgeCountAction

- (instancetype)initWithActionDictionary:(NSDictionary<NSString *, id> *)action
                             application:(UIApplication *)application {
    NSParameterAssert(action);
    NSParameterAssert(application);
    if (self = [super init]) {
        _action = action;
        _application = application;
    }
    return self;
}

- (void)execute {
    NSInteger value = [self.action[@"value"] integerValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[self.action[@"method"] lowercaseString] isEqualToString:@"add"]) {
            NSInteger currentBadgeCount = [self.application applicationIconBadgeNumber];
            [self.application setApplicationIconBadgeNumber:currentBadgeCount + value];
        } else {
            [self.application setApplicationIconBadgeNumber:value];
        }
    });
}

@end