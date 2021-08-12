//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSBadgeCountAction.h"
#import "EMSDispatchWaiter.h"

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
    EMSDispatchWaiter *waiter = [[EMSDispatchWaiter alloc] init];
    NSInteger value = [self.action[@"value"] integerValue];

    __weak typeof(self) weakSelf = self;
    [waiter enter];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[weakSelf.action[@"method"] lowercaseString] isEqualToString:@"add"]) {
            NSInteger currentBadgeCount = [weakSelf.application applicationIconBadgeNumber];
            [weakSelf.application setApplicationIconBadgeNumber:currentBadgeCount + value];
        } else {
            [weakSelf.application setApplicationIconBadgeNumber:value];
        }
        [waiter exit];
    });

    [waiter waitWithInterval:2];
}

@end