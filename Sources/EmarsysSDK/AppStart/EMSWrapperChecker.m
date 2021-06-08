//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import "EMSWrapperChecker.h"
#import "EMSDispatchWaiter.h"

@interface EMSWrapperChecker ()

@property(nonatomic, strong) NSOperationQueue *queue;
@property(nonatomic, strong) EMSDispatchWaiter *waiter;
@property(nonatomic, strong) NSString *innerWrapper;

@end

@implementation EMSWrapperChecker

- (instancetype)initWithOperationQueue:(NSOperationQueue *)queue
                                waiter:(EMSDispatchWaiter *)waiter {
    NSParameterAssert(queue);
    NSParameterAssert(waiter);
    if (self = [super init]) {
        _queue = queue;
        _waiter = waiter;
    }
    return self;
}

- (NSString *)wrapper {
    if (!self.innerWrapper) {
        self.innerWrapper = @"none";
        [self.waiter enter];
        __weak typeof(self) weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:@"EmarsysSDKWrapperExist"
                                                          object:nil
                                                           queue:self.queue
                                                      usingBlock:^(NSNotification *note) {
                                                          weakSelf.innerWrapper = note.object;
                                                          [weakSelf.waiter exit];
                                                      }];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EmarsysSDKWrapperCheckerNotification"
                                                            object:nil];
        [self.waiter waitWithInterval:1];
    }
    return self.innerWrapper;
}

@end