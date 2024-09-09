//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSBadgeCountAction.h"
#import "EMSDispatchWaiter.h"
#import <UserNotifications/UNUserNotificationCenter.h>
#import "EMSBlocks.h"

@interface EMSBadgeCountAction ()

@property(nonatomic, strong) UIApplication *application;
@property(nonatomic, strong) UNUserNotificationCenter *notificationCenter;
@property(nonatomic, strong) NSDictionary *action;
@property(nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation EMSBadgeCountAction

- (instancetype)initWithActionDictionary:(NSDictionary<NSString *, id> *)action
                             application:(UIApplication *)application
                  userNotificationCenter:(UNUserNotificationCenter *)userNotificationCenter
                          operationQueue:(NSOperationQueue *)operationQueue {
    NSParameterAssert(action);
    NSParameterAssert(application);
    NSParameterAssert(userNotificationCenter);
    NSParameterAssert(operationQueue);
    if (self = [super init]) {
        _action = action;
        _application = application;
        _notificationCenter = userNotificationCenter;
        _operationQueue = operationQueue;
    }
    return self;
}

- (void)execute {
    EMSDispatchWaiter *waiter = [[EMSDispatchWaiter alloc] init];
    NSInteger value = [self.action[@"value"] integerValue];
    if ([[self.action[@"method"] lowercaseString] isEqualToString:@"add"]) {
        NSInteger currentBadgeCount = [self.application applicationIconBadgeNumber];
        value += currentBadgeCount;
    }
    [waiter enter];
    [self setBadgeCount:value
        completionBlock:^(NSError * _Nullable error) {
        [waiter exit];
    }];
    [waiter waitWithInterval:2.0];
}

- (void)setBadgeCount:(NSInteger)badgeCount
      completionBlock:(EMSCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    if (@available(iOS 16.0, *)) {
        [self.notificationCenter setBadgeCount:badgeCount
                         withCompletionHandler:^(NSError * _Nullable error) {
            [weakSelf.operationQueue addOperationWithBlock:^{
                completionBlock(error);
            }];
        }];
    } else {
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            [weakSelf.application setApplicationIconBadgeNumber:badgeCount];
        }];
        operation.completionBlock = ^{
            [weakSelf.operationQueue addOperationWithBlock:^{
                completionBlock(nil);
            }];
        };
        [mainQueue addOperation:operation];
    }
}

@end
